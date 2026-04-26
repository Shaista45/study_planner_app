import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    // Filter out completed tasks and tasks without deadlines
    final List<StudyTask> activeTasks = appState.tasks
        .where((task) => !task.isCompleted && task.deadline != null)
        .toList();

    // Sort by closest deadline
    activeTasks.sort((a, b) => a.deadline!.compareTo(b.deadline!));

    final DateTime now = DateTime.now();

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
                    'Reminders',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: activeTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No upcoming reminders.',
                            style: TextStyle(
                              color: AppColors.deepBrown.withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: activeTasks.length,
                      itemBuilder: (context, index) {
                        final StudyTask task = activeTasks[index];
                        final Duration difference = task.deadline!.difference(
                          now,
                        );

                        // Determine urgency status
                        bool isOverdue = difference.isNegative;
                        bool isDueToday = difference.inDays == 0 && !isOverdue;

                        Color iconColor;
                        Color bgColor;
                        String timeText;
                        IconData icon;

                        if (isOverdue) {
                          iconColor = Colors.red;
                          bgColor = Colors.red.withValues(alpha: 0.1);
                          timeText =
                              'Overdue by ${difference.inHours.abs()} hours';
                          icon = Icons.warning_rounded;
                        } else if (isDueToday) {
                          iconColor = AppColors.accentOrange;
                          bgColor = AppColors.accentOrange.withValues(
                            alpha: 0.1,
                          );
                          timeText = 'Due in ${difference.inHours} hours';
                          icon = Icons.access_time_filled_rounded;
                        } else {
                          iconColor = AppColors.primaryOlive;
                          bgColor = AppColors.primaryOlive.withValues(
                            alpha: 0.1,
                          );
                          timeText = 'Due in ${difference.inDays} days';
                          icon = Icons.event_rounded;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isOverdue
                                  ? Colors.red.shade100
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: iconColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.deepBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeText,
                                      style: TextStyle(
                                        color: iconColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
