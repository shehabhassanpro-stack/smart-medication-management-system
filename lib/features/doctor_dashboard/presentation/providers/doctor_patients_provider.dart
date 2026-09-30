import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/services/doctor_patient_service.dart';

class DoctorPatientsProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final DoctorPatientService _doctorPatientService;

  bool _isLoading = true;
  String? _errorMessage;
  
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  
  String _searchQuery = '';
  Timer? _debounceTimer;
  StreamSubscription? _patientsSub;

  DoctorPatientsProvider(this._authProvider, {DoctorPatientService? doctorPatientService})
      : _doctorPatientService = doctorPatientService ?? DoctorPatientService() {
    _init();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  List<Map<String, dynamic>> get filteredPatients => _filteredPatients;
  
  UserModel? get user => _authProvider.userModel;
  
  int get totalPatientsCount => _allPatients.length;
  
  String get searchQuery => _searchQuery;

  Future<void> _init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (user != null) {
        _patientsSub?.cancel();
        _patientsSub = _doctorPatientService.getDoctorPatients(user!.uid).listen(
          (patients) {
            _allPatients = patients.map((p) => {
              ...p,
              'lastVisit': 'مؤخراً',
              'status': 'مستقر',
              'adherence': -1, // H3: Dynamic calculation pending real intake logs
            }).toList();
            
            // Re-apply filter if there is a search query
            _applySearchFilter();
            
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = 'حدث خطأ أثناء تحميل بيانات المرضى';
            _isLoading = false;
            notifyListeners();
          }
        );
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    
    _searchQuery = query;
    notifyListeners(); // Update UI immediately for typed text, but delay the heavy filtering
    
    // Debounce the actual filtering (Wait 300ms after user stops typing)
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applySearchFilter();
      notifyListeners();
    });
  }
  
  void _applySearchFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredPatients = List.from(_allPatients);
    } else {
      final query = _searchQuery.trim().toLowerCase();
      _filteredPatients = _allPatients.where((patient) {
        final name = (patient['name'] ?? '').toString().toLowerCase();
        final phone = (patient['phone'] ?? '').toString().toLowerCase();
        final patientId = (patient['patientId'] ?? '').toString().toLowerCase();
        
        return name.contains(query) || phone.contains(query) || patientId.contains(query);
      }).toList();
    }
  }

  /// Optimistically unlinks a patient, hiding from UI instantly. 
  /// Rolls back if the backend fails.
  Future<(bool, String)> unlinkPatient(String patientId) async {
    if (user == null) return (false, 'يجب تسجيل الدخول أولاً');
    
    // 1. Snapshot the current state for rollback
    final previousAll = List<Map<String, dynamic>>.from(_allPatients);
    final previousFiltered = List<Map<String, dynamic>>.from(_filteredPatients);
    
    // 2. Optimistic UI Update (Fast)
    _allPatients.removeWhere((p) => p['patientId'] == patientId);
    _filteredPatients.removeWhere((p) => p['patientId'] == patientId);
    notifyListeners();
    
    // 3. Backend Call
    final (success, message) = await _doctorPatientService.unlinkPatient(
      doctorId: user!.uid,
      patientId: patientId,
    );
    
    // 4. Rollback if failed
    if (!success) {
      // Restore previous state
      _allPatients = previousAll;
      _filteredPatients = previousFiltered;
      notifyListeners();
    }
    
    return (success, message);
  }

  Future<void> refresh() async {
    await _init();
  }
  
  @override
  void dispose() {
    _patientsSub?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
