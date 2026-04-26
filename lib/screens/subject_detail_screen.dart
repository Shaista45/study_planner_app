import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/app_illustration.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';
import 'package:smart_study_planner/widgets/custom_button.dart';

class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final Subject? subject = appState.selectedSubject;

    if (subject == null) {
      return Scaffold(
        drawer: const AppNavDrawer(currentRoute: AppRoutes.subjectDetail),
        appBar: AppBar(title: const Text('Subject Detail')),
        body: const Center(child: Text('No subject selected.')),
      );
    }

    final List<StudyTask> subjectTasks = appState.tasksForSubject(subject.id);

    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.subjectDetail),
      appBar: AppBar(title: const Text('Subject Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              subject.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Upcoming tasks:'),
            const SizedBox(height: 8),
            if (subjectTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: AppIllustration(
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'No tasks yet for this subject',
                  subtitle: 'Add a task to start tracking your progress.',
                  small: true,
                ),
              ),
            ...subjectTasks.map(
              (StudyTask task) => Card(
                child: ListTile(
                  title: Text(task.title),
                  trailing: task.isCompleted
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryOlive,
                        )
                      : null,
                  onTap: () {
                    context.read<AppState>().setSelectedTask(task.id);
                    Navigator.pushNamed(context, AppRoutes.editTask);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Add Task for this Subject',
              onPressed: () {
                context.read<AppState>().setSelectedSubject(subject.id);
                Navigator.pushNamed(context, AppRoutes.addTask);
              },
            ),
          ],
        ),
      ),
    );
  }
}
