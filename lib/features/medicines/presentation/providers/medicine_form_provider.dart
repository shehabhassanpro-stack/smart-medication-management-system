import 'package:flutter/foundation.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../../../../core/services/notification_scheduler.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/offline_banner.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 MEDICINE FORM PROVIDER - With Notification Scheduling
// ═══════════════════════════════════════════════════════════════════════════════
//
// Updated to integrate with NotificationScheduler for automatic
// scheduling of medicine reminders when a medicine is saved.
//
// Changes from original:
// 1. Added NotificationScheduler integration
// 2. saveMedicine() now schedules notifications after successful save
// 3. Added _scheduleNotifications() private method
// 4. Returns saved MedicineEntity for caller use
//
// ═══════════════════════════════════════════════════════════════════════════════

class MedicineFormProvider extends ChangeNotifier {
  final MedicinesRepository _repository;
  final String _userId;

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION SCHEDULER INTEGRATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  final NotificationScheduler _notificationScheduler = NotificationScheduler.instance;

  MedicineFormProvider({
    required MedicinesRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  String _name = '';
  String _dosage = '';
  DosageForm _dosageForm = DosageForm.tablet;
  List<String> _times = [];
  Frequency _frequency = Frequency.onceDaily;
  bool _isActive = true;
  bool _isCritical = false;
  String? _instructions;
  String? _notes;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _stockCount;
  int? _refillReminder;

  bool _isSaving = false;
  String? _errorMessage;
  
  /// Last saved medicine (useful for caller to access after save)
  MedicineEntity? _lastSavedMedicine;

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  String get name => _name;
  String get dosage => _dosage;
  DosageForm get dosageForm => _dosageForm;
  List<String> get times => List.unmodifiable(_times);
  Frequency get frequency => _frequency;
  bool get isActive => _isActive;
  bool get isCritical => _isCritical;
  String? get instructions => _instructions;
  String? get notes => _notes;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int? get stockCount => _stockCount;
  int? get refillReminder => _refillReminder;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  
  /// Get the last saved medicine entity
  MedicineEntity? get lastSavedMedicine => _lastSavedMedicine;

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isValid {
    if (_name.trim().isEmpty) return false;
    if (_name.trim().length < 2) return false;
    if (_dosage.trim().isEmpty) return false;
    if (_times.isEmpty) return false;
    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  void initWithMedicine(MedicineEntity medicine) {
    _name = medicine.name;
    _dosage = medicine.dosage;
    _dosageForm = medicine.dosageForm;
    _times = List.from(medicine.times);
    _frequency = medicine.frequency;
    _isActive = medicine.isActive;
    _isCritical = medicine.isCritical;
    _instructions = medicine.instructions;
    _notes = medicine.notes;
    _startDate = medicine.startDate;
    _endDate = medicine.endDate;
    _stockCount = medicine.stockCount;
    _refillReminder = medicine.refillReminder;
    _errorMessage = null;
    _lastSavedMedicine = null;
    notifyListeners();
  }

  void reset() {
    _name = '';
    _dosage = '';
    _dosageForm = DosageForm.tablet;
    _times = [];
    _frequency = Frequency.onceDaily;
    _isActive = true;
    _isCritical = false;
    _instructions = null;
    _notes = null;
    _startDate = null;
    _endDate = null;
    _stockCount = null;
    _refillReminder = null;
    _isSaving = false;
    _errorMessage = null;
    _lastSavedMedicine = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setDosage(String value) {
    _dosage = value;
    notifyListeners();
  }

  void setDosageForm(DosageForm value) {
    _dosageForm = value;
    notifyListeners();
  }

  void setFrequency(Frequency value) {
    _frequency = value;
    _updateTimesForFrequency();
    notifyListeners();
  }

  void _updateTimesForFrequency() {
    switch (_frequency) {
      case Frequency.onceDaily:
        if (_times.isEmpty) _times = ['08:00'];
        break;
      case Frequency.twiceDaily:
        if (_times.length < 2) _times = ['08:00', '20:00'];
        break;
      case Frequency.thriceDaily:
        if (_times.length < 3) _times = ['08:00', '14:00', '20:00'];
        break;
      case Frequency.fourTimesDaily:
        if (_times.length < 4) _times = ['08:00', '12:00', '16:00', '20:00'];
        break;
      default:
        break;
    }
  }

  void addTime(String time) {
    if (!_times.contains(time)) {
      _times.add(time);
      _times.sort();
      notifyListeners();
    }
  }

  void removeTime(String time) {
    _times.remove(time);
    notifyListeners();
  }

  void setTimes(List<String> times) {
    _times = List.from(times);
    notifyListeners();
  }

  void setIsActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void setIsCritical(bool value) {
    _isCritical = value;
    notifyListeners();
  }

  void setInstructions(String? value) {
    _instructions = value?.isNotEmpty == true ? value : null;
    notifyListeners();
  }

  void setNotes(String? value) {
    _notes = value?.isNotEmpty == true ? value : null;
    notifyListeners();
  }

  void setStartDate(DateTime? value) {
    _startDate = value;
    notifyListeners();
  }

  void setEndDate(DateTime? value) {
    _endDate = value;
    notifyListeners();
  }

  void setStock(int? stock, int? refillReminder) {
    _stockCount = stock;
    _refillReminder = refillReminder;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE MEDICINE - WITH NOTIFICATION SCHEDULING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Save medicine to repository and schedule notifications
  /// 
  /// Returns true if save was successful.
  /// After successful save, [lastSavedMedicine] contains the saved entity.
  /// 
  /// Flow:
  /// 1. Validate form data
  /// 2. Create MedicineEntity
  /// 3. Save to Firestore via repository
  /// 4. Schedule notifications (if active)
  /// 5. Return result
  Future<bool> saveMedicine({String? existingId}) async {
    // ─── OFFLINE GUARD ─────────────────────────────────────────
    if (ConnectivityService.instance.isOffline) {
      _errorMessage = 'وضع القراءة فقط — اتصل بالإنترنت لحفظ البيانات';
      notifyListeners();
      OfflineBanner.showWriteBlocked();
      return false;
    }

    if (!isValid) {
      _errorMessage = _getValidationError();
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _lastSavedMedicine = null;
    notifyListeners();

    final now = DateTime.now();

    final medicine = MedicineEntity(
      id: existingId ?? now.millisecondsSinceEpoch.toString(),
      userId: _userId,
      name: _name.trim(),
      dosage: _dosage.trim(),
      dosageForm: _dosageForm,
      times: _times,
      frequency: _frequency,
      isActive: _isActive,
      isCritical: _isCritical,
      instructions: _instructions?.trim(),
      notes: _notes?.trim(),
      startDate: _startDate,
      endDate: _endDate,
      stockCount: _stockCount,
      refillReminder: _refillReminder,
      createdAt: now,
      updatedAt: now,
    );

    // Save to repository
    final result = existingId != null
        ? await _repository.updateMedicine(medicine: medicine)
        : await _repository.addMedicine(medicine: medicine);

    _isSaving = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.userMessage;
        notifyListeners();
        return false;
      },
      (savedMedicine) async {
        _lastSavedMedicine = savedMedicine;
        
        // ═══════════════════════════════════════════════════════════════════
        // 🔔 SCHEDULE NOTIFICATIONS FOR THIS MEDICINE
        // ═══════════════════════════════════════════════════════════════════
        await _scheduleNotifications(savedMedicine);
        
        notifyListeners();
        return true;
      },
    );
  }

  /// Schedule notifications for the saved medicine
  Future<void> _scheduleNotifications(MedicineEntity medicine) async {
    debugPrint('📅 MedicineFormProvider: Scheduling notifications for ${medicine.name}');

    // Convert MedicineEntity to SchedulableMedicine
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

    // Schedule using NotificationScheduler
    final scheduleResult = await _notificationScheduler.scheduleForMedicine(schedulable);

    if (scheduleResult.success) {
      debugPrint('✅ Scheduled ${scheduleResult.scheduledCount} notifications');
    } else {
      debugPrint('⚠️ Some notifications failed: ${scheduleResult.errors}');
      // Note: We don't fail the save operation if notifications fail
      // The medicine is saved, notifications are best-effort
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION ERRORS
  // ═══════════════════════════════════════════════════════════════════════════

  String? _getValidationError() {
    if (_name.trim().isEmpty) {
      return 'يرجى إدخال اسم الدواء';
    }
    if (_name.trim().length < 2) {
      return 'اسم الدواء يجب أن يكون حرفين على الأقل';
    }
    if (_dosage.trim().isEmpty) {
      return 'يرجى إدخال الجرعة';
    }
    if (_times.isEmpty) {
      return 'يرجى إضافة وقت واحد على الأقل';
    }
    if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
      return 'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية';
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert current form state to MedicineEntity
  /// Returns null if form is invalid
  MedicineEntity? toEntity({String? existingId}) {
    if (!isValid) return null;

    final now = DateTime.now();

    return MedicineEntity(
      id: existingId ?? now.millisecondsSinceEpoch.toString(),
      userId: _userId,
      name: _name.trim(),
      dosage: _dosage.trim(),
      dosageForm: _dosageForm,
      times: _times,
      frequency: _frequency,
      isActive: _isActive,
      isCritical: _isCritical,
      instructions: _instructions?.trim(),
      notes: _notes?.trim(),
      startDate: _startDate,
      endDate: _endDate,
      stockCount: _stockCount,
      refillReminder: _refillReminder,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Convert MedicineEntity to SchedulableMedicine
  /// Useful for external scheduling needs
  static SchedulableMedicine toSchedulable(MedicineEntity medicine) {
    return SchedulableMedicine(
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
  }
}
