import 'package:flutter/material.dart';
import 'core/utils/app_logger.dart';
import 'app/employee_engagement_app.dart';
import 'services/storage/secure_storage_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('App', 'Starting EngageHub');

  final authProvider = AuthProvider();
  AppLogger.info('App', 'Restoring session');
  await authProvider.init();

  // Check if onboarding is completed
  final storage = SecureStorageService.instance;
  String? value = await storage.read(
    key: SecureStorageService.onboardingCompletedKey,
  );
  final onboardingCompleted = value == 'true';
  AppLogger.info('App', 'Onboarding completed: $onboardingCompleted');
  AppLogger.info('App', 'Auth status: ${authProvider.status}');

  runApp(
    EmployeeEngagementApp(
      authProvider: authProvider,
      onboardingCompleted: onboardingCompleted,
    ),
  );
}
