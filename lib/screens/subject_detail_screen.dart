import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/screens/edit_task_screen.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/task_item_card.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    // Find the specific subject based on the ID passed in
    final Subject subject = appState.subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => Subject(id: '', name: 'Unknown Subject'),
    );

    // Filter tasks so we only see ones belonging to this subject
    final List<StudyTask> subjectTasks = appState.tasksForSubject(subjectId);

    // Calculate progress strictly for this subject
    final int totalTasks = subjectTasks.length;
    final int completedTasks = subjectTasks.where((t) => t.isCompleted).length;
    final double progressValue = totalTasks == 0
        ? 0.0
        : completedTasks / totalTasks;
    final int progressPercent = (progressValue * 100).toInt();

    final List<Color> dots = const <Color>[
      AppColors.primaryOlive,
      AppColors.secondaryYellow,
      AppColors.accentOrange,
    ];

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
                  Expanded(
                    child: Text(
                      subject.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBrown,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Details Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOlive,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOlive.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                subject.teacherName?.isNotEmpty == true
                                    ? subject.teacherName!
                                    : 'No teacher assigned',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                subject.studyHours != null
                                    ? '${subject.studyHours} Hours / Week'
                                    : 'Study hours not set',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Individual Subject Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subject Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$progressPercent%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.secondaryYellow,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Filtered Tasks Section
                    Text(
                      'Tasks for ${subject.name}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBrown,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (subjectTasks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Text(
                            'No tasks assigned to this subject yet.',
                            style: TextStyle(
                              color: AppColors.deepBrown.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List<Widget>.generate(subjectTasks.length, (
                        int index,
                      ) {
                        final StudyTask task = subjectTasks[index];
                        return TaskItemCard(
                          title: task.title,
                          status: task.isCompleted ? 'Done' : 'In Progress',
                          dotColor: dots[index % dots.length],
                          heroTag: 'subject-task-${task.id}',
                          onTap: () {
                            context.read<AppState>().setSelectedTask(task.id);
                            Navigator.of(context).push(
                              PageRouteBuilder<void>(
                                transitionDuration: const Duration(
                                  milliseconds: 320,
                                ),
                                pageBuilder: (_, __, ___) =>
                                    const EditTaskScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                        );
                      }),
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
