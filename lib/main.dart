import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/utils/app_logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/main/main_nav_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/challenges_provider.dart';
import 'providers/rewards_provider.dart';
import 'providers/certifications_provider.dart';
import 'providers/attendance_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('App', 'Starting EngageHub');

  final authProvider = AuthProvider();
  AppLogger.info('App', 'Restoring session');
  await authProvider.init();

  // Check if onboarding is completed
  final storage = FlutterSecureStorage();
  String? value = await storage.read(key: 'onboarding_completed');
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

class EmployeeEngagementApp extends StatelessWidget {
  final AuthProvider authProvider;
  final bool onboardingCompleted;

  const EmployeeEngagementApp({
    super.key,
    required this.authProvider,
    required this.onboardingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => ChallengesProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => CertificationsProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
        title: 'EngageHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            surfaceContainerHighest: AppColors.background,
          ),
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: AppInitializer(onboardingCompleted: onboardingCompleted),
      ),
    );
  }
}

class AppRestartHandler extends StatefulWidget {
  const AppRestartHandler({super.key});

  @override
  State<AppRestartHandler> createState() => _AppRestartHandlerState();
}

class _AppRestartHandlerState extends State<AppRestartHandler> {
  @override
  void initState() {
    super.initState();
    // Immediately rebuild the app with updated onboarding status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restartApp();
    });
  }

  void _restartApp() {
    // Get the updated onboarding status
    FlutterSecureStorage().read(key: 'onboarding_completed').then((value) {
      final onboardingCompleted = value == 'true';

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                AppInitializer(onboardingCompleted: onboardingCompleted),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class AppInitializer extends StatefulWidget {
  final bool onboardingCompleted;

  const AppInitializer({super.key, required this.onboardingCompleted});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash for 3 seconds, then navigate
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    if (!widget.onboardingCompleted) {
      return const OnboardingScreen();
    }

    // Normal auth flow
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isAuthenticated) {
          return const MainNavScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
