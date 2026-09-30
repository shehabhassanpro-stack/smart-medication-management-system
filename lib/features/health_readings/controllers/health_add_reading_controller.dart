import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/health/health_exports.dart';
import '../utils/health_rate_limiter.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/widgets/offline_banner.dart';

enum HealthAddReadingState { initial, loading, success, error }

class HealthAddReadingController extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final HealthRateLimiter _rateLimiter;

  HealthAddReadingController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    HealthRateLimiter? rateLimiter,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _rateLimiter = rateLimiter ?? HealthRateLimiter.instance;

  HealthAddReadingState _state = HealthAddReadingState.initial;
  String? _errorMessage;
  HealthReading? _savedReading;
  HealthReading? _previewReading;

  ReadingType? _selectedType;
  MeasurementTime? _selectedMeasurementTime;

  int? _systolic;
  int? _diastolic;
  double? _value;
  String? _notes;

  double? _userHeight;
  bool _isLoadingUserData = false;

  HealthAddReadingState get state => _state;
  String? get errorMessage => _errorMessage;
  HealthReading? get savedReading => _savedReading;
  HealthReading? get previewReading => _previewReading;
  ReadingType? get selectedType => _selectedType;
  MeasurementTime? get selectedMeasurementTime => _selectedMeasurementTime;
  bool get isLoading => _state == HealthAddReadingState.loading;
  bool get hasError => _state == HealthAddReadingState.error;
  bool get isSuccess => _state == HealthAddReadingState.success;

  double? get userHeight => _userHeight;
  bool get isLoadingUserData => _isLoadingUserData;
  bool get hasUserHeight => _userHeight != null && _userHeight! > 0;

  User? get currentUser => _auth.currentUser;
  String get _rateLimitKey => currentUser?.uid ?? 'anonymous';

  Future<void> loadUserHeight() async {
    if (currentUser == null) return;
    
    _isLoadingUserData = true;
    notifyListeners();

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        _userHeight = (data?['height'] as num?)?.toDouble();
        debugPrint('User height loaded: $_userHeight cm');
      }
    } catch (e) {
      debugPrint('Error loading user height: $e');
    } finally {
      _isLoadingUserData = false;
      notifyListeners();
    }
  }

  void setUserHeight(double? height) {
    _userHeight = height;
    _updatePreview();
    notifyListeners();
  }

  void setSelectedType(ReadingType? type) {
    if (_selectedType != type) {
      _selectedType = type;
      _clearValues();
      
      if (type == ReadingType.weight && _userHeight == null) {
        loadUserHeight();
      }
      
      notifyListeners();
    }
  }

  void setMeasurementTime(MeasurementTime? time) {
    _selectedMeasurementTime = time;
    _updatePreview();
    notifyListeners();
  }

  void setSystolic(int? value) {
    _systolic = value;
    _updatePreview();
    notifyListeners();
  }

  void setDiastolic(int? value) {
    _diastolic = value;
    _updatePreview();
    notifyListeners();
  }

  void setValue(double? value) {
    _value = value;
    _updatePreview();
    notifyListeners();
  }

  void setNotes(String? notes) {
    _notes = InputSanitizer.sanitizeNotes(notes);
    _updatePreview();
    notifyListeners();
  }

  void setBloodPressure(int? systolic, int? diastolic) {
    _systolic = systolic;
    _diastolic = diastolic;
    _updatePreview();
    notifyListeners();
  }

  ValidationResult validate() {
    if (_selectedType == null) {
      return const ValidationFailure(
        message: 'يرجى اختيار نوع القراءة',
        errorType: ValidationErrorType.required,
      );
    }

    if (_selectedType == ReadingType.bloodPressure) {
      return HealthReadingValidator.validateBloodPressure(
        systolic: _systolic,
        diastolic: _diastolic,
      );
    }

    return HealthReadingValidator.validate(
      type: _selectedType!,
      value: _value,
    );
  }

  bool canSave() {
    final key = HealthRateLimitConfig.createKey('save', _rateLimitKey);
    return _rateLimiter.canPerformAction(
      key,
      maxActions: HealthRateLimitConfig.maxSaveActions,
      window: HealthRateLimitConfig.saveWindow,
    );
  }

  Duration? getWaitTime() {
    final key = HealthRateLimitConfig.createKey('save', _rateLimitKey);
    return _rateLimiter.getWaitTime(
      key,
      maxActions: HealthRateLimitConfig.maxSaveActions,
      window: HealthRateLimitConfig.saveWindow,
    );
  }

  Future<bool> saveReading() async {
    // ─── OFFLINE GUARD ─────────────────────────────────────────
    if (ConnectivityService.instance.isOffline) {
      _setError('وضع القراءة فقط — اتصل بالإنترنت لحفظ البيانات');
      OfflineBanner.showWriteBlocked();
      return false;
    }

    if (currentUser == null) {
      _setError('يرجى تسجيل الدخول');
      return false;
    }

    if (!canSave()) {
      final waitTime = getWaitTime();
      _setError('لقد تجاوزت الحد الأقصى. انتظر ${waitTime?.inMinutes ?? 1} دقائق');
      return false;
    }

    final validationResult = validate();
    if (validationResult is ValidationFailure) {
      _setError(validationResult.message);
      return false;
    }

    _setState(HealthAddReadingState.loading);

    try {
      final reading = _createReading();

      final docRef = await _firestore
          .collection('health_readings')
          .add(reading.toMap());

      _savedReading = reading.copyWith(id: docRef.id);
      _setState(HealthAddReadingState.success);
      return true;
    } catch (e) {
      debugPrint('Error saving reading: $e');
      _setError('حدث خطأ أثناء حفظ القراءة');
      return false;
    }
  }

  HealthReading _createReading() {
    final now = DateTime.now();
    double value = 0;

    if (_selectedType == ReadingType.bloodPressure) {
      value = (_systolic ?? 0).toDouble();
    } else {
      value = _value ?? 0;
    }

    return HealthReading(
      id: '',
      userId: currentUser!.uid,
      type: _selectedType!,
      value: value,
      systolic: _systolic,
      diastolic: _diastolic,
      timestamp: now,
      notes: _notes,
      measurementTime: _selectedMeasurementTime,
      createdAt: now,
      updatedAt: null,
    );
  }

  void _updatePreview() {
    if (currentUser == null || _selectedType == null) {
      _previewReading = null;
      return;
    }

    bool hasValidData = false;

    if (_selectedType == ReadingType.bloodPressure) {
      hasValidData = _systolic != null && _diastolic != null &&
          _systolic! > 0 && _diastolic! > 0;
    } else {
      hasValidData = _value != null && _value! > 0;
    }

    if (hasValidData) {
      _previewReading = _createReading();
    } else {
      _previewReading = null;
    }
  }

  void _setState(HealthAddReadingState newState) {
    _state = newState;
    if (newState != HealthAddReadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _state = HealthAddReadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearValues() {
    _systolic = null;
    _diastolic = null;
    _value = null;
    _notes = null;
    _selectedMeasurementTime = null;
    _previewReading = null;
  }

  void reset() {
    _state = HealthAddReadingState.initial;
    _errorMessage = null;
    _savedReading = null;
    _selectedType = null;
    _clearValues();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == HealthAddReadingState.error) {
      _state = HealthAddReadingState.initial;
    }
    notifyListeners();
  }

  void prepareForNewReading() {
    _state = HealthAddReadingState.initial;
    _errorMessage = null;
    _savedReading = null;
    _clearValues();
    notifyListeners();
  }
}
