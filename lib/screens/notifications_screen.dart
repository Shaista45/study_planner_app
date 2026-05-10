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
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOlive.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_off_rounded,
                              size: 48,
                              color: AppColors.primaryOlive,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No upcoming reminders.',
                            style: TextStyle(
                              color: AppColors.deepBrown.withValues(alpha: 0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                        Color borderColor;
                        String timeText;
                        IconData icon;

                        // Apply Theme Colors based on Urgency
                        if (isOverdue) {
                          iconColor = Colors.red.shade700;
                          bgColor = Colors.red.shade50;
                          borderColor = Colors.red.shade200;
                          timeText =
                              'Overdue by ${difference.inHours.abs()} hrs';
                          icon = Icons.warning_rounded;
                        } else if (isDueToday) {
                          iconColor = AppColors.accentOrange;
                          bgColor = AppColors.accentOrange.withValues(
                            alpha: 0.1,
                          );
                          borderColor = AppColors.accentOrange.withValues(
                            alpha: 0.3,
                          );
                          timeText = 'Due in ${difference.inHours} hours';
                          icon = Icons.access_time_filled_rounded;
                        } else {
                          iconColor = AppColors.primaryOlive;
                          bgColor = AppColors.primaryOlive.withValues(
                            alpha: 0.1,
                          );
                          borderColor = Colors.transparent;
                          timeText = 'Due in ${difference.inDays} days';
                          icon = Icons.event_rounded;
                        }

                        // Split Title and Description
                        String displayTitle = task.title;
                        String displayDesc = '';
                        if (task.title.contains(' - ')) {
                          final parts = task.title.split(' - ');
                          displayTitle = parts.first;
                          displayDesc = parts.sublist(1).join(' - ');
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
                              color: isOverdue || isDueToday
                                  ? borderColor
                                  : Colors.grey.shade100,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align to top for better description layout
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
                                      displayTitle,
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
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),

                                    // Add the Beautiful Description Box if it exists
                                    if (displayDesc.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryYellow
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: const Border(
                                            left: BorderSide(
                                              color: AppColors.secondaryYellow,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          displayDesc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.deepBrown
                                                .withValues(alpha: 0.7),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
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
