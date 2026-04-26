import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/widgets/app_illustration.dart';
import 'package:smart_study_planner/widgets/custom_button.dart';
import 'package:smart_study_planner/widgets/custom_text_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const AppIllustration(
              icon: Icons.emoji_people_rounded,
              title: 'Create Your Study Space',
              subtitle: 'Start managing tasks and subjects with ease.',
              small: true,
            ),
            const SizedBox(height: 14),
            const CustomTextField(label: 'Full name'),
            const SizedBox(height: 12),
            const CustomTextField(label: 'Email'),
            const SizedBox(height: 12),
            const CustomTextField(label: 'Password', obscureText: true),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Create Account',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
