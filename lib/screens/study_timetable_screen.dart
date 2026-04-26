import 'package:flutter/material.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';

class StudyTimetableScreen extends StatelessWidget {
  const StudyTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.studyTimetable),
      appBar: AppBar(title: const Text('Study Timetable')),
      body: ListView(
        children: <Widget>[
          const ListTile(
            leading: Icon(Icons.schedule),
            title: Text('08:00 - Mathematics revision'),
          ),
          const ListTile(
            leading: Icon(Icons.schedule),
            title: Text('16:00 - Biology flashcards'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.addTask),
                  child: const Text('Add Session'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.editTask),
                  child: const Text('Edit Session'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
