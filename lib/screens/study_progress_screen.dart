import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';

class StudyProgressScreen extends StatelessWidget {
  const StudyProgressScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final int totalTasks = appState.tasks.length;
    final int completedTasks = appState.completedTasks.length;
    final double ratio = totalTasks == 0 ? 0 : completedTasks / totalTasks;

    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.studyProgress),
      appBar: AppBar(title: const Text('Study Progress')),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Completion this week: ${(ratio * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: ratio),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.weeklyOverview),
            child: const Text('View Weekly Overview'),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.completedTasks),
            child: const Text('See completed tasks'),
          ),
        ],
      ),
    );
  }
}
