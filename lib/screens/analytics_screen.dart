import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/ad_banner_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Core structural metrics calculated dynamically
    final int totalTasks = appState.tasks.length;
    final int completedCount = appState.completedTasks.length;
    final int pendingCount = appState.pendingTasks.length;
    final int totalSubjects = appState.subjects.length;

    // Safety check to handle division by zero if no tasks exist yet
    final double completionRate = totalTasks > 0
        ? (completedCount / totalTasks)
        : 0.0;
    final int completionPercentage = (completionRate * 100).round();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          controller:
              scrollController, // ✅ Wire up the controller for tap-to-top actions
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SECTION
              Text(
                'Study Insights',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBrown,
                ),
              ),
              Text(
                'Real-time metrics of your academic progress',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // 2. MAIN PROGRESS RING CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Custom Circular Progress Ring Graphic
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: completionKeyRate(completionRate),
                            backgroundColor: Colors.grey.shade100,
                            color: AppColors.primaryOlive,
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '$completionPercentage%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Descriptive Metrics Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Task Completion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalTasks > 0
                                ? 'You have completed $completedCount out of $totalTasks tasks so far.'
                                : 'Add study tasks to unlock performance tracking statistics.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. GRID METRICS BLOCK
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Active Courses',
                      value: '$totalSubjects',
                      icon: Icons.menu_book_rounded,
                      color: AppColors.primaryOlive.withValues(alpha: 0.1),
                      iconColor: AppColors.primaryOlive,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Pending Work',
                      value: '$pendingCount',
                      icon: Icons.assignment_late_rounded,
                      color: AppColors.accentOrange.withValues(alpha: 0.1),
                      iconColor: AppColors.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. SUBJECT-WISE BREAKDOWN PANEL
              Text(
                'Course Load Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBrown,
                ),
              ),
              const SizedBox(height: 12),
              totalSubjects == 0
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalSubjects,
                      itemBuilder: (context, index) {
                        final subject = appState.subjects[index];
                        final int subjectTaskCount = appState
                            .tasksForSubject(subject.id)
                            .length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.secondaryYellow
                                        .withValues(alpha: 0.3),
                                    radius: 18,
                                    child: const Icon(
                                      Icons.bookmark_rounded,
                                      size: 16,
                                      color: AppColors.deepBrown,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    subject.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepBrown,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$subjectTaskCount Tasks',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              const AdBannerWidget(), // ✅ Instantiates flawlessly with live SDK bindings below
            ],
          ),
        ),
      ),
    );
  }

  // Double fallback security wrapper targeting visual bounds safety
  double completionKeyRate(double actualRate) {
    if (actualRate.isNaN || actualRate.isInfinite || actualRate < 0.0) {
      return 0.0;
    }
    if (actualRate > 1.0) return 1.0;
    return actualRate;
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBrown,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        'No subject allocation metrics available.',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
    );
  }
}
