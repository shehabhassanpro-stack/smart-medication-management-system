import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_care_app/core/app_theme.dart';
import 'package:medical_care_app/providers/auth_provider.dart';
import 'package:medical_care_app/models/user_model.dart';
import 'dart:async';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String? _errorMessage;
  
  Map<String, dynamic> _statistics = {
    'totalPatients': 0,
    'criticalPatients': 0,
    'weeklyIncrease': 0,
  };
  
  List<Map<String, dynamic>> _recentPatients = [];
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.userModel;

      if (currentUser == null) {
        throw Exception('لم يتم تسجيل الدخول');
      }

      await Future.wait([
        _loadStatistics(currentUser.uid),
        _loadRecentPatients(currentUser.uid),
        _loadAlerts(currentUser.uid),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'حدث خطأ في تحميل البيانات';
        });
      }
    }
  }

  Future<void> _loadStatistics(String doctorId) async {
    try {
      final patientsSnapshot = await _firestore
          .collection('doctor_patients')
          .where('doctorId', isEqualTo: doctorId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('انتهى وقت الاتصال'),
          );

      final criticalCount = patientsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'critical')
          .length;

      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weeklyIncrease = patientsSnapshot.docs
          .where((doc) {
            final addedAt = (doc.data()['addedAt'] as Timestamp?)?.toDate();
            return addedAt != null && addedAt.isAfter(oneWeekAgo);
          })
          .length;

      _statistics = {
        'totalPatients': patientsSnapshot.docs.length,
        'criticalPatients': criticalCount,
        'weeklyIncrease': weeklyIncrease,
      };
    } catch (e) {
      debugPrint('❌ Error loading statistics: $e');
      rethrow;
    }
  }

  Future<void> _loadRecentPatients(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('doctor_patients')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('lastVisit', descending: true)
          .limit(5)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('انتهى وقت الاتصال'),
          );

      _recentPatients = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'غير معروف',
          'age': data['age'] ?? 0,
          'condition': data['condition'] ?? 'غير محدد',
          'status': data['status'] ?? 'stable',
          'lastVisit': data['lastVisit'] != null
              ? _formatDate((data['lastVisit'] as Timestamp).toDate())
              : 'غير معروف',
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error loading recent patients: $e');
      _recentPatients = [];
    }
  }

  Future<void> _loadAlerts(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('doctor_alerts')
          .where('doctorId', isEqualTo: doctorId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('انتهى وقت الاتصال'),
          );

      _alerts = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'type': data['type'] ?? 'info',
          'title': data['title'] ?? 'تنبيه',
          'subtitle': data['subtitle'] ?? '',
          'time': data['createdAt'] != null
              ? _formatTimeAgo((data['createdAt'] as Timestamp).toDate())
              : 'الآن',
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error loading alerts: $e');
      _alerts = [];
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'critical':
        return AppTheme.errorRed;
      case 'warning':
        return AppTheme.warningOrange;
      case 'stable':
        return AppTheme.successGreen;
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'critical':
        return 'حرجة';
      case 'warning':
        return 'تحذير';
      case 'stable':
        return 'مستقرة';
      default:
        return 'عادية';
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'critical':
      case 'warning':
        return Icons.warning_rounded;
      case 'medicine':
        return Icons.medication_rounded;
      case 'appointment':
        return Icons.event_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'critical':
        return AppTheme.errorRed;
      case 'warning':
        return AppTheme.warningOrange;
      case 'medicine':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.successGreen;
    }
  }

  Future<void> _handleRefresh() async {
    await _loadDashboardData();
  }

  void _handleAddPatient() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة إضافة مريض قريباً'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _handleSearchPatient() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة البحث عن مريض قريباً'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _handleViewReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة التقارير قريباً'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _handleViewPatient(String patientId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('عرض تفاصيل المريض: $patientId'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _handleNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: CustomScrollView(
                      slivers: [
                        _buildAppBar(context),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildStatisticsCards(context),
                              const SizedBox(height: 16),
                              _buildQuickActions(context),
                              const SizedBox(height: 16),
                              _buildRecentPatients(context),
                              const SizedBox(height: 16),
                              _buildAlerts(context),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _handleAddPatient,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('إضافة مريض'),
              backgroundColor: AppTheme.primaryBlue,
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'حدث خطأ غير متوقع',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        final displayName = user?.name ?? 'دكتور';
        final specialty = user?.specialty ?? 'غير محدد';

        return SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.primaryBlue,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'د. $displayName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  specialty,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: _handleNotifications,
                                ),
                                if (_alerts.isNotEmpty)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'المرضى',
              value: '${_statistics['totalPatients']}',
              icon: Icons.people_rounded,
              color: AppTheme.primaryBlue,
              subtitle: '+${_statistics['weeklyIncrease']} هذا الأسبوع',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'الحالات الحرجة',
              value: '${_statistics['criticalPatients']}',
              icon: Icons.warning_rounded,
              color: AppTheme.warningOrange,
              subtitle: 'تحتاج متابعة',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowSM[0].color,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.search_rounded,
                  title: 'بحث عن مريض',
                  color: AppTheme.primaryBlue,
                  onTap: _handleSearchPatient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.assessment_rounded,
                  title: 'التقارير',
                  color: AppTheme.successGreen,
                  onTap: _handleViewReports,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatients(BuildContext context) {
    if (_recentPatients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المرضى الأخيرون',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowSM[0].color,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لا يوجد مرضى حالياً',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'المرضى الأخيرون',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _recentPatients.take(3).map((patient) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPatientCard(
                  name: patient['name'],
                  age: patient['age'],
                  condition: patient['condition'],
                  status: patient['status'],
                  lastVisit: patient['lastVisit'],
                  onTap: () => _handleViewPatient(patient['id']),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard({
    required String name,
    required int age,
    required String condition,
    required String status,
    required String lastVisit,
    required VoidCallback onTap,
  }) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowSM[0].color,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.8),
                    AppTheme.primaryBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        size: 14,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$age سنة',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.medical_information_outlined,
                        size: 14,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          condition,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'آخر زيارة: $lastVisit',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(BuildContext context) {
    if (_alerts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التنبيهات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowSM[0].color,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لا توجد تنبيهات جديدة',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'التنبيهات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _alerts.take(3).map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAlertCard(
                  icon: _getAlertIcon(alert['type']),
                  title: alert['title'],
                  subtitle: alert['subtitle'],
                  time: alert['time'],
                  color: _getAlertColor(alert['type']),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowSM[0].color,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppTheme.textMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
