import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/home_repository.dart';
import '../../domain/models/health_evaluation.dart';
import '../../domain/services/health_evaluator.dart';
import '../widgets/today_medicines_card.dart';
import '../../../../core/services/notification_action_handler.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🏠 HOME PROVIDER - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Version: 2.0.0
// Architecture: Clean Architecture + Provider Pattern
//
// Features:
// • Optimistic UI Updates (instant feedback like Facebook/Instagram)
// • Per-Medicine Processing Tracking (prevents duplicate actions)
// • Debounce Protection (prevents rapid-fire clicks)
// • External Notification Sync (updates from notification actions)
// • Idempotent Operations (same action = same result)
// • State Recovery (handles app lifecycle changes)
//
// Security:
// • Guard checks prevent duplicate submissions
// • Processing state tracked per-medicine
// • Safe disposal with null checks
//
// ═══════════════════════════════════════════════════════════════════════════════

enum HomeState {
  initial,
  loading,
  loaded,
  error,
  refreshing,
}

class HomeProvider extends ChangeNotifier {
  final HomeRepository _repository;
  final FirebaseAuth _auth;

  HomeState _state = HomeState.initial;
  HealthSummary _healthSummary = HealthSummary.empty();
  LatestReadings _latestReadings = LatestReadings.empty();
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  bool _isDisposed = false;

  List<MedicineItem> _todayMedicines = [];
  int _totalMedicinesCount = 0;
  int _totalReadingsCount = 0;
  int _unreadNotificationsCount = 0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 PROCESSING STATE - Prevents duplicate actions
  // ═══════════════════════════════════════════════════════════════════════════

  final Set<String> _processingMedicineIds = {};
  DateTime? _lastActionTime;
  static const Duration _actionDebounceTime = Duration(milliseconds: 500);

  StreamSubscription<NotificationActionEvent>? _notificationSubscription;

  HomeProvider({
    HomeRepository? repository,
    FirebaseAuth? auth,
  })  : _repository = repository ?? HomeRepository(),
        _auth = auth ?? FirebaseAuth.instance {
    _setupNotificationListener();
    _registerNotificationCallback();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS - State Access
  // ═══════════════════════════════════════════════════════════════════════════

  HomeState get state => _state;
  bool get isLoading => _state == HomeState.loading;
  bool get isRefreshing => _state == HomeState.refreshing;
  bool get hasError => _state == HomeState.error;
  bool get isLoaded => _state == HomeState.loaded;
  bool get hasData => _latestReadings.hasAnyReading || _userData != null;

  HealthSummary get healthSummary => _healthSummary;
  LatestReadings get latestReadings => _latestReadings;

  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  String get userName => _userData?['name'] as String? ?? 'المستخدم';
  double get userHeight => (_userData?['height'] as num?)?.toDouble() ?? 170.0;
  String? get userEmail => _auth.currentUser?.email;
  String? get userAvatarUrl => _userData?['avatarUrl'] as String?;

  DateTime? get userCreatedAt {
    final createdAtData = _userData?['createdAt'];
    if (createdAtData == null) return null;

    if (createdAtData is Timestamp) {
      return createdAtData.toDate();
    }

    if (createdAtData is DateTime) {
      return createdAtData;
    }

    return null;
  }

  List<MedicineItem> get todayMedicines => _todayMedicines;
  int get medicinesCount => _totalMedicinesCount;
  int get readingsCount => _totalReadingsCount;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  int get takenMedicinesCount =>
      _todayMedicines.where((m) => m.status == MedicineStatus.taken).length;
  int get pendingMedicinesCount =>
      _todayMedicines.where((m) => m.status == MedicineStatus.upcoming).length;
  int get missedMedicinesCount =>
      _todayMedicines.where((m) => m.status == MedicineStatus.missed).length;

  String? get _currentUserId => _auth.currentUser?.uid;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 PROCESSING STATE GETTERS - For UI to check loading state
  // ═══════════════════════════════════════════════════════════════════════════

  bool isMedicineProcessing(String medicineId) => 
      _processingMedicineIds.contains(medicineId);

  bool get hasAnyProcessing => _processingMedicineIds.isNotEmpty;

  Set<String> get processingMedicineIds => 
      Set.unmodifiable(_processingMedicineIds);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 NOTIFICATION CALLBACK REGISTRATION
  // ═══════════════════════════════════════════════════════════════════════════

  void _registerNotificationCallback() {
    try {
      NotificationActionHandler.instance.setMedicineActionCallback(() {
        debugPrint('🔔 HomeProvider: Medicine action callback triggered');
        _refreshMedicinesOnly();
      });
      debugPrint('✅ HomeProvider: Notification callback registered');
    } catch (e) {
      debugPrint('⚠️ HomeProvider: Failed to register notification callback: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION LISTENER - Auto-refresh on medicine actions
  // ═══════════════════════════════════════════════════════════════════════════

  void _setupNotificationListener() {
    try {
      _notificationSubscription = NotificationActionHandler.instance.actionStream.listen(
        (event) {
          debugPrint('🔔 HomeProvider: Received notification action: ${event.type}');
          
          if (event.success && 
              (event.type == NotificationActionType.markTaken ||
               event.type == NotificationActionType.skip ||
               event.type == NotificationActionType.snooze)) {
            debugPrint('🔄 HomeProvider: Auto-refreshing after ${event.type}');
            
            final medicineId = event.payload.medicineId;
            if (medicineId != null) {
              _processingMedicineIds.remove(medicineId);
            }
            
            _refreshMedicinesOnly();
          }
        },
        onError: (error) {
          debugPrint('❌ HomeProvider: Notification stream error: $error');
        },
      );
      debugPrint('✅ HomeProvider: Notification listener setup complete');
    } catch (e) {
      debugPrint('⚠️ HomeProvider: Failed to setup notification listener: $e');
    }
  }

  Future<void> _refreshMedicinesOnly() async {
    final userId = _currentUserId;
    if (userId == null || _isDisposed) return;

    try {
      await _loadMedicinesData(userId);
      _safeNotifyListeners();
      debugPrint('✅ HomeProvider: Medicines refreshed');
    } catch (e) {
      debugPrint('❌ HomeProvider: Error refreshing medicines: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 PUBLIC METHOD FOR EXTERNAL REFRESH (e.g., from app.dart)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> refreshMedicines() async {
    await _refreshMedicinesOnly();
  }

  void forceRefreshFromNotification() {
    debugPrint('🔄 HomeProvider: Force refresh from notification');
    _refreshMedicinesOnly();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOAD DATA
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadInitialData() async {
    final userId = _currentUserId;
    if (userId == null) {
      _setError('المستخدم غير مسجل');
      return;
    }

    _setState(HomeState.loading);
    _errorMessage = null;

    bool hasAnySuccess = false;
    String? lastError;

    final userResult = await _repository.getUserData(userId);
    userResult.when(
      success: (data) {
        _userData = data;
        hasAnySuccess = true;
      },
      failure: (message, _) {
        lastError = message;
        debugPrint('User data error: $message');
      },
    );

    final readingsResult = await _repository.getLatestReadings(userId);
    readingsResult.when(
      success: (data) {
        _latestReadings = data;
        hasAnySuccess = true;
      },
      failure: (message, _) {
        lastError = message;
        debugPrint('Readings error: $message');
        _latestReadings = LatestReadings.empty();
      },
    );

    await _loadMedicinesData(userId);

    await _loadReadingsCount(userId);
    
    await _loadUnreadNotificationsCount(userId);

    _calculateHealthSummary();

    if (hasAnySuccess) {
      _setState(HomeState.loaded);
    } else {
      _setError(lastError ?? 'فشل تحميل البيانات');
    }
  }

  Future<void> _loadMedicinesData(String userId) async {
    try {
      final medicinesResult = await _repository.getTodayMedicines(userId);
      medicinesResult.when(
        success: (medicines) {
          _todayMedicines = medicines.map((m) => _convertToMedicineItem(m)).toList();
          _totalMedicinesCount = medicines.length;
        },
        failure: (_, __) {
          _todayMedicines = [];
          _totalMedicinesCount = 0;
        },
      );
    } catch (e) {
      debugPrint('Error loading medicines: $e');
      _todayMedicines = [];
      _totalMedicinesCount = 0;
    }
  }

  Future<void> _loadReadingsCount(String userId) async {
    try {
      final countResult = await _repository.getReadingsCount(userId);
      countResult.when(
        success: (value) {
          _totalReadingsCount = value;
        },
        failure: (_, __) {
          _totalReadingsCount = 0;
        },
      );
    } catch (e) {
      debugPrint('Error loading readings count: $e');
      _totalReadingsCount = 0;
    }
  }

  Future<void> _loadUnreadNotificationsCount(String userId) async {
    try {
      final countResult = await _repository.getUnreadNotificationsCount(userId);
      countResult.when(
        success: (value) {
          _unreadNotificationsCount = value;
        },
        failure: (_, __) {
          _unreadNotificationsCount = 0;
        },
      );
    } catch (e) {
      debugPrint('Error loading unread notifications count: $e');
      _unreadNotificationsCount = 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 UPDATED: CONVERT TO MEDICINE ITEM - Now respects processing state
  // ═══════════════════════════════════════════════════════════════════════════

  MedicineItem _convertToMedicineItem(Map<String, dynamic> data) {
    final medicineId = data['id'] as String? ?? '';
    final scheduledTime = data['scheduledTime'] as String? ?? '';
    final isTaken = data['isTaken'] as bool? ?? false;
    final isSkipped = data['isSkipped'] as bool? ?? false;
    final isSnoozed = data['isSnoozed'] as bool? ?? false;
    
    final status = _calculateMedicineStatus(
      scheduledTime: scheduledTime,
      isTaken: isTaken,
      isSkipped: isSkipped,
      isSnoozed: isSnoozed,
    );

    final isProcessing = _processingMedicineIds.contains(medicineId);
    
    // الدواء المأخوذ أو المتخطى لا يمكن التفاعل معه
    final isCompleted = status == MedicineStatus.taken || 
                        status == MedicineStatus.skipped;
    
    final canTakeAction = !isCompleted && !isProcessing && status.canMarkTaken;
    final canSkipAction = !isCompleted && !isProcessing && status.canSkip;
    final canSnoozeAction = !isCompleted && !isProcessing && status.canSnooze;

    return MedicineItem(
      id: medicineId,
      name: data['name'] as String? ?? 'دواء',
      dosage: data['dosage'] as String? ?? '',
      time: _formatTime(scheduledTime),
      scheduledTime: scheduledTime,
      status: status,
      onTap: null,
      onMarkTaken: canTakeAction 
          ? () => markMedicineTaken(medicineId, scheduledTime: scheduledTime)
          : null,
      onSkip: canSkipAction
          ? () => skipMedicine(medicineId, scheduledTime: scheduledTime)
          : null,
      onSnooze: canSnoozeAction
          ? () => snoozeMedicine(medicineId, scheduledTime: scheduledTime)
          : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 UPDATED: CALCULATE MEDICINE STATUS - Includes all status types
  // ═══════════════════════════════════════════════════════════════════════════

  MedicineStatus _calculateMedicineStatus({
    required String scheduledTime,
    required bool isTaken,
    bool isSkipped = false,
    bool isSnoozed = false,
  }) {
    if (isTaken) return MedicineStatus.taken;
    if (isSkipped) return MedicineStatus.skipped;
    if (isSnoozed) return MedicineStatus.snoozed;

    try {
      final now = DateTime.now();
      final timeParts = scheduledTime.split(':');
      if (timeParts.length >= 2) {
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        final difference = now.difference(scheduledDateTime);

        if (difference.inMinutes > 60) {
          return MedicineStatus.missed;
        }
        
        if (difference.inMinutes > 0 && difference.inMinutes <= 30) {
          return MedicineStatus.inGracePeriod;
        }
        
        if (difference.inMinutes >= -5 && difference.inMinutes <= 0) {
          return MedicineStatus.due;
        }
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }

    return MedicineStatus.upcoming;
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'م' : 'ص';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (e) {
      debugPrint('Error formatting time: $e');
    }
    return time;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 ENTERPRISE GRADE: MEDICINE ACTIONS WITH FULL PROTECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> markMedicineTaken(
    String medicineId, {
    String? scheduledTime,
  }) async {
    return _executeMedicineAction(
      medicineId: medicineId,
      scheduledTime: scheduledTime,
      action: MedicineActionType.markTaken,
      targetStatus: MedicineStatus.taken,
      repositoryCall: (userId, medId, medName, schedTime) => 
          _repository.markMedicineTaken(
            userId: userId,
            medicineId: medId,
            scheduledTime: schedTime,
            medicineName: medName,
          ),
    );
  }

  Future<bool> skipMedicine(
    String medicineId, {
    String? scheduledTime,
    String? reason,
  }) async {
    return _executeMedicineAction(
      medicineId: medicineId,
      scheduledTime: scheduledTime,
      action: MedicineActionType.skip,
      targetStatus: MedicineStatus.skipped,
      repositoryCall: (userId, medId, medName, schedTime) => 
          _repository.skipMedicine(
            userId: userId,
            medicineId: medId,
            scheduledTime: schedTime,
            reason: reason,
            medicineName: medName,
          ),
    );
  }

  Future<bool> snoozeMedicine(
    String medicineId, {
    String? scheduledTime,
    int snoozeMinutes = 15,
  }) async {
    return _executeMedicineAction(
      medicineId: medicineId,
      scheduledTime: scheduledTime,
      action: MedicineActionType.snooze,
      targetStatus: MedicineStatus.snoozed,
      repositoryCall: (userId, medId, medName, schedTime) => 
          _repository.snoozeMedicine(
            userId: userId,
            medicineId: medId,
            scheduledTime: schedTime,
            snoozeMinutes: snoozeMinutes,
            medicineName: medName,
          ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 UNIFIED MEDICINE ACTION EXECUTOR - All protections in one place
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> _executeMedicineAction({
    required String medicineId,
    required String? scheduledTime,
    required MedicineActionType action,
    required MedicineStatus targetStatus,
    required Future<Result<void>> Function(
      String userId,
      String medicineId, 
      String medicineName,
      String? scheduledTime,
    ) repositoryCall,
  }) async {
    
    // ══════════════════════════════════════════════════════════════════════
    // GUARD 1: Check user authentication
    // ══════════════════════════════════════════════════════════════════════
    final userId = _currentUserId;
    if (userId == null) {
      debugPrint('⚠️ [${action.name}] User not authenticated');
      return false;
    }

    // ══════════════════════════════════════════════════════════════════════
    // GUARD 2: Check if medicine is already being processed (Idempotency)
    // ══════════════════════════════════════════════════════════════════════
    if (_processingMedicineIds.contains(medicineId)) {
      debugPrint('⚠️ [${action.name}] Medicine $medicineId already processing');
      return false;
    }

    // ══════════════════════════════════════════════════════════════════════
    // GUARD 3: Debounce - prevent rapid-fire clicks
    // ══════════════════════════════════════════════════════════════════════
    final now = DateTime.now();
    if (_lastActionTime != null && 
        now.difference(_lastActionTime!) < _actionDebounceTime) {
      debugPrint('⚠️ [${action.name}] Debounced - too fast');
      return false;
    }
    _lastActionTime = now;

    // ══════════════════════════════════════════════════════════════════════
    // GUARD 4: Check if medicine exists and can be actioned
    // ══════════════════════════════════════════════════════════════════════
    final medicineIndex = _todayMedicines.indexWhere((m) => m.id == medicineId);
    if (medicineIndex == -1) {
      debugPrint('⚠️ [${action.name}] Medicine $medicineId not found');
      return false;
    }

    final medicine = _todayMedicines[medicineIndex];
    
    if (medicine.status == MedicineStatus.taken ||
        medicine.status == MedicineStatus.skipped) {
      debugPrint('⚠️ [${action.name}] Medicine already ${medicine.status.name}');
      return false;
    }

    // ══════════════════════════════════════════════════════════════════════
    // STEP 1: Mark as processing (Optimistic Lock)
    // ══════════════════════════════════════════════════════════════════════
    _processingMedicineIds.add(medicineId);
    debugPrint('🔒 [${action.name}] Processing lock acquired for $medicineId');

    // ══════════════════════════════════════════════════════════════════════
    // STEP 2: Optimistic UI Update (Instant feedback)
    // ══════════════════════════════════════════════════════════════════════
    _updateMedicineStatusLocally(medicineIndex, targetStatus);
    _safeNotifyListeners();
    debugPrint('✨ [${action.name}] Optimistic UI update applied');

    try {
      // ════════════════════════════════════════════════════════════════════
      // STEP 3: Execute repository call
      // ════════════════════════════════════════════════════════════════════
      final result = await repositoryCall(
        userId,
        medicineId,
        medicine.name,
        scheduledTime ?? medicine.scheduledTime,
      );

      return result.when(
        success: (_) {
          debugPrint('✅ [${action.name}] Success for ${medicine.name}');
          return true;
        },
        failure: (message, error) {
          debugPrint('❌ [${action.name}] Failed: $message');
          
          // ══════════════════════════════════════════════════════════════════
          // ROLLBACK: Revert optimistic update on failure
          // ══════════════════════════════════════════════════════════════════
          _rollbackMedicineStatus(medicineIndex, medicine);
          _safeNotifyListeners();
          
          return false;
        },
      );
    } catch (e) {
      debugPrint('❌ [${action.name}] Exception: $e');
      
      // ══════════════════════════════════════════════════════════════════════
      // ROLLBACK: Revert optimistic update on exception
      // ══════════════════════════════════════════════════════════════════════
      _rollbackMedicineStatus(medicineIndex, medicine);
      _safeNotifyListeners();
      
      return false;
    } finally {
      // ══════════════════════════════════════════════════════════════════════
      // STEP 4: Release processing lock (always executes)
      // ══════════════════════════════════════════════════════════════════════
      _processingMedicineIds.remove(medicineId);
      debugPrint('🔓 [${action.name}] Processing lock released for $medicineId');
      
      // Notify to update button state
      _safeNotifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 HELPER: Update medicine status locally (Optimistic Update)
  // ═══════════════════════════════════════════════════════════════════════════

  void _updateMedicineStatusLocally(int index, MedicineStatus newStatus) {
    if (index < 0 || index >= _todayMedicines.length) return;
    
    final oldMedicine = _todayMedicines[index];
    _todayMedicines[index] = MedicineItem(
      id: oldMedicine.id,
      name: oldMedicine.name,
      dosage: oldMedicine.dosage,
      time: oldMedicine.time,
      scheduledTime: oldMedicine.scheduledTime,
      status: newStatus,
      onTap: oldMedicine.onTap,
      onMarkTaken: null,
      onSkip: null,
      onSnooze: null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 HELPER: Rollback medicine status (On failure)
  // ═══════════════════════════════════════════════════════════════════════════

  void _rollbackMedicineStatus(int index, MedicineItem originalMedicine) {
    if (index < 0 || index >= _todayMedicines.length) return;
    
    _todayMedicines[index] = originalMedicine;
    debugPrint('↩️ Rolled back medicine status for ${originalMedicine.name}');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    final userId = _currentUserId;
    if (userId == null) return;

    final previousState = _state;
    _setState(HomeState.refreshing);

    bool hasAnySuccess = false;

    final userResult = await _repository.getUserData(userId);
    userResult.when(
      success: (data) {
        _userData = data;
        hasAnySuccess = true;
      },
      failure: (_, __) {},
    );

    final readingsResult = await _repository.getLatestReadings(userId);
    readingsResult.when(
      success: (data) {
        _latestReadings = data;
        hasAnySuccess = true;
      },
      failure: (_, __) {},
    );

    await _loadMedicinesData(userId);

    await _loadReadingsCount(userId);
    
    await _loadUnreadNotificationsCount(userId);

    _calculateHealthSummary();

    if (hasAnySuccess || previousState == HomeState.loaded) {
      _setState(HomeState.loaded);
    } else {
      _setState(previousState);
    }
  }

  Future<void> retryLoad() async {
    if (_state == HomeState.error) {
      await loadInitialData();
    }
  }

  void _calculateHealthSummary() {
    _healthSummary = HealthEvaluator.evaluateHealth(
      bloodPressure: _latestReadings.bloodPressure,
      bloodSugar: _latestReadings.bloodSugar,
      weight: _latestReadings.weight,
      userHeight: userHeight,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  void _setState(HomeState newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    if (_isDisposed) return;
    _errorMessage = message;
    _state = HomeState.error;
    notifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void reset() {
    _state = HomeState.initial;
    _healthSummary = HealthSummary.empty();
    _latestReadings = LatestReadings.empty();
    _userData = null;
    _errorMessage = null;
    _todayMedicines = [];
    _totalMedicinesCount = 0;
    _totalReadingsCount = 0;
    _unreadNotificationsCount = 0;
    _processingMedicineIds.clear();
    _lastActionTime = null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _processingMedicineIds.clear();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🆕 MEDICINE ACTION TYPE ENUM - For unified action handling
// ═══════════════════════════════════════════════════════════════════════════════

enum MedicineActionType {
  markTaken,
  skip,
  snooze,
}
