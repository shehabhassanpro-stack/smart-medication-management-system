import 'package:flutter/foundation.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../../../../core/services/notification_scheduler.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/offline_banner.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 MEDICINES PROVIDER - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Critical Fixes Applied:
// ✓ Added _isDisposed flag to prevent "used after disposed" errors
// ✓ Added _safeNotifyListeners() for safe state updates
// ✓ Added mounted checks for all async operations
// ✓ Added adherence rate calculation
// ✓ Proper dispose() override with cleanup
//
// ═══════════════════════════════════════════════════════════════════════════════

enum MedicinesStatus {
  initial,
  loading,
  loaded,
  error,
}

class MedicinesProvider extends ChangeNotifier {
  final MedicinesRepository _repository;
  final String _userId;
  final NotificationScheduler _notificationScheduler = NotificationScheduler.instance;

  bool _isDisposed = false;

  MedicinesProvider({
    required MedicinesRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId;

  MedicinesStatus _status = MedicinesStatus.initial;
  List<MedicineEntity> _medicines = [];
  List<MedicineEntity> _todaySchedule = [];
  MedicinesCount _medicinesCount = MedicinesCount.zero();
  String? _errorMessage;

  String _searchQuery = '';
  MedicineFilter _currentFilter = const MedicineFilter();
  MedicineSort _currentSort = MedicineSort.createdAtDesc;

  double _adherenceRate = 0.0;
  int _takenDosesToday = 0;
  int _totalDosesToday = 0;

  MedicinesStatus get status => _status;
  List<MedicineEntity> get medicines => _medicines;
  List<MedicineEntity> get todaySchedule => _todaySchedule;
  MedicinesCount get medicinesCount => _medicinesCount;
  String? get errorMessage => _errorMessage;
  String get userId => _userId;

  String get searchQuery => _searchQuery;
  MedicineFilter get currentFilter => _currentFilter;
  MedicineSort get currentSort => _currentSort;

  bool get isLoading => _status == MedicinesStatus.loading;
  bool get hasError => _status == MedicinesStatus.error;
  bool get isEmpty => _medicines.isEmpty && _status == MedicinesStatus.loaded;

  double get adherenceRate => _adherenceRate;
  int get takenDosesToday => _takenDosesToday;
  int get totalDosesToday => _totalDosesToday;

  List<MedicineEntity> get filteredMedicines {
    List<MedicineEntity> result = List.from(_medicines);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((m) {
        return m.name.toLowerCase().contains(query) ||
            m.dosage.toLowerCase().contains(query) ||
            (m.instructions?.toLowerCase().contains(query) ?? false) ||
            (m.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_currentFilter.isActive != null) {
      result = result.where((m) => m.isActive == _currentFilter.isActive).toList();
    }

    if (_currentFilter.isCritical != null) {
      result = result.where((m) => m.isCritical == _currentFilter.isCritical).toList();
    }

    if (_currentFilter.dosageForm != null) {
      result = result.where((m) => m.dosageForm == _currentFilter.dosageForm).toList();
    }

    return result;
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> loadMedicines() async {
    if (_isDisposed) return;
    if (_status == MedicinesStatus.loading) return;

    _status = MedicinesStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    final result = await _repository.getMedicines(
      userId: _userId,
      filter: _currentFilter,
      sort: _currentSort,
    );

    if (_isDisposed) return;

    result.fold(
      (failure) {
        _status = MedicinesStatus.error;
        _errorMessage = failure.userMessage;
      },
      (medicines) {
        _medicines = medicines;
        _status = MedicinesStatus.loaded;
        _updateMedicinesCount();
      },
    );

    _safeNotifyListeners();

    if (!_isDisposed) {
      await _loadTodaySchedule();
      await _loadAdherenceRate();
    }
  }

  Future<void> refreshMedicines() async {
    if (_isDisposed) return;
    _errorMessage = null;

    final result = await _repository.getMedicines(
      userId: _userId,
      filter: _currentFilter,
      sort: _currentSort,
    );

    if (_isDisposed) return;

    result.fold(
      (failure) {
        _errorMessage = failure.userMessage;
      },
      (medicines) {
        _medicines = medicines;
        _updateMedicinesCount();
      },
    );

    _safeNotifyListeners();

    if (!_isDisposed) {
      await _loadTodaySchedule();
      await _loadAdherenceRate();
    }
  }

  Future<void> _loadTodaySchedule() async {
    if (_isDisposed) return;

    final result = await _repository.getMedicinesForDate(
      userId: _userId,
      date: DateTime.now(),
    );

    if (_isDisposed) return;

    result.fold(
      (failure) {
        debugPrint('Error loading today schedule: ${failure.userMessage}');
      },
      (medicines) {
        _todaySchedule = medicines;
        _totalDosesToday = medicines.fold<int>(0, (sum, m) => sum + m.times.length);
      },
    );

    _safeNotifyListeners();
  }

  Future<void> _loadAdherenceRate() async {
    if (_isDisposed) return;

    try {
      final result = await _repository.getOverallAdherence(userId: _userId);

      if (_isDisposed) return;

      result.fold(
        (failure) {
          debugPrint('Error loading adherence: ${failure.userMessage}');
          _adherenceRate = _calculateLocalAdherence();
        },
        (adherence) {
          _adherenceRate = adherence.adherenceRate;
          _takenDosesToday = adherence.takenDoses;
          _totalDosesToday = adherence.totalDoses;
        },
      );

      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Error calculating adherence: $e');
      _adherenceRate = _calculateLocalAdherence();
      _safeNotifyListeners();
    }
  }

  double _calculateLocalAdherence() {
    if (_totalDosesToday == 0) return 0.0;
    return (_takenDosesToday / _totalDosesToday) * 100;
  }

  void _updateMedicinesCount() {
    _medicinesCount = MedicinesCount(
      total: _medicines.length,
      active: _medicines.where((m) => m.isActive).length,
      inactive: _medicines.where((m) => !m.isActive).length,
      critical: _medicines.where((m) => m.isCritical).length,
    );
  }

  void setSearchQuery(String query) {
    if (_isDisposed) return;
    _searchQuery = query;
    _safeNotifyListeners();
  }

  void setFilter(MedicineFilter filter) {
    if (_isDisposed) return;
    _currentFilter = filter;
    _safeNotifyListeners();
    loadMedicines();
  }

  void setSort(MedicineSort sort) {
    if (_isDisposed) return;
    _currentSort = sort;
    _safeNotifyListeners();
    loadMedicines();
  }

  void clearFilters() {
    if (_isDisposed) return;
    _currentFilter = const MedicineFilter();
    _searchQuery = '';
    _safeNotifyListeners();
    loadMedicines();
  }

  Future<bool> toggleMedicineStatus(String medicineId, bool isActive) async {
    if (_isDisposed) return false;

    // ─── OFFLINE GUARD ─────────────────────────────────────
    if (ConnectivityService.instance.isOffline) {
      OfflineBanner.showWriteBlocked();
      return false;
    }

    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index == -1) return false;

    final oldMedicine = _medicines[index];
    _medicines[index] = oldMedicine.copyWith(isActive: isActive);
    _updateMedicinesCount();
    _safeNotifyListeners();

    final result = await _repository.toggleMedicineStatus(
      medicineId: medicineId,
      isActive: isActive,
    );

    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        _medicines[index] = oldMedicine;
        _updateMedicinesCount();
        _errorMessage = failure.userMessage;
        _safeNotifyListeners();
        return false;
      },
      (updatedMedicine) async {
        _medicines[index] = updatedMedicine;
        _updateMedicinesCount();
        await _handleStatusChange(updatedMedicine, isActive);
        _safeNotifyListeners();
        return true;
      },
    );
  }

  Future<void> _handleStatusChange(MedicineEntity medicine, bool isActive) async {
    if (_isDisposed) return;
    
    if (isActive) {
      debugPrint('📅 Medicine reactivated: ${medicine.name} - Scheduling notifications');
      await _scheduleNotificationsForMedicine(medicine);
    } else {
      debugPrint('🚫 Medicine deactivated: ${medicine.name} - Cancelling notifications');
      await _cancelNotificationsForMedicine(medicine.id, medicine.times.length);
    }
  }

  Future<bool> deleteMedicine(String medicineId) async {
    debugPrint('🗑️ deleteMedicine called with ID: $medicineId');
    
    if (_isDisposed) {
      debugPrint('🗑️ Provider is disposed, returning false');
      return false;
    }

    // ─── OFFLINE GUARD ─────────────────────────────────────
    if (ConnectivityService.instance.isOffline) {
      OfflineBanner.showWriteBlocked();
      return false;
    }

    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index == -1) {
      debugPrint('🗑️ Medicine not found in list, returning false');
      return false;
    }

    final deletedMedicine = _medicines[index];
    debugPrint('🗑️ Found medicine: ${deletedMedicine.name} at index $index');
    
    _medicines.removeAt(index);
    _updateMedicinesCount();
    _safeNotifyListeners();
    debugPrint('🗑️ Removed from local list, calling repository...');

    final result = await _repository.deleteMedicine(medicineId: medicineId);
    debugPrint('🗑️ Repository result received');

    if (_isDisposed) {
      debugPrint('🗑️ Provider disposed after repository call');
      return false;
    }

    return result.fold(
      (failure) {
        debugPrint('🗑️ DELETE FAILED: ${failure.userMessage}');
        _medicines.insert(index, deletedMedicine);
        _updateMedicinesCount();
        _errorMessage = failure.userMessage;
        _safeNotifyListeners();
        return false;
      },
      (_) async {
        debugPrint('🗑️ DELETE SUCCESS: ${deletedMedicine.name}');
        _todaySchedule.removeWhere((m) => m.id == medicineId);
        debugPrint('🗑️ Cancelling notifications...');
        await _cancelNotificationsForMedicine(medicineId, deletedMedicine.times.length);
        _safeNotifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteMedicines(List<String> medicineIds) async {
    if (_isDisposed) return false;

    final deletedMedicines = <int, MedicineEntity>{};

    for (final id in medicineIds) {
      final index = _medicines.indexWhere((m) => m.id == id);
      if (index != -1) {
        deletedMedicines[index] = _medicines[index];
      }
    }

    _medicines.removeWhere((m) => medicineIds.contains(m.id));
    _updateMedicinesCount();
    _safeNotifyListeners();

    final result = await _repository.deleteMedicines(medicineIds: medicineIds);

    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        deletedMedicines.forEach((index, medicine) {
          _medicines.insert(index, medicine);
        });
        _updateMedicinesCount();
        _errorMessage = failure.userMessage;
        _safeNotifyListeners();
        return false;
      },
      (_) async {
        _todaySchedule.removeWhere((m) => medicineIds.contains(m.id));
        debugPrint('🗑️ Bulk delete: Cancelling notifications for ${medicineIds.length} medicines');
        for (final entry in deletedMedicines.entries) {
          await _cancelNotificationsForMedicine(entry.value.id, entry.value.times.length);
        }
        _safeNotifyListeners();
        return true;
      },
    );
  }

  Future<void> _scheduleNotificationsForMedicine(MedicineEntity medicine) async {
    if (_isDisposed) return;
    
    try {
      final schedulable = SchedulableMedicine(
        id: medicine.id,
        name: medicine.name,
        dosage: medicine.dosage,
        times: medicine.times,
        isActive: medicine.isActive,
        isCritical: medicine.isCritical,
        instructions: medicine.instructions,
        startDate: medicine.startDate,
        endDate: medicine.endDate,
      );

      final result = await _notificationScheduler.scheduleForMedicine(schedulable);

      if (result.success) {
        debugPrint('✅ Scheduled ${result.scheduledCount} notifications for ${medicine.name}');
      } else {
        debugPrint('⚠️ Failed to schedule some notifications: ${result.errors}');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling notifications: $e');
    }
  }

  Future<void> _cancelNotificationsForMedicine(String medicineId, int timesCount) async {
    if (_isDisposed) return;
    
    try {
      await _notificationScheduler.cancelForMedicine(medicineId, timesCount);
      debugPrint('✅ Cancelled notifications for medicine: $medicineId');
    } catch (e) {
      debugPrint('❌ Error cancelling notifications: $e');
    }
  }

  Future<void> rescheduleAllNotifications() async {
    if (_isDisposed) return;
    
    debugPrint('🔄 Rescheduling all notifications for user: $_userId');

    try {
      final result = await _notificationScheduler.rescheduleAllMedicines(_userId);

      if (result.success) {
        debugPrint('✅ Rescheduled ${result.scheduledCount} notifications');
      } else {
        debugPrint('⚠️ Some notifications failed: ${result.errors}');
      }
    } catch (e) {
      debugPrint('❌ Error rescheduling notifications: $e');
    }
  }

  MedicineEntity? getMedicineById(String id) {
    try {
      return _medicines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<MedicineEntity> getMedicinesNeedingRefill() {
    return _medicines.where((m) => m.needsRefill).toList();
  }

  List<MedicineEntity> getCriticalMedicines() {
    return _medicines.where((m) => m.isCritical && m.isActive).toList();
  }

  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
