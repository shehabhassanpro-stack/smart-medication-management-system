import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/services/doctor_patient_service.dart';

/// Aggregated analytics provider for the doctor's reports dashboard.
/// Loads cross-patient statistics: KPIs, critical alerts, adherence ranking.
class DoctorReportsProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final DoctorPatientService _doctorPatientService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;
  StreamSubscription? _patientsSub;

  // --- KPI Data ---
  int _totalPatients = 0;
  int _totalActiveMedicines = 0;
  double _averageAdherence = -1.0;
  List<CriticalAlert> _criticalAlerts = [];
  List<PatientAdherence> _adherenceRanking = [];

  // --- Filter ---
  String _selectedPeriod = '30d';

  DoctorReportsProvider(this._authProvider,
      {DoctorPatientService? doctorPatientService})
      : _doctorPatientService =
            doctorPatientService ?? DoctorPatientService() {
    _init();
  }

  /// Safe notifyListeners that respects dispose lifecycle
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalPatients => _totalPatients;
  int get totalActiveMedicines => _totalActiveMedicines;
  double get averageAdherence => _averageAdherence;
  List<CriticalAlert> get criticalAlerts => _criticalAlerts;
  List<PatientAdherence> get adherenceRanking => _adherenceRanking;
  String get selectedPeriod => _selectedPeriod;

  int get _periodDays {
    switch (_selectedPeriod) {
      case '7d':
        return 7;
      case '90d':
        return 90;
      default:
        return 30;
    }
  }

  void setSelectedPeriod(String period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    _safeNotify();
    _loadAnalytics();
  }

  String get uid => _authProvider.userModel?.uid ?? '';

  // --- Initialization ---
  Future<void> _init() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      if (uid.isEmpty) {
        _isLoading = false;
        _safeNotify();
        return;
      }

      // Listen to patient list changes
      _patientsSub?.cancel();
      _patientsSub =
          _doctorPatientService.getDoctorPatients(uid).listen((patients) {
        _totalPatients = patients.length;
        _safeNotify();
        _loadAnalytics();
      }, onError: (e) {
        debugPrint('❌ Reports patients stream error: $e');
        _errorMessage = 'حدث خطأ أثناء تحميل بيانات المرضى';
        _isLoading = false;
        _safeNotify();
      });
    } catch (e, st) {
      debugPrint('❌ DoctorReportsProvider init error: $e\n$st');
      _errorMessage = 'حدث خطأ غير متوقع (${e.runtimeType})';
      _isLoading = false;
      _safeNotify();
    }
  }

  // --- Load All Analytics ---
  Future<void> _loadAnalytics() async {
    if (_disposed) return;

    try {
      // Step 1: Get linked patient IDs
      final linksSnap = await _firestore
          .collection('doctor_patients')
          .where('doctorId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .get();

      if (_disposed) return;

      final patientIds =
          linksSnap.docs.map((d) => d.data()['patientId'] as String).toList();
      final patientNames = <String, String>{};
      for (final doc in linksSnap.docs) {
        patientNames[doc.data()['patientId']] =
            doc.data()['patientName'] ?? 'مريض';
      }

      _totalPatients = patientIds.length;

      if (patientIds.isEmpty) {
        _totalActiveMedicines = 0;
        _averageAdherence = -1.0;
        _criticalAlerts = [];
        _adherenceRanking = [];
        _isLoading = false;
        _safeNotify();
        return;
      }

      // Step 2: Load medicines, readings, and logs in parallel (batched)
      await Future.wait([
        _loadMedicinesCount(patientIds),
        _loadCriticalAlerts(patientIds, patientNames),
        _loadAdherenceRanking(patientIds, patientNames),
      ]);

      if (_disposed) return;

      _isLoading = false;
      _safeNotify();
    } catch (e, st) {
      debugPrint('❌ _loadAnalytics error: $e\n$st');
      if (_disposed) return;
      _errorMessage = 'تعذر تحميل التقارير (${e.runtimeType})';
      _isLoading = false;
      _safeNotify();
    }
  }

  // --- Load Active Medicines Count ---
  Future<void> _loadMedicinesCount(List<String> patientIds) async {
    int total = 0;
    for (int i = 0; i < patientIds.length; i += 10) {
      final batch =
          patientIds.sublist(i, (i + 10).clamp(0, patientIds.length));
      final snap = await _firestore
          .collection('medicines')
          .where('userId', whereIn: batch)
          .where('isActive', isEqualTo: true)
          .get();
      total += snap.docs.length;
    }
    _totalActiveMedicines = total;
  }

  // --- Load Critical Alerts ---
  Future<void> _loadCriticalAlerts(
      List<String> patientIds, Map<String, String> names) async {
    final cutoff = DateTime.now().subtract(Duration(days: _periodDays));
    final alerts = <CriticalAlert>[];

    for (int i = 0; i < patientIds.length; i += 10) {
      final batch =
          patientIds.sublist(i, (i + 10).clamp(0, patientIds.length));
      final snap = await _firestore
          .collection('health_readings')
          .where('userId', whereIn: batch)
          .where('timestamp',
              isGreaterThan: Timestamp.fromDate(cutoff))
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final type = data['type'] as String? ?? '';
        final userId = data['userId'] as String? ?? '';
        final ts = data['timestamp'] as Timestamp?;

        CriticalAlert? alert;

        if (type == 'bloodSugar') {
          final val = (data['value'] as num?)?.toDouble() ?? 0;
          if (val > 300) {
            alert = CriticalAlert(
              patientId: userId,
              patientName: names[userId] ?? 'مريض',
              type: 'سكر مرتفع جداً',
              value: '${val.toStringAsFixed(0)} mg/dL',
              severity: AlertSeverity.critical,
              timestamp: ts?.toDate(),
            );
          } else if (val < 50) {
            alert = CriticalAlert(
              patientId: userId,
              patientName: names[userId] ?? 'مريض',
              type: 'سكر منخفض جداً',
              value: '${val.toStringAsFixed(0)} mg/dL',
              severity: AlertSeverity.critical,
              timestamp: ts?.toDate(),
            );
          } else if (val > 200) {
            alert = CriticalAlert(
              patientId: userId,
              patientName: names[userId] ?? 'مريض',
              type: 'سكر مرتفع',
              value: '${val.toStringAsFixed(0)} mg/dL',
              severity: AlertSeverity.warning,
              timestamp: ts?.toDate(),
            );
          }
        } else if (type == 'bloodPressure') {
          final sys =
              (data['systolic'] ?? data['value'] as num?)?.toDouble() ?? 0;
          if (sys > 180) {
            alert = CriticalAlert(
              patientId: userId,
              patientName: names[userId] ?? 'مريض',
              type: 'ضغط مرتفع جداً',
              value: '${sys.toStringAsFixed(0)} mmHg',
              severity: AlertSeverity.critical,
              timestamp: ts?.toDate(),
            );
          } else if (sys > 140) {
            alert = CriticalAlert(
              patientId: userId,
              patientName: names[userId] ?? 'مريض',
              type: 'ضغط مرتفع',
              value: '${sys.toStringAsFixed(0)} mmHg',
              severity: AlertSeverity.warning,
              timestamp: ts?.toDate(),
            );
          }
        } else if (type == 'temperature') {
          final val = (data['value'] as num?)?.toDouble() ?? 0;
          if (val > 39.0) {
            alert = CriticalAlert(
              patientId: userId,
              patientName: names[userId] ?? 'مريض',
              type: 'حرارة مرتفعة',
              value: '${val.toStringAsFixed(1)} °C',
              severity: val > 40 ? AlertSeverity.critical : AlertSeverity.warning,
              timestamp: ts?.toDate(),
            );
          }
        }

        if (alert != null) alerts.add(alert);
      }
    }

    // Sort: critical first, then by timestamp (newest first)
    alerts.sort((a, b) {
      final severityCompare = b.severity.index.compareTo(a.severity.index);
      if (severityCompare != 0) return severityCompare;
      return (b.timestamp ?? DateTime(2000))
          .compareTo(a.timestamp ?? DateTime(2000));
    });

    _criticalAlerts = alerts.take(20).toList();
  }

  // --- Load Adherence Ranking ---
  Future<void> _loadAdherenceRanking(
      List<String> patientIds, Map<String, String> names) async {
    final cutoff = DateTime.now().subtract(Duration(days: _periodDays));
    final ranking = <PatientAdherence>[];

    for (final pid in patientIds) {
      if (_disposed) return;

      // Get active medicines for this patient
      final medsSnap = await _firestore
          .collection('medicines')
          .where('userId', isEqualTo: pid)
          .where('isActive', isEqualTo: true)
          .get();

      if (medsSnap.docs.isEmpty) {
        ranking.add(PatientAdherence(
          patientId: pid,
          patientName: names[pid] ?? 'مريض',
          adherenceRate: -1.0,
          totalMedicines: 0,
        ));
        continue;
      }

      // Count expected daily doses
      int expectedPerDay = 0;
      for (final med in medsSnap.docs) {
        final times = med.data()['times'] as List<dynamic>?;
        expectedPerDay += times?.length ?? 1;
      }
      final expectedTotal = expectedPerDay * _periodDays;

      // Count taken doses — try userId first, fallback to odId
      int takenCount = 0;
      try {
        final logsSnap = await _firestore
            .collection('medicine_logs')
            .where('userId', isEqualTo: pid)
            .where('timestamp',
                isGreaterThan: Timestamp.fromDate(cutoff))
            .get();
        takenCount = logsSnap.docs.where((d) {
          final s = d.data()['status'] ?? d.data()['action'];
          return s == 'taken' || s == 'take';
        }).length;
      } catch (e) {
        debugPrint('⚠️ medicine_logs userId query failed for $pid: $e');
        // If userId index fails, try odId
        try {
          final logsSnap = await _firestore
              .collection('medicine_logs')
              .where('odId', isEqualTo: pid)
              .where('timestamp',
                  isGreaterThan: Timestamp.fromDate(cutoff))
              .get();
          takenCount = logsSnap.docs.where((d) {
            final s = d.data()['status'] ?? d.data()['action'];
            return s == 'taken' || s == 'take';
          }).length;
        } catch (e2) {
          debugPrint('⚠️ medicine_logs odId query also failed for $pid: $e2');
          // If both indexes are missing, just mark as no data
          takenCount = 0;
        }
      }

      final rate = expectedTotal > 0
          ? (takenCount / expectedTotal * 100).clamp(0.0, 100.0)
          : -1.0;

      ranking.add(PatientAdherence(
        patientId: pid,
        patientName: names[pid] ?? 'مريض',
        adherenceRate: rate,
        totalMedicines: medsSnap.docs.length,
      ));
    }

    // Sort: lowest adherence first (needs most attention)
    ranking.sort((a, b) {
      if (a.adherenceRate < 0 && b.adherenceRate < 0) return 0;
      if (a.adherenceRate < 0) return 1;
      if (b.adherenceRate < 0) return -1;
      return a.adherenceRate.compareTo(b.adherenceRate);
    });

    _adherenceRanking = ranking;

    // Calculate average (exclude -1 patients)
    final valid = ranking.where((r) => r.adherenceRate >= 0).toList();
    if (valid.isNotEmpty) {
      _averageAdherence =
          valid.fold(0.0, (acc, r) => acc + r.adherenceRate) / valid.length;
    } else {
      _averageAdherence = -1.0;
    }
  }

  Future<void> refresh() => _init();

  @override
  void dispose() {
    _disposed = true;
    _patientsSub?.cancel();
    super.dispose();
  }
}

// --- Data Models ---

enum AlertSeverity { warning, critical }

class CriticalAlert {
  final String patientId;
  final String patientName;
  final String type;
  final String value;
  final AlertSeverity severity;
  final DateTime? timestamp;

  const CriticalAlert({
    required this.patientId,
    required this.patientName,
    required this.type,
    required this.value,
    required this.severity,
    this.timestamp,
  });
}

class PatientAdherence {
  final String patientId;
  final String patientName;
  final double adherenceRate;
  final int totalMedicines;

  const PatientAdherence({
    required this.patientId,
    required this.patientName,
    required this.adherenceRate,
    required this.totalMedicines,
  });
}
