import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorPatientDetailProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String patientId;

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? patientData;
  List<Map<String, dynamic>> healthReadings = [];
  List<Map<String, dynamic>> activeMedicines = [];
  double adherenceRate = -1.0; // -1 = unavailable

  // UI state for chart type selector
  String _selectedReadingType = 'bloodSugar';
  bool _isTableView = false;

  // Stream subscriptions for real-time updates
  StreamSubscription? _healthSub;
  StreamSubscription? _medicinesSub;

  DoctorPatientDetailProvider(this.patientId) {
    _init();
  }

  // --- Getters ---
  String get selectedReadingType => _selectedReadingType;
  bool get isTableView => _isTableView;

  void setSelectedReadingType(String type) {
    if (_selectedReadingType == type) return;
    _selectedReadingType = type;
    notifyListeners();
  }

  void toggleViewMode() {
    _isTableView = !_isTableView;
    notifyListeners();
  }

  /// Get readings filtered by the currently selected type
  List<Map<String, dynamic>> get filteredReadings {
    return healthReadings
        .where((r) => r['type'] == _selectedReadingType)
        .toList();
  }

  /// Get unique reading types available in the data
  List<String> get availableReadingTypes {
    final types = healthReadings.map((r) => r['type'] as String? ?? '').toSet();
    types.remove('');
    return types.toList();
  }

  // --- Initialization ---
  Future<void> _init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Load demographics once (doesn't change often)
      await _loadPatientDemographics();

      // Set up real-time streams for health readings and medicines
      _setupHealthReadingsStream();
      _setupMedicinesStream();

      // Load adherence data
      await _calculateRealAdherence();

      isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ DoctorPatientDetailProvider error: $e');
      debugPrint('❌ Stack: $stackTrace');
      errorMessage = 'تعذر استرداد بيانات المريض (${e.runtimeType}).';
      isLoading = false;
      notifyListeners();
    }
  }

  // --- Demographics (one-time read) ---
  Future<void> _loadPatientDemographics() async {
    debugPrint('📋 Loading demographics for patient: $patientId');
    final doc = await _firestore.collection('users').doc(patientId).get();
    if (doc.exists) {
      patientData = doc.data();
      debugPrint('📋 Demographics loaded: ${patientData?['name']}');
    }
  }

  // --- Health Readings (real-time stream) ---
  void _setupHealthReadingsStream() {
    _healthSub?.cancel();
    _healthSub = _firestore
        .collection('health_readings')
        .where('userId', isEqualTo: patientId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      healthReadings = snapshot.docs.map((e) {
        final data = e.data();
        data['id'] = e.id;
        return data;
      }).toList();
      debugPrint('📊 Health readings stream: ${healthReadings.length} readings');
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ Health readings stream error: $e');
    });
  }

  // --- Active Medicines (real-time stream) ---
  void _setupMedicinesStream() {
    _medicinesSub?.cancel();
    _medicinesSub = _firestore
        .collection('medicines')
        .where('userId', isEqualTo: patientId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      activeMedicines = snapshot.docs.map((e) {
        final data = e.data();
        data['id'] = e.id;
        return data;
      }).toList();
      debugPrint('💊 Medicines stream: ${activeMedicines.length} active');

      // Recalculate adherence when medicines change
      _calculateRealAdherence();
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ Medicines stream error: $e');
    });
  }

  // --- Real Adherence Calculation ---
  Future<void> _calculateRealAdherence() async {
    try {
      if (activeMedicines.isEmpty) {
        adherenceRate = -1.0;
        return;
      }

      // Query medicine_logs for the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final logsQuery = await _firestore
          .collection('medicine_logs')
          .where('odId', isEqualTo: patientId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      // Also check userId field (some logs may use userId instead of odId)
      QuerySnapshot<Map<String, dynamic>>? logsQuery2;
      if (logsQuery.docs.isEmpty) {
        logsQuery2 = await _firestore
            .collection('medicine_logs')
            .where('userId', isEqualTo: patientId)
            .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
            .get();
      }

      final allLogs = [
        ...logsQuery.docs,
        ...(logsQuery2?.docs ?? []),
      ];

      // Count taken doses
      final takenDoses = allLogs.where((log) {
        final status = log.data()['status'] ?? log.data()['action'];
        return status == 'taken' || status == 'take';
      }).length;

      // Calculate expected doses: sum of daily doses × 30 days
      int totalExpectedPerDay = 0;
      for (final med in activeMedicines) {
        final times = med['times'] as List<dynamic>?;
        totalExpectedPerDay += times?.length ?? 1;
      }
      final expectedDoses = totalExpectedPerDay * 30;

      if (expectedDoses == 0) {
        adherenceRate = -1.0;
      } else {
        adherenceRate = (takenDoses / expectedDoses * 100).clamp(0.0, 100.0);
      }

      debugPrint('🎯 Adherence: $takenDoses taken / $expectedDoses expected = ${adherenceRate.toStringAsFixed(1)}%');
    } catch (e) {
      debugPrint('❌ Adherence calculation error: $e');
      adherenceRate = -1.0;
    }
  }

  Future<void> refresh() => _init();

  // --- Computed Properties ---
  String get patientName => patientData?['name'] ?? 'مريض غير معروف';
  String get bloodType => patientData?['bloodType'] ?? '--';
  String get phone => patientData?['phone'] ?? '--';

  String get genderArabic {
    final ga = patientData?['genderArabic'];
    if (ga != null) return ga;
    final g = patientData?['gender'];
    if (g == 'male') return 'ذكر';
    if (g == 'female') return 'أنثى';
    return '--';
  }

  String get age {
    final raw = patientData?['dateOfBirth'];
    if (raw == null) return '--';

    DateTime? dob;
    if (raw is Timestamp) {
      dob = raw.toDate();
    } else if (raw is String) {
      dob = DateTime.tryParse(raw);
    }
    if (dob == null) return '--';

    final today = DateTime.now();
    int calculatedAge = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      calculatedAge--;
    }
    return calculatedAge.toString();
  }

  @override
  void dispose() {
    _healthSub?.cancel();
    _medicinesSub?.cancel();
    super.dispose();
  }
}
