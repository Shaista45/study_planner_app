import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';

class WeeklyOverviewScreen extends StatelessWidget {
  const WeeklyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.weeklyOverview),
      appBar: AppBar(title: const Text('Weekly Overview')),
      body: ListView(
        children: <Widget>[
          const ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Tasks completed: 12'),
          ),
          const ListTile(
            leading: Icon(Icons.timer_outlined),
            title: Text('Study hours: 16.5'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.studyProgress),
                  child: const Text('Progress Details'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.studyTimetable),
                  child: const Text('Open Timetable'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
