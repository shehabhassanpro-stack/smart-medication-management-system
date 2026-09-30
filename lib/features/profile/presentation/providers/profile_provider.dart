import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/user_model.dart';
import '../../../../core/services/credentials_manager.dart';

enum ProfileState { initial, loading, loaded, error, updating, success }

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  ProfileProvider({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  ProfileState _state = ProfileState.initial;
  String? _errorMessage;
  UserModel? _user;
  bool _isDisposed = false;
  Timer? _successTimer;
  
  int _readingsCount = 0;
  int _medicinesCount = 0;
  int _consecutiveDays = 0;
  DateTime? _memberSince;

  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  
  bool get isLoading => _state == ProfileState.loading;
  bool get isUpdating => _state == ProfileState.updating;
  bool get hasError => _state == ProfileState.error;
  bool get isLoaded => _state == ProfileState.loaded;

  String get userName {
    if (_user?.role == UserRole.doctor) {
      if (_user?.gender == 'female') {
        return 'دكتورة ${_user?.name ?? 'طبيبة'}';
      } else if (_user?.gender == 'male') {
        return 'دكتور ${_user?.name ?? 'طبيب'}';
      }
      return 'دكتور/ة ${_user?.name ?? 'طبيب'}';
    }
    return _user?.name ?? 'مستخدم';
  }
  String get userEmail => _user?.email ?? '';
  String get userPhone => _user?.phone ?? '';
  String? get userId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;
  
  String get userInitial {
    final name = _user?.name ?? '';
    if (name.isEmpty) return '؟';
    return name[0].toUpperCase();
  }
  
  DateTime? get dateOfBirth => _user?.dateOfBirth;
  int? get age => _user?.age;
  
  String? get gender => _user?.gender;
  String? get genderArabic => _user?.genderArabic;
  String? get bloodType => _user?.bloodType;
  double? get height => _user?.height;
  double? get weight => _user?.weight;
  String? get address => _user?.address;
  String? get nationalId => _user?.nationalId;
  List<String> get chronicDiseases => _user?.chronicDiseases ?? [];
  List<String> get allergies => _user?.allergies ?? [];
  String? get emergencyContact => _user?.emergencyContact;
  String? get emergencyPhone => _user?.emergencyPhone;
  
  int get readingsCount => _readingsCount;
  int get medicinesCount => _medicinesCount;
  int get consecutiveDays => _consecutiveDays;
  DateTime? get memberSince => _memberSince;
  int get profileCompleteness => _user?.profileCompleteness ?? 0;
  
  String get memberSinceFormatted {
    if (_memberSince == null) return 'غير معروف';
    final now = DateTime.now();
    final difference = now.difference(_memberSince!);
    
    if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months شهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years سنة';
    }
  }

  Future<void> init() async {
    if (_isDisposed) return;
    
    if (!isAuthenticated) {
      _setState(ProfileState.error);
      _errorMessage = 'يرجى تسجيل الدخول';
      return;
    }
    
    await loadProfile();
    await loadStatistics();
  }

  Future<void> loadProfile() async {
    if (_isDisposed || !isAuthenticated) return;
    
    _setState(ProfileState.loading);
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (_isDisposed) return;
      
      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!, doc.id);
        _memberSince = _user?.createdAt;
        _setState(ProfileState.loaded);
        _log('Profile loaded: ${_user?.name}');
      } else {
        _setState(ProfileState.error);
        _errorMessage = 'لم يتم العثور على بيانات المستخدم';
      }
    } catch (e) {
      if (_isDisposed) return;
      _logError('Load profile error', e);
      _setState(ProfileState.error);
      _errorMessage = 'حدث خطأ في تحميل البيانات';
    }
  }

  Future<void> loadStatistics() async {
    if (_isDisposed || !isAuthenticated) return;
    
    try {
      // Using parallel execution for better performance
      // Each future returns int, so we use proper type annotation
      final (readingsCount, medicinesCount, consecutiveDays) = await (
        _getReadingsCount(),
        _getMedicinesCount(),
        _calculateConsecutiveDaysOptimized(),
      ).wait;
      
      if (_isDisposed) return;
      
      _readingsCount = readingsCount;
      _medicinesCount = medicinesCount;
      _consecutiveDays = consecutiveDays;
      
      _safeNotifyListeners();
      _log('Statistics loaded: readings=$_readingsCount, medicines=$_medicinesCount, days=$_consecutiveDays');
    } catch (e) {
      if (_isDisposed) return;
      _logError('Load statistics error', e);
    }
  }

  Future<int> _getReadingsCount() async {
    final snapshot = await _firestore
        .collection('health_readings')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> _getMedicinesCount() async {
    final snapshot = await _firestore
        .collection('medicines')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> _calculateConsecutiveDaysOptimized() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final snapshot = await _firestore
          .collection('health_readings')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('timestamp', descending: true)
          .get();
      
      if (snapshot.docs.isEmpty) return 0;
      
      final Set<String> daysWithReadings = {};
      
      for (final doc in snapshot.docs) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        final dayKey = '${timestamp.year}-${timestamp.month}-${timestamp.day}';
        daysWithReadings.add(dayKey);
      }
      
      int consecutiveDays = 0;
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dayKey = '${date.year}-${date.month}-${date.day}';
        
        if (daysWithReadings.contains(dayKey)) {
          consecutiveDays++;
        } else if (i > 0) {
          break;
        }
      }
      
      return consecutiveDays;
    } catch (e) {
      _logError('Calculate consecutive days error', e);
      return 0;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    double? height,
    double? weight,
    String? address,
    String? nationalId,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? emergencyContact,
    String? emergencyPhone,
  }) async {
    if (_isDisposed) return false;
    
    if (!isAuthenticated) {
      _errorMessage = 'يرجى تسجيل الدخول';
      return false;
    }
    
    _setState(ProfileState.updating);
    
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (name != null && name.isNotEmpty) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (dateOfBirth != null) updates['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      if (gender != null) updates['gender'] = gender;
      if (bloodType != null) updates['bloodType'] = bloodType;
      if (height != null) updates['height'] = height;
      if (weight != null) updates['weight'] = weight;
      if (address != null) updates['address'] = address;
      if (nationalId != null) updates['nationalId'] = nationalId;
      if (chronicDiseases != null) updates['chronicDiseases'] = chronicDiseases;
      if (allergies != null) updates['allergies'] = allergies;
      if (emergencyContact != null) updates['emergencyContact'] = emergencyContact;
      if (emergencyPhone != null) updates['emergencyPhone'] = emergencyPhone;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
      
      if (name != null && name.isNotEmpty) {
        await _auth.currentUser?.updateDisplayName(name);
      }
      
      if (_isDisposed) return true;
      
      await loadProfile();
      
      _setState(ProfileState.success);
      _log('Profile updated successfully');
      
      _scheduleStateReset();
      
      return true;
    } catch (e) {
      if (_isDisposed) return false;
      _logError('Update profile error', e);
      _setState(ProfileState.error);
      _errorMessage = 'حدث خطأ في تحديث البيانات';
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isDisposed) return false;
    
    if (!isAuthenticated) {
      _errorMessage = 'يرجى تسجيل الدخول';
      return false;
    }
    
    _setState(ProfileState.updating);
    
    try {
      final user = _auth.currentUser!;
      final email = user.email!;
      
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      
      if (_isDisposed) return true;
      
      _setState(ProfileState.success);
      _log('Password changed successfully');
      
      _scheduleStateReset();
      
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (_isDisposed) return false;
      _logError('Change password error', e);
      _setState(ProfileState.error);
      
      switch (e.code) {
        case 'wrong-password':
          _errorMessage = 'كلمة المرور الحالية غير صحيحة';
          break;
        case 'weak-password':
          _errorMessage = 'كلمة المرور الجديدة ضعيفة جداً';
          break;
        case 'requires-recent-login':
          _errorMessage = 'يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى';
          break;
        default:
          _errorMessage = 'حدث خطأ في تغيير كلمة المرور';
      }
      
      return false;
    } catch (e) {
      if (_isDisposed) return false;
      _logError('Change password error', e);
      _setState(ProfileState.error);
      _errorMessage = 'حدث خطأ غير متوقع';
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚪 LOGOUT - Enterprise Grade Implementation
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // This logout implementation follows security best practices:
  // 1. Clear saved credentials (prevents auto-login)
  // 2. Sign out from Firebase
  // 3. Clear local state
  // 4. Reset to initial state
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logout user and clear all saved credentials
  /// 
  /// [clearCredentials] - If true (default), clears saved email/password
  ///                      Set to false only for session-only logout
  /// 
  /// Returns true if logout was successful
  Future<bool> logout({bool clearCredentials = true}) async {
    if (_isDisposed) return false;
    
    _setState(ProfileState.updating);
    
    try {
      _log('🚪 Starting logout process...');
      
      // ═══════════════════════════════════════════════════════════════
      // Step 1: Clear saved credentials (CRITICAL for preventing auto-login)
      // ═══════════════════════════════════════════════════════════════
      if (clearCredentials) {
        _log('🧹 Clearing saved credentials...');
        final credentialsResult = await CredentialsManager.instance.clearAll();
        
        if (!credentialsResult.success) {
          _logError('Warning: Failed to clear credentials', credentialsResult.errorMessage);
          // Continue with logout even if credentials clearing fails
        } else {
          _log('✅ Credentials cleared successfully');
        }
      }
      
      // ═══════════════════════════════════════════════════════════════
      // Step 2: Sign out from Firebase
      // ═══════════════════════════════════════════════════════════════
      _log('🔐 Signing out from Firebase...');
      await _auth.signOut();
      _log('✅ Firebase sign out successful');
      
      // ═══════════════════════════════════════════════════════════════
      // Step 3: Clear local state
      // ═══════════════════════════════════════════════════════════════
      _user = null;
      _readingsCount = 0;
      _medicinesCount = 0;
      _consecutiveDays = 0;
      _memberSince = null;
      _errorMessage = null;
      
      // ═══════════════════════════════════════════════════════════════
      // Step 4: Reset to initial state
      // ═══════════════════════════════════════════════════════════════
      _setState(ProfileState.initial);
      
      _log('═══════════════════════════════════════════════════════════');
      _log('✅ LOGOUT COMPLETE');
      _log('   • Credentials cleared: $clearCredentials');
      _log('   • Firebase signed out: true');
      _log('   • Local state cleared: true');
      _log('═══════════════════════════════════════════════════════════');
      
      return true;
    } catch (e) {
      if (_isDisposed) return false;
      
      _logError('Logout error', e);
      _setState(ProfileState.error);
      _errorMessage = 'حدث خطأ في تسجيل الخروج';
      
      // Attempt to clear credentials even on error (security measure)
      if (clearCredentials) {
        try {
          await CredentialsManager.instance.clearAll();
        } catch (_) {
          // Ignore secondary error
        }
      }
      
      return false;
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    if (_isDisposed) return false;
    
    if (!isAuthenticated) {
      _errorMessage = 'يرجى تسجيل الدخول';
      return false;
    }
    
    _setState(ProfileState.updating);
    
    try {
      final user = _auth.currentUser!;
      final email = user.email!;
      final uid = user.uid;
      
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      await _deleteUserDataInBatches(uid);
      
      await user.delete();
      
      _user = null;
      _setState(ProfileState.initial);
      _log('Account deleted successfully');
      
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (_isDisposed) return false;
      _logError('Delete account error', e);
      _setState(ProfileState.error);
      
      switch (e.code) {
        case 'wrong-password':
          _errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'requires-recent-login':
          _errorMessage = 'يرجى إعادة تسجيل الدخول والمحاولة مرة أخرى';
          break;
        default:
          _errorMessage = 'حدث خطأ في حذف الحساب';
      }
      
      return false;
    } catch (e) {
      if (_isDisposed) return false;
      _logError('Delete account error', e);
      _setState(ProfileState.error);
      _errorMessage = 'حدث خطأ غير متوقع';
      return false;
    }
  }

  Future<void> _deleteUserDataInBatches(String uid) async {
    const int batchSize = 400;
    
    await _deleteCollectionInBatches(
      'health_readings',
      'userId',
      uid,
      batchSize,
    );
    
    await _deleteCollectionInBatches(
      'medicines',
      'userId',
      uid,
      batchSize,
    );
    
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<void> _deleteCollectionInBatches(
    String collection,
    String field,
    String value,
    int batchSize,
  ) async {
    QuerySnapshot snapshot;
    
    do {
      snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .limit(batchSize)
          .get();
      
      if (snapshot.docs.isEmpty) break;
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
    } while (snapshot.docs.length == batchSize);
  }

  String generateQRData() {
    if (!isAuthenticated || _user == null) return '';
    
    final now = DateTime.now();
    final expiry = now.add(const Duration(minutes: 5));
    
    final data = {
      'uid': userId,
      'name': _user?.name,
      'exp': expiry.millisecondsSinceEpoch,
      'type': 'patient',
    };
    
    return Uri.encodeComponent(
      '${data['uid']}|${data['name']}|${data['exp']}|${data['type']}'
    );
  }

  void _setState(ProfileState newState) {
    if (_isDisposed) return;
    _state = newState;
    if (newState != ProfileState.error) {
      _errorMessage = null;
    }
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _scheduleStateReset() {
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 1), () {
      if (!_isDisposed && _state == ProfileState.success) {
        _setState(ProfileState.loaded);
      }
    });
  }

  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    if (_state == ProfileState.error) {
      _setState(ProfileState.loaded);
    }
  }

  Future<void> refresh() async {
    if (_isDisposed) return;
    await loadProfile();
    await loadStatistics();
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('ProfileProvider: $message');
    }
  }

  void _logError(String message, Object? error) {
    if (kDebugMode) {
      debugPrint('ProfileProvider: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _successTimer?.cancel();
    _successTimer = null;
    _log('Disposing ProfileProvider');
    super.dispose();
  }
}
