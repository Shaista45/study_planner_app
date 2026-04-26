import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class StudyTimetableScreen extends StatefulWidget {
  const StudyTimetableScreen({super.key});

  @override
  State<StudyTimetableScreen> createState() => _StudyTimetableScreenState();
}

class _StudyTimetableScreenState extends State<StudyTimetableScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _currentWeek;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentWeek = _generateWeek(_selectedDate);
  }

  // Generates a list of 7 days starting from Monday of the selected date's week
  List<DateTime> _generateWeek(DateTime date) {
    final int currentWeekday = date.weekday;
    final DateTime monday = date.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getWeekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    final int minute = time.minute;
    final String ampm = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    final String minStr = minute.toString().padLeft(2, '0');
    return '$hour:$minStr $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    // Filter tasks that have a deadline matching the selected day
    final List<StudyTask> dailyTasks = appState.tasks.where((task) {
      if (task.deadline == null) return false;
      return _isSameDay(task.deadline!, _selectedDate);
    }).toList();

    // Sort tasks by time (earliest first)
    dailyTasks.sort((a, b) => a.deadline!.compareTo(b.deadline!));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                    'Study Timetable',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),

            // Weekly Strip
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryOlive,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOlive.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _currentWeek.map((date) {
                  final bool isSelected = _isSameDay(date, _selectedDate);
                  final bool isToday = _isSameDay(date, DateTime.now());

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryYellow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getWeekdayName(date.weekday),
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.deepBrown
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.deepBrown
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isToday)
                            Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentOrange
                                    : AppColors.secondaryYellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Selected Day Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _isSameDay(_selectedDate, DateTime.now())
                    ? 'Today\'s Plan'
                    : '${_getWeekdayName(_selectedDate.weekday)}, ${_selectedDate.day}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBrown,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daily Timeline View
            Expanded(
              child: dailyTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No study sessions planned.',
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
                      itemCount: dailyTasks.length,
                      itemBuilder: (context, index) {
                        final StudyTask task = dailyTasks[index];
                        final Subject? subject = appState.subjects
                            .where((s) => s.id == task.subjectId)
                            .firstOrNull;

                        return IntrinsicHeight(
                          child: Row(
                            children: [
                              // Timeline UI
                              SizedBox(
                                width: 70,
                                child: Column(
                                  children: [
                                    Text(
                                      _formatTime(task.deadline!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.deepBrown,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        color: index == dailyTasks.length - 1
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Task Card
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: task.isCompleted
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: task.priorityLevel == 'High'
                                          ? AppColors.accentOrange.withValues(
                                              alpha: 0.5,
                                            )
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            subject?.name ?? 'General',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryOlive,
                                            ),
                                          ),
                                          if (task.priorityLevel == 'High')
                                            const Icon(
                                              Icons
                                                  .local_fire_department_rounded,
                                              size: 16,
                                              color: AppColors.accentOrange,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: task.isCompleted
                                              ? Colors.grey
                                              : AppColors.deepBrown,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
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
