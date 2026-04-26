import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/widgets/app_illustration.dart';
import 'package:smart_study_planner/widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AppIllustration(
              icon: Icons.menu_book_rounded,
              title: 'Plan Better Every Day',
              subtitle: 'Build your study momentum with small daily wins.',
            ),
            const SizedBox(height: 12),
            Text(
              'Smart Study Planner',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Continue',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
            ),
          ],
        ),
      ),
    );
  }
}
