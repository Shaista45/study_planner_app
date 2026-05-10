import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class StudyTimetableScreen extends StatefulWidget {
  const StudyTimetableScreen({super.key});

  @override
  State<StudyTimetableScreen> createState() => _StudyTimetableScreenState();
}

class _StudyTimetableScreenState extends State<StudyTimetableScreen> {
  // Start by selecting today's day of the week (1 = Mon, 7 = Sun)
  int _selectedDay = DateTime.now().weekday;

  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final daySessions = appState.getSessionsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryOlive,
        onPressed: () => _showAddSessionSheet(context, appState),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Block",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.deepBrown,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Weekly Timetable',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),

            // 2. DAY SELECTOR STRIP
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final int dayNumber = index + 1;
                  final bool isSelected = _selectedDay == dayNumber;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = dayNumber),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryYellow
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondaryYellow
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekDays[index],
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.deepBrown
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 3. SESSIONS TIMELINE
            Expanded(
              child: daySessions.isEmpty
                  ? Center(
                      child: Text(
                        'No study blocks planned for this day.',
                        style: TextStyle(
                          color: AppColors.deepBrown.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: daySessions.length,
                      itemBuilder: (context, index) {
                        final session = daySessions[index];
                        final subjectName = appState.subjectName(
                          session.subjectId,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: const Border(
                              left: BorderSide(
                                color: AppColors.primaryOlive,
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subjectName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.deepBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 16,
                                        color: AppColors.primaryOlive,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${session.startTime.format(context)} - ${session.endTime.format(context)}',
                                        style: TextStyle(
                                          color: AppColors.deepBrown.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    appState.deleteStudySession(session.id),
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

  // --- BOTTOM SHEET TO ADD A NEW SESSION ---
  void _showAddSessionSheet(BuildContext context, AppState appState) {
    String? selectedSubject = appState.subjects.isNotEmpty
        ? appState.subjects.first.id
        : null;
    int selectedDay = _selectedDay;
    TimeOfDay startTime = const TimeOfDay(hour: 18, minute: 0); // Default 6 PM
    TimeOfDay endTime = const TimeOfDay(hour: 19, minute: 0); // Default 7 PM

    if (selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a Subject first!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          // StatefulBuilder allows the bottom sheet to update its own state
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Study Block',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBrown,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subject Dropdown
                  const Text(
                    'Subject',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedSubject,
                        items: appState.subjects
                            .map(
                              (sub) => DropdownMenuItem(
                                value: sub.id,
                                child: Text(sub.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setSheetState(() => selectedSubject = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Day Dropdown
                  const Text(
                    'Day of Week',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedDay,
                        items: List.generate(
                          7,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(_weekDays[index]),
                          ),
                        ),
                        onChanged: (val) =>
                            setSheetState(() => selectedDay = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: startTime,
                                );
                                if (time != null)
                                  setSheetState(() => startTime = time);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  startTime.format(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Time',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: endTime,
                                );
                                if (time != null)
                                  setSheetState(() => endTime = time);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  endTime.format(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOlive,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        appState.addStudySession(
                          subjectId: selectedSubject!,
                          dayOfWeek: selectedDay,
                          startTime: startTime,
                          endTime: endTime,
                        );
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      child: const Text(
                        'Save Block',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
