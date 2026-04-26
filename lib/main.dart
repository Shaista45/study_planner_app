import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Study Planner',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.dashboard,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
