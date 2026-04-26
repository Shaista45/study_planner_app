import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedSubjectId;
  String? _selectedTaskId;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final StudyTask? task = appState.selectedTask;
    final List<Subject> subjects = appState.subjects;

    if (!_initialized && task != null) {
      _selectedTaskId = task.id;
      _selectedSubjectId = task.subjectId;
      _titleController.text = task.title;
      _initialized = true;
    }

    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.editTask),
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: task == null
            ? const Center(
                child: Text('No task selected. Use Search Tasks first.'),
              )
            : Hero(
                tag: 'task-card-${task.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Update selected task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Task title',
                            hintText: 'Complete chapter 3 summary',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                          ),
                          items: subjects
                              .map(
                                (Subject subject) => DropdownMenuItem<String>(
                                  value: subject.id,
                                  child: Text(subject.name),
                                ),
                              )
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedSubjectId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          children: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryYellow,
                                foregroundColor: AppColors.deepBrown,
                              ),
                              onPressed: () async {
                                if (_selectedTaskId == null ||
                                    _selectedSubjectId == null) {
                                  return;
                                }

                                await context.read<AppState>().updateTask(
                                  id: _selectedTaskId!,
                                  title: _titleController.text,
                                  subjectId: _selectedSubjectId!,
                                );

                                if (!context.mounted) {
                                  return;
                                }

                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushReplacementNamed(AppRoutes.dashboard);
                              },
                              child: const Text('Update'),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                if (_selectedTaskId == null) {
                                  return;
                                }

                                await context
                                    .read<AppState>()
                                    .markTaskCompleted(_selectedTaskId!);

                                if (!context.mounted) {
                                  return;
                                }

                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushReplacementNamed(
                                  AppRoutes.completedTasks,
                                );
                              },
                              child: const Text('Mark Completed'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
