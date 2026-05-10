import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/screens/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.scrollController});
  final ScrollController? scrollController;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoHideCompleted = false;

  void _showEditProfileDialog(BuildContext context, AppState appState) {
    final TextEditingController nameController = TextEditingController(
      text: appState.userName,
    );
    final TextEditingController roleController = TextEditingController(
      text: appState.userRole,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.deepBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: AppColors.primaryOlive),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryOlive,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: 'Department / Role',
                  labelStyle: const TextStyle(color: AppColors.primaryOlive),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryOlive,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOlive,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                appState.updateProfile(
                  nameController.text.trim(),
                  roleController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.deepBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(color: AppColors.deepBrown, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryOlive,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Tighter padding)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.deepBrown,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section (Tighter padding)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.secondaryYellow
                                .withValues(alpha: 0.3),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 36,
                              color: AppColors.deepBrown,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.deepBrown,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appState.userRole,
                                  style: TextStyle(
                                    color: AppColors.deepBrown.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _showEditProfileDialog(context, appState),
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AppColors.primaryOlive,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced gap
                    // Preferences
                    Text(
                      'App Preferences',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBrown,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced gap

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            activeColor: AppColors.primaryOlive,
                            title: const Text(
                              'Push Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: const Text(
                              'Get reminders for pending tasks',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _notificationsEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          SwitchListTile(
                            activeColor: AppColors.primaryOlive,
                            title: const Text(
                              'Hide Completed',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: const Text(
                              'Remove finished tasks from dashboard',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _autoHideCompleted,
                            onChanged: (bool value) {
                              setState(() {
                                _autoHideCompleted = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced gap
                    // About Section
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBrown,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced gap

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            visualDensity:
                                VisualDensity.compact, // Makes list tighter
                            leading: const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primaryOlive,
                              size: 20,
                            ),
                            title: const Text(
                              'App Version',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Text(
                              '1.0.0',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Smart Study Planner is up to date!',
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          ListTile(
                            visualDensity: VisualDensity.compact,
                            leading: const Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.primaryOlive,
                              size: 20,
                            ),
                            title: const Text(
                              'Help & Support',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                            ),
                            onTap: () {
                              _showInfoDialog(
                                'Help & Support',
                                'Having trouble?\n\nCheck your active internet connection to ensure Firebase syncs properly. For academic schedule updates, contact your university administration.',
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          ListTile(
                            visualDensity: VisualDensity.compact,
                            leading: const Icon(
                              Icons.privacy_tip_outlined,
                              color: AppColors.primaryOlive,
                              size: 20,
                            ),
                            title: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                            ),
                            onTap: () {
                              _showInfoDialog(
                                'Privacy Policy',
                                'Your data is secured using Google Firebase Authentication. Your study tasks, subjects, and schedules are private and securely stored in the cloud.',
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Pushes the log out button to the bottom if there is remaining space
                    const Spacer(),

                    // LOGOUT BUTTON (Tighter padding)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ), // Reduced vertical padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await appState.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), // Tighter bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
