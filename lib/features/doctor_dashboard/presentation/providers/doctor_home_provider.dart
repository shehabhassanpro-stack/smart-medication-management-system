import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import 'doctor_patients_provider.dart';

/// H2 Fix: DoctorHomeProvider no longer subscribes to Firestore directly.
/// It delegates patient data to DoctorPatientsProvider (single source of truth),
/// eliminating the duplicate Firestore stream subscription.
class DoctorHomeProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final DoctorPatientsProvider _patientsProvider;

  final int _unreadNotificationsCount = 0;
  
  VoidCallback? _patientsListener;

  DoctorHomeProvider(this._authProvider, this._patientsProvider) {
    // Listen to the shared patients provider for changes
    _patientsListener = () => notifyListeners();
    _patientsProvider.addListener(_patientsListener!);
  }

  bool get isLoading => _patientsProvider.isLoading;
  String? get errorMessage => _patientsProvider.errorMessage;
  bool get hasError => _patientsProvider.hasError;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  UserModel? get user => _authProvider.userModel;
  
  String get doctorName {
    if (user?.gender == 'female') {
      return 'دكتورة ${user?.name ?? 'طبيبة'}';
    } else if (user?.gender == 'male') {
      return 'دكتور ${user?.name ?? 'طبيب'}';
    }
    return 'دكتور/ة ${user?.name ?? 'طبيب'}';
  }
  
  String? get doctorAvatarUrl => user?.photoUrl;
  
  int get activePatientsCount => _patientsProvider.totalPatientsCount;
  int get criticalAlertsCount => 0; // Default until implemented
  
  /// Exposes the first 5 patients from the shared provider as "recent".
  List<Map<String, dynamic>> get recentPatients {
    final all = _patientsProvider.filteredPatients;
    return all.take(5).toList();
  }

  Future<void> refresh() async {
    await _patientsProvider.refresh();
  }
  
  @override
  void dispose() {
    if (_patientsListener != null) {
      _patientsProvider.removeListener(_patientsListener!);
    }
    super.dispose();
  }
}
