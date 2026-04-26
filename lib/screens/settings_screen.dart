import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.scrollController});
  final ScrollController? scrollController;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  // UPDATED: Added a method to show the edit profile popup
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
              const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
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

            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    Container(
                      padding: const EdgeInsets.all(20),
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
                            radius: 36,
                            backgroundColor: AppColors.secondaryYellow
                                .withValues(alpha: 0.3),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppColors.deepBrown,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // UPDATED: Bound to global AppState
                                Text(
                                  appState.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: AppColors.deepBrown,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // UPDATED: Bound to global AppState
                                Text(
                                  appState.userRole,
                                  style: TextStyle(
                                    color: AppColors.deepBrown.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // UPDATED: Attached to the new dialog function
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
                    const SizedBox(height: 32),

                    // Preferences
                    Text(
                      'App Preferences',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBrown,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              'Get reminders for pending tasks',
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
                              'Dark Mode',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Switch to a darker theme'),
                            value: _darkModeEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // About Section
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBrown,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                            leading: const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primaryOlive,
                            ),
                            title: const Text(
                              'App Version',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: const Text(
                              '1.0.0',
                              style: TextStyle(color: Colors.grey),
                            ),
                            onTap: () {},
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          ListTile(
                            leading: const Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.primaryOlive,
                            ),
                            title: const Text(
                              'Help & Support',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            onTap: () {},
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          ListTile(
                            leading: const Icon(
                              Icons.privacy_tip_outlined,
                              color: AppColors.primaryOlive,
                            ),
                            title: const Text(
                              'Privacy Policy',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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
