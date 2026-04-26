import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/widgets/app_illustration.dart';
import 'package:smart_study_planner/widgets/custom_button.dart';
import 'package:smart_study_planner/widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: AppIllustration(
                icon: Icons.school_rounded,
                title: 'Welcome Back',
                subtitle: 'Stay focused and keep your study streak alive.',
                small: true,
              ),
            ),
            const SizedBox(height: 14),
            const CustomTextField(label: 'Email'),
            const SizedBox(height: 12),
            const CustomTextField(label: 'Password', obscureText: true),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Login',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.forgotPassword),
              child: const Text('Forgot password?'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
