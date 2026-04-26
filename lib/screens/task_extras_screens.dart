import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.completedTasks),
      appBar: AppBar(title: const Text('Completed Tasks')),
      body: ListView(
        children: <Widget>[
          ...appState.completedTasks.map(
            (StudyTask task) => ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(task.title),
              subtitle: Text(appState.subjectName(task.subjectId)),
            ),
          ),
          if (appState.completedTasks.isEmpty)
            const ListTile(title: Text('No completed tasks yet.')),
          ListTile(
            leading: const Icon(Icons.add_alert_outlined),
            title: const Text('Create reminder'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.addReminder),
          ),
        ],
      ),
    );
  }
}

class AddReminderScreen extends StatelessWidget {
  const AddReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.addReminder),
      appBar: AppBar(title: const Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(labelText: 'Reminder title'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Date and time'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTasksScreen extends StatefulWidget {
  const SearchTasksScreen({super.key});

  @override
  State<SearchTasksScreen> createState() => _SearchTasksScreenState();
}

class _SearchTasksScreenState extends State<SearchTasksScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final List<StudyTask> visibleTasks = appState.searchTasks(_controller.text);

    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.searchTasks),
      appBar: AppBar(title: const Text('Search Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search by task title',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ...visibleTasks.map(
                    (StudyTask task) => ListTile(
                      title: Text(task.title),
                      subtitle: Text(appState.subjectName(task.subjectId)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.read<AppState>().setSelectedTask(task.id);
                        Navigator.pushNamed(context, AppRoutes.editTask);
                      },
                    ),
                  ),
                  if (visibleTasks.isEmpty)
                    const ListTile(title: Text('No matching tasks found.')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
