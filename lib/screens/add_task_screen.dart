import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/animated_scale_button.dart';
import 'package:smart_study_planner/widgets/note_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_study_planner/services/notification_service.dart';
import 'package:smart_study_planner/utils/app_logger.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedSubjectId;
  String _selectedPriority = 'Medium';
  bool _alarmEnabled = true;
  int _selectedColor = 0;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(minutes: 1)),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOlive,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.deepBrown,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOlive,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.deepBrown,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final List<Subject> subjects = appState.subjects;

    bool isValidSubject(String? id) =>
        id != null && subjects.any((s) => s.id == id);

    if (!isValidSubject(_selectedSubjectId)) {
      _selectedSubjectId = isValidSubject(appState.selectedSubject?.id)
          ? appState.selectedSubject!.id
          : (subjects.isNotEmpty ? subjects.first.id : null);
    }

    final List<Color> palette = const <Color>[
      AppColors.primaryOlive,
      AppColors.secondaryYellow,
      AppColors.accentOrange,
      AppColors.deepBrown,
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. APP BAR NAV PANEL
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Task',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. SCROLLABLE DATA ENTRY CONTAINER
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DATE & TIME STRIP
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _pickDate,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        color: AppColors.primaryOlive,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.deepBrown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _pickTime,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        color: AppColors.secondaryYellow,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.deepBrown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TASK TITLE INPUT
                      NoteInputField(
                        label: 'Task Title',
                        controller: _titleController,
                        hint: 'e.g., Complete Math Assignment',
                      ),
                      const SizedBox(height: 16),

                      // SELECTORS: DROPDOWN SELECTION BOXES
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subject',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedSubjectId,
                                      hint: const Text('Select Subject'),
                                      items: subjects.map((Subject subject) {
                                        return DropdownMenuItem<String>(
                                          value: subject.id,
                                          child: Text(
                                            subject.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) => setState(
                                        () => _selectedSubjectId = value,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedPriority,
                                      items: _priorities.map((String p) {
                                        return DropdownMenuItem(
                                          value: p,
                                          child: Text(p),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedPriority = val!,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // VISUAL SETTINGS PANEL (COLORS & ALARM SWITCH)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Color Tag',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  children: List<Widget>.generate(
                                    palette.length,
                                    (int index) {
                                      final bool selected =
                                          _selectedColor == index;
                                      return GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedColor = index,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: selected ? 28 : 24,
                                          height: selected ? 28 : 24,
                                          decoration: BoxDecoration(
                                            color: palette[index],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selected
                                                  ? AppColors.deepBrown
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Alarm',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Switch(
                                activeColor: AppColors.primaryOlive,
                                value: _alarmEnabled,
                                onChanged: (bool value) =>
                                    setState(() => _alarmEnabled = value),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // TASK DETAILS DESCRIPTION FIELD
                      Text(
                        'Task Details',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _noteController,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Add details for this task...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // 3. PERSISTENCE TRIGGER ACTION BUTTON
              SizedBox(
                width: double.infinity,
                child: AnimatedScaleButton(
                  onTap: subjects.isEmpty ? null : () => _saveNote(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: subjects.isEmpty
                          ? Colors.grey.shade300
                          : AppColors.secondaryYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Save Task',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: subjects.isEmpty
                            ? Colors.grey.shade500
                            : AppColors.deepBrown,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote(BuildContext context) async {
    final AppState appState = context.read<AppState>();

    if (_selectedSubjectId == null && appState.subjects.isNotEmpty) {
      _selectedSubjectId = appState.subjects.first.id;
    }

    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid subject first.')),
      );
      return;
    }

    final DateTime deadline = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final String titleInput = _titleController.text.trim();
    final String cleanTitle = titleInput.isEmpty
        ? 'New Study Task'
        : titleInput;

    try {
      // Persist the task once through AppState so the local cache and cloud stay in sync.
      final String? taskId = await appState.addTask(
        title: cleanTitle,
        subjectId: _selectedSubjectId!,
        deadline: deadline,
        priorityLevel: _selectedPriority,
      );

      if (taskId == null) {
        throw StateError('Failed to save task');
      }

      // Log task creation
      await AppLogger.logTaskEvent(
        'Created',
        taskId: 'new_task',
        taskName: cleanTitle,
        details: 'Task created with priority: $_selectedPriority',
      );

      // 🔔 🚀 Schedule notification if alarm is enabled
      if (_alarmEnabled) {
        final NotificationService notificationService = NotificationService();

        await notificationService.showTaskCreatedNotification(
          taskId: taskId,
          taskTitle: cleanTitle,
          deadline: deadline,
        );

        await notificationService.scheduleTaskDueNotification(
          taskId: taskId,
          taskTitle: cleanTitle,
          deadline: deadline,
        );

        // Log notification scheduling
        await AppLogger.logNotification(
          'TaskReminder',
          title: 'Task Created / Task Overdue',
          body:
              'Task "$cleanTitle" scheduled with created and due notifications.',
          details: 'Created at ${DateTime.now()} for deadline $deadline',
        );

        debugPrint(
          "Event Listener Log: Notifications scheduled for $cleanTitle with task ID: $taskId",
        );
      }

      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      // Log the error
      await AppLogger.logError(
        'Task creation failed',
        errorCode: 'TASK_SAVE_ERROR',
        stackTrace: e.toString(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save task: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
