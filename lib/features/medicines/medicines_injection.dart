import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_colors.dart';
import 'data/datasources/medicines_remote_datasource.dart';
import 'data/repositories/medicines_repository_impl.dart';
import 'domain/repositories/medicines_repository.dart';
import 'presentation/providers/medicines_provider.dart';
import 'presentation/providers/medicine_form_provider.dart';
import 'presentation/screens/medicines_list_screen.dart';

class MedicinesInjection {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static MedicinesRemoteDataSource? _dataSource;
  static MedicinesRepository? _repository;

  static MedicinesRemoteDataSource get dataSource {
    _dataSource ??= MedicinesRemoteDataSourceImpl(firestore: _firestore);
    return _dataSource!;
  }

  static MedicinesRepository get repository {
    _repository ??= MedicinesRepositoryImpl(remoteDataSource: dataSource);
    return _repository!;
  }

  static Widget buildMedicinesScreen(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const _MedicinesLoadingWidget();
        }

        final userId = authProvider.userId;

        if (userId == null || userId.isEmpty) {
          if (authProvider.firebaseUser != null) {
            return const _MedicinesLoadingWidget();
          }
          return const _MedicinesAuthErrorWidget();
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<MedicinesProvider>(
              create: (_) => MedicinesProvider(
                repository: repository,
                userId: userId,
              ),
            ),
            ChangeNotifierProvider<MedicineFormProvider>(
              create: (_) => MedicineFormProvider(
                repository: repository,
                userId: userId,
              ),
            ),
          ],
          child: const MedicinesListScreen(),
        );
      },
    );
  }

  static void clearCache() {
    _dataSource = null;
    _repository = null;
  }
}

class _MedicinesLoadingWidget extends StatelessWidget {
  const _MedicinesLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicinesAuthErrorWidget extends StatelessWidget {
  const _MedicinesAuthErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'خطأ في المصادقة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى تسجيل الدخول مرة أخرى',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  authProvider.logout();
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}