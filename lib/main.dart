import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🚀 Required for kIsWeb flag
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;
import 'package:smart_study_planner/screens/app_shell.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/firebase_options.dart';
import 'package:smart_study_planner/state/app_state.dart'; // Handles your local AppState flawlessly now
import 'package:smart_study_planner/theme/app_theme.dart';
import 'package:smart_study_planner/screens/auth_screen.dart';
import 'package:smart_study_planner/services/notification_service.dart';
import 'package:smart_study_planner/services/log_service.dart';

Future<void> main() async {
  // Required when calling native code before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the logging service
  await logger.init();
  logger.info('App starting...');

  // Initialize Firebase core platform connections
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.info('Firebase initialized');

  // Initialize Google Mobile Ads safely on all platforms. Wrap in try/catch
  // so that web or unexpected platform issues don't crash app startup.
  try {
    await admob.MobileAds.instance.initialize();
    logger.info(
      'Google Mobile Ads initialized (attempted on current platform).',
    );
  } catch (e, st) {
    // Log the failure but continue app startup. On web the SDK may behave
    // differently so we don't want initialization failures to crash the app.
    debugPrint('Google Mobile Ads initialization failed: $e');
    logger.info('Google Mobile Ads initialization failed: $e');
  }

  // Initialize the notification service and request permissions
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  logger.info('Notification service initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState()..initialize(),
      // Wrap MaterialApp in a Consumer to listen for auth changes
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          // Wait for SharedPreferences to load
          if (!appState.isReady) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Study Planner',
            theme: AppTheme.lightTheme,

            // THE GATEKEEPER: If logged in, show AppShell. If not, show Auth screen!
            home: appState.isLoggedIn ? AppShell() : const AuthScreen(),

            // Keep your existing routes
            routes: AppRoutes.getRoutes(),
          );
        },
      ),
    );
  }
}
