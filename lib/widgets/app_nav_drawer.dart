import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primaryOlive),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Smart Study Planner',
                style: TextStyle(color: AppColors.deepBrown, fontSize: 20),
              ),
            ),
          ),
          _drawerItem(
            context,
            'Dashboard',
            Icons.home_outlined,
            AppRoutes.dashboard,
          ),
          _drawerItem(context, 'Add Note', Icons.add_task, AppRoutes.addTask),
          _drawerItem(
            context,
            'Edit Task',
            Icons.edit_note,
            AppRoutes.editTask,
          ),
          _drawerItem(
            context,
            'Completed Tasks',
            Icons.task_alt_outlined,
            AppRoutes.completedTasks,
          ),
          _drawerItem(
            context,
            'Search Tasks',
            Icons.search,
            AppRoutes.searchTasks,
          ),
          _drawerItem(
            context,
            'Subjects',
            Icons.book_outlined,
            AppRoutes.subjects,
          ),
          _drawerItem(
            context,
            'Study Timetable',
            Icons.calendar_today_outlined,
            AppRoutes.studyTimetable,
          ),
          _drawerItem(
            context,
            'Study Progress',
            Icons.show_chart_outlined,
            AppRoutes.studyProgress,
          ),
          _drawerItem(
            context,
            'Weekly Overview',
            Icons.view_week_outlined,
            AppRoutes.weeklyOverview,
          ),
          _drawerItem(
            context,
            'Notifications',
            Icons.notifications_outlined,
            AppRoutes.notifications,
          ),
          _drawerItem(
            context,
            'Settings',
            Icons.settings_outlined,
            AppRoutes.settings,
          ),
          const Divider(),
          _drawerItem(context, 'Log out', Icons.logout, AppRoutes.login),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    final bool selected = route == currentRoute;

    return ListTile(
      selected: selected,
      selectedTileColor: AppColors.secondaryYellow.withValues(alpha: 0.3),
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        if (!selected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
