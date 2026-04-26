import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';
import 'package:smart_study_planner/widgets/custom_button.dart';
import 'package:smart_study_planner/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.forgotPassword),
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Reset your password'),
            const SizedBox(height: 12),
            const CustomTextField(label: 'Registered email'),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Send Reset Link',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.editProfile),
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const CustomTextField(label: 'Name'),
            const SizedBox(height: 12),
            const CustomTextField(label: 'Email'),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Save Profile',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}
