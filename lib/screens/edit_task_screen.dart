import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/animated_scale_button.dart';
import 'package:smart_study_planner/widgets/note_input_field.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      final task = appState.selectedTask;

      if (task != null) {
        setState(() {
          String titleStr = task.title;
          String noteStr = '';
          if (titleStr.contains(' - ')) {
            final parts = titleStr.split(' - ');
            titleStr = parts.first;
            noteStr = parts.sublist(1).join(' - ');
          }

          _titleController.text = titleStr;
          _noteController.text = noteStr;
          _selectedSubjectId = task.subjectId;
          _selectedPriority = task.priorityLevel.isNotEmpty
              ? task.priorityLevel
              : 'Medium';

          if (task.deadline != null) {
            _selectedDate = task.deadline!;
            _selectedTime = TimeOfDay.fromDateTime(task.deadline!);
          }
        });
      }
    });
  }

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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOlive,
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

  // NEW: Confirmation Dialog before deleting
  void _showDeleteConfirmation(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Task',
          style: TextStyle(
            color: AppColors.deepBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: TextStyle(color: AppColors.deepBrown, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (appState.selectedTask != null) {
                // Calls the delete method from your AppState
                await appState.deleteTask(appState.selectedTask!.id);
              }
              if (context.mounted) {
                Navigator.pop(ctx); // Close the dialog
                Navigator.pop(context); // Close the edit screen
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
              // 1. HEADER
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Edit Task',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      if (appState.selectedTask != null) {
                        await appState.markTaskCompleted(
                          appState.selectedTask!.id,
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.primaryOlive,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. FORM AREA
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DEADLINE CONTAINER
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
                                onTap: _pickDate,
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
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: _pickTime,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TITLE
                      NoteInputField(
                        label: 'Task Title',
                        controller: _titleController,
                        hint: 'e.g., Complete Math Assignment',
                      ),
                      const SizedBox(height: 16),

                      // SUBJECT & PRIORITY
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
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedSubjectId,
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

                      // COLORS & ALARM
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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

                      // TASK DETAILS
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
                        decoration: InputDecoration(
                          hintText: 'Add details for this task...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // 3. ACTION BUTTONS (Update & Delete)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedScaleButton(
                      onTap: subjects.isEmpty
                          ? null
                          : () => _updateNote(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Update Task', // Renamed for clarity!
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBrown,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // NEW: Delete Task Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () =>
                          _showDeleteConfirmation(context, appState),
                      child: const Text(
                        'Delete Task',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateNote(BuildContext context) async {
    final AppState appState = context.read<AppState>();
    final currentTask = appState.selectedTask;

    if (currentTask == null || _selectedSubjectId == null) return;

    final DateTime deadline = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final String description = _noteController.text.trim();
    final String baseTitle = _titleController.text.trim();
    final String title = baseTitle.isEmpty ? 'Untitled Task' : baseTitle;
    final String persistedTitle = description.isEmpty
        ? title
        : '$title - $description';

    await appState.updateTask(
      id: currentTask.id,
      title: persistedTitle,
      subjectId: _selectedSubjectId!,
      deadline: deadline,
      priorityLevel: _selectedPriority,
    );

    if (!context.mounted) return;
    Navigator.pop(context);
  }
}
