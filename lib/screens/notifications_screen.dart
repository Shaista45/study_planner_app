import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.notifications),
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Task reminders'),
            subtitle: const Text('Notify before each task deadline.'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Weekly summary'),
            subtitle: const Text('Get a progress summary each Sunday.'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Open Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
