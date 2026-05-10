import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/screens/app_shell.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/firebase_options.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_theme.dart';
import 'package:smart_study_planner/screens/auth_screen.dart';
import 'package:smart_study_planner/services/notification_service.dart'; // UPDATED: Imported the service

Future<void> main() async {
  // UPDATED: Made main async
  // UPDATED: Required when calling native code before runApp
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // UPDATED: Initialize the notification service and request permissions
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState()..initialize(),
      // UPDATED: Wrap MaterialApp in a Consumer to listen for auth changes
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
            // FIX: Removed the 'const' keyword before AppShell()
            home: appState.isLoggedIn ? AppShell() : const AuthScreen(),

            // Keep your existing routes
            routes: AppRoutes.getRoutes(),
          );
        },
      ),
    );
  }
}
