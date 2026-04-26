import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/screens/edit_task_screen.dart';
import 'package:smart_study_planner/screens/study_progress_screen.dart';
import 'package:smart_study_planner/screens/study_timetable_screen.dart';
import 'package:smart_study_planner/screens/notifications_screen.dart';
import 'package:smart_study_planner/screens/settings_screen.dart'; // IMPORTED: Settings Screen
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/screens/add_task_screen.dart';
import 'package:smart_study_planner/screens/subjects_screen.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/calendar_grid_cell.dart';
import 'package:smart_study_planner/widgets/calendar_strip_cell.dart';
import 'package:smart_study_planner/widgets/task_item_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final DateTime base = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final List<DateTime> dateStrip = List<DateTime>.generate(
      10,
      (int index) => base.add(Duration(days: index - 3)),
    );
    final List<String> weekDays = const <String>[
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];
    final List<Color> dots = const <Color>[
      AppColors.primaryOlive,
      AppColors.secondaryYellow,
      AppColors.accentOrange,
    ];

    final List<StudyTask> allTasks = appState.tasks;
    final List<StudyTask> displayTasks = allTasks.take(5).toList();

    final int activeSubjectsCount = appState.subjects.length;
    final double progressValue = allTasks.isEmpty
        ? 0.0
        : appState.completedTasks.length / allTasks.length;
    final int progressPercent = (progressValue * 100).toInt();

    final int totalDays = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;
    final int firstDayOffset =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday - 1;
    final int gridItems = ((totalDays + firstDayOffset) / 7).ceil() * 7;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondaryYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder<void>(
              transitionDuration: const Duration(milliseconds: 360),
              pageBuilder: (_, __, ___) => const AddTaskScreen(),
              transitionsBuilder:
                  (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child,
                  ) {
                    const Offset begin = Offset(0, 0.12);
                    const Offset end = Offset.zero;
                    final Animatable<Offset> tween = Tween<Offset>(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: Curves.easeOutCubic));

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      ),
                    );
                  },
            ),
          );
        },
        icon: const Icon(Icons.add, color: AppColors.deepBrown),
        label: const Text(
          "Add Task",
          style: TextStyle(
            color: AppColors.deepBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 380;

            return SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // UPDATED: Header now includes the Notification Bell and Settings Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _monthYear(_selectedDate),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_active_rounded,
                              color: AppColors.deepBrown,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.settings_rounded,
                              color: AppColors.deepBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 84,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dateStrip.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DateTime date = dateStrip[index];
                        final bool selected = _sameDay(date, _selectedDate);
                        return CalendarStripCell(
                          dayLabel: _weekdayShort(date.weekday),
                          dayNumber: date.day,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StudyTimetableScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOlive,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: weekDays
                                .map(
                                  (String label) => Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: gridItems,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (BuildContext context, int index) {
                              if (index < firstDayOffset ||
                                  index >= firstDayOffset + totalDays) {
                                return const SizedBox.shrink();
                              }
                              final int value = index - firstDayOffset + 1;
                              return CalendarGridCell(
                                value: '$value',
                                highlight: value == _selectedDate.day,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const StudyProgressScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryYellow.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Study Progress',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$progressPercent% Completed',
                                  style: const TextStyle(
                                    color: AppColors.deepBrown,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progressValue,
                                  backgroundColor: Colors.white,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.accentOrange,
                                      ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOlive.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subjects',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SubjectsScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryOlive,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$activeSubjectsCount Active',
                                style: const TextStyle(
                                  color: AppColors.deepBrown,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.primaryOlive,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Today',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(AppRoutes.searchTasks),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (displayTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'No tasks for today. Add a task to get started.',
                      ),
                    ),
                  ...List<Widget>.generate(displayTasks.length, (int index) {
                    final StudyTask task = displayTasks[index];
                    return TaskItemCard(
                      title: task.title,
                      status: task.isCompleted ? 'Done' : 'In Progress',
                      dotColor: dots[index % dots.length],
                      heroTag: 'task-card-${task.id}',
                      onTap: () {
                        context.read<AppState>().setSelectedTask(task.id);
                        Navigator.of(context).push(
                          PageRouteBuilder<void>(
                            transitionDuration: const Duration(
                              milliseconds: 320,
                            ),
                            pageBuilder: (_, __, ___) => const EditTaskScreen(),
                            transitionsBuilder:
                                (
                                  BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation,
                                  Widget child,
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
                  if (!compact) const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _monthYear(DateTime date) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _weekdayShort(int weekday) {
    const List<String> names = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return names[weekday - 1];
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
