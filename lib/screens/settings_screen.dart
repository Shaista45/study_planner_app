import 'package:flutter/material.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  // FIX: Added the scrollController parameter here
  const SettingsScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
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
                // FIX: Assigned the controller to the scroll view here
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
                                const Text(
                                  'Student Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: AppColors.deepBrown,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Computer Science Dept.',
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
                          IconButton(
                            onPressed: () {},
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
