import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/health/health_exports.dart';
import '../../../models/user_model.dart';
import '../utils/health_rate_limiter.dart';
import '../utils/health_readings_utils.dart';

enum HealthReadingsState { initial, loading, loaded, error, empty }

class HealthReadingsController extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final HealthRateLimiter _rateLimiter;

  static const int _queryLimit = 100;
  static const double _defaultHeight = 170.0;

  HealthReadingsController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    HealthRateLimiter? rateLimiter,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _rateLimiter = rateLimiter ?? HealthRateLimiter.instance;

  HealthReadingsState _state = HealthReadingsState.initial;
  String? _errorMessage;

  ReadingType _selectedType = ReadingType.bloodPressure;
  TimePeriod _selectedPeriod = TimePeriod.week;
  String _searchQuery = '';
  bool _isSearching = false;

  List<HealthReading> _readings = [];
  List<HealthReading> _filteredReadings = [];

  // ═══════════════════════════════════════════════════════════════
  // 👤 USER DATA - للحصول على الطول لحساب BMI
  // ═══════════════════════════════════════════════════════════════
  double _userHeight = _defaultHeight;
  bool _userDataLoaded = false;

  StreamSubscription<QuerySnapshot>? _readingsSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  // ═══════════════════════════════════════════════════════════════
  // 📊 GETTERS
  // ═══════════════════════════════════════════════════════════════
  HealthReadingsState get state => _state;
  String? get errorMessage => _errorMessage;
  ReadingType get selectedType => _selectedType;
  TimePeriod get selectedPeriod => _selectedPeriod;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  List<HealthReading> get readings => _filteredReadings;

  bool get isLoading => _state == HealthReadingsState.loading;
  bool get hasError => _state == HealthReadingsState.error;
  bool get isEmpty => _state == HealthReadingsState.empty;
  bool get isLoaded => _state == HealthReadingsState.loaded;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String get _userId => currentUser?.uid ?? '';
  String get _rateLimitKey => _userId.isEmpty ? 'anonymous' : _userId;

  /// طول المستخدم بالسنتيمتر - للاستخدام في حساب BMI
  double get userHeight => _userHeight;

  // ═══════════════════════════════════════════════════════════════
  // 🚀 INITIALIZATION
  // ═══════════════════════════════════════════════════════════════
  void init() {
    if (!isAuthenticated) {
      _setState(HealthReadingsState.error);
      _errorMessage = 'يرجى تسجيل الدخول';
      return;
    }
    _loadUserData();
    _subscribeToReadings();
  }

  /// تحميل بيانات المستخدم (الطول)
  void _loadUserData() {
    if (_userDataLoaded || !isAuthenticated) return;

    _userSubscription = _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final height = (data['height'] as num?)?.toDouble();
          if (height != null && height > 0) {
            _userHeight = height;
            _userDataLoaded = true;
            notifyListeners();
          }
        }
      },
      onError: (error) {
        debugPrint('Error loading user data: $error');
        // استخدام القيمة الافتراضية
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 TYPE & PERIOD SELECTION
  // ═══════════════════════════════════════════════════════════════
  void setSelectedType(ReadingType type) {
    if (_selectedType != type) {
      _selectedType = type;
      _subscribeToReadings();
      notifyListeners();
    }
  }

  void setSelectedPeriod(TimePeriod period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      _subscribeToReadings();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
      _applyFilters();
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // 📡 FIRESTORE SUBSCRIPTION
  // ═══════════════════════════════════════════════════════════════
  void _subscribeToReadings() {
    _readingsSubscription?.cancel();

    if (!isAuthenticated) return;

    _setState(HealthReadingsState.loading);

    Query query = _firestore
        .collection('health_readings')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: _selectedType.id);

    final startDate = _selectedPeriod.startDate;
    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    query = query.orderBy('timestamp', descending: true).limit(_queryLimit);

    _readingsSubscription = query.snapshots().listen(
      _onReadingsUpdate,
      onError: _onReadingsError,
    );
  }

  void _onReadingsUpdate(QuerySnapshot snapshot) {
    _readings = snapshot.docs.map((doc) {
      return HealthReading.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    _applyFilters();

    if (_filteredReadings.isEmpty) {
      _setState(HealthReadingsState.empty);
    } else {
      _setState(HealthReadingsState.loaded);
    }
  }

  void _onReadingsError(Object error) {
    debugPrint('Firestore Error: $error');
    _setState(HealthReadingsState.error);
    _errorMessage = 'حدث خطأ في تحميل البيانات';
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredReadings = List.from(_readings);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredReadings = _readings.where((reading) {
        return reading.value.toString().contains(query) ||
            reading.notes?.toLowerCase().contains(query) == true ||
            reading.displayValue.contains(query);
      }).toList();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 STATISTICS
  // ═══════════════════════════════════════════════════════════════
  HealthStatistics getStatistics() {
    return HealthStatisticsCalculator.calculate(_filteredReadings);
  }

  BloodPressureStatistics getBloodPressureStatistics() {
    return HealthStatisticsCalculator.calculateBloodPressure(_filteredReadings);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑️ DELETE OPERATIONS
  // ═══════════════════════════════════════════════════════════════
  bool canDeleteReading() {
    final key = HealthRateLimitConfig.createKey('delete', _rateLimitKey);
    return !_rateLimiter.isBlocked(
      key,
      maxActions: HealthRateLimitConfig.maxDeleteActions,
      window: HealthRateLimitConfig.deleteWindow,
    );
  }

  int getRemainingDeleteActions() {
    final key = HealthRateLimitConfig.createKey('delete', _rateLimitKey);
    return _rateLimiter.getRemainingActions(
      key,
      maxActions: HealthRateLimitConfig.maxDeleteActions,
      window: HealthRateLimitConfig.deleteWindow,
    );
  }

  Future<bool> deleteReading(HealthReading reading) async {
    final key = HealthRateLimitConfig.createKey('delete', _rateLimitKey);

    if (!_rateLimiter.canPerformAction(
      key,
      maxActions: HealthRateLimitConfig.maxDeleteActions,
      window: HealthRateLimitConfig.deleteWindow,
    )) {
      _errorMessage = 'لقد تجاوزت الحد الأقصى للحذف';
      notifyListeners();
      return false;
    }

    try {
      await _firestore.collection('health_readings').doc(reading.id).delete();
      return true;
    } catch (e) {
      debugPrint('Delete Error: $e');
      _errorMessage = 'حدث خطأ أثناء الحذف';
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 REFRESH & STATE
  // ═══════════════════════════════════════════════════════════════
  void refresh() {
    _subscribeToReadings();
  }

  void _setState(HealthReadingsState newState) {
    _state = newState;
    if (newState != HealthReadingsState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _readingsSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
