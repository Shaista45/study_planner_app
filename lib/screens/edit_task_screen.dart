import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
// REMOVED unused app_routes import
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/animated_scale_button.dart';
import 'package:smart_study_planner/widgets/note_input_field.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController _titleController = TextEditingController();

  String? _selectedSubjectId;
  int _selectedDay = DateTime.now().day;
  int _selectedMonth = DateTime.now().month;
  int _selectedHour = 10;
  int _selectedMinute = 0;
  String _meridiem = 'AM';
  String _selectedPriority = 'Medium';
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final appState = context.read<AppState>();
      final task = appState.selectedTask;

      if (task != null) {
        _titleController.text = task.title;
        _selectedSubjectId = task.subjectId;
        _selectedPriority = task.priorityLevel;

        if (task.deadline != null) {
          _selectedDay = task.deadline!.day;
          _selectedMonth = task.deadline!.month;

          int h = task.deadline!.hour;
          _meridiem = h >= 12 ? 'PM' : 'AM';
          if (h == 0) {
            _selectedHour = 12;
          } else if (h > 12) {
            _selectedHour = h - 12;
          } else {
            _selectedHour = h;
          }
          _selectedMinute = task.deadline!.minute;
        }
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final List<Subject> subjects = appState.subjects;
    final StudyTask? task = appState.selectedTask;

    if (task == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit Task',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (!task.isCompleted)
                    IconButton(
                      onPressed: () {
                        appState.markTaskCompleted(task.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.primaryOlive,
                        size: 28,
                      ),
                      tooltip: 'Mark as Completed',
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Deadline',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _pickerChip(
                          label: 'Day',
                          value: _selectedDay,
                          max: 31,
                          onChanged: (int v) =>
                              setState(() => _selectedDay = v),
                        ),
                        _pickerChip(
                          label: 'Month',
                          value: _selectedMonth,
                          max: 12,
                          onChanged: (int v) =>
                              setState(() => _selectedMonth = v),
                        ),
                        _pickerChip(
                          label: 'Hour',
                          value: _selectedHour,
                          min: 1,
                          max: 12,
                          onChanged: (int v) =>
                              setState(() => _selectedHour = v),
                        ),
                        _pickerChip(
                          label: 'Minute',
                          value: _selectedMinute,
                          min: 0,
                          max: 59,
                          padTwoDigits: true,
                          onChanged: (int v) =>
                              setState(() => _selectedMinute = v),
                        ),
                        SizedBox(
                          width: 104,
                          child: DropdownButtonFormField<String>(
                            initialValue:
                                _meridiem, // FIX: Changed 'value' to 'initialValue'
                            items: const <String>['AM', 'PM']
                                .map(
                                  (String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() => _meridiem = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NoteInputField(
                label: 'Task Title',
                controller: _titleController,
                hint: 'e.g., Complete Math Assignment',
              ),
              const SizedBox(height: 14),

              // Subject Dropdown
              Text(
                'Subject',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue:
                    _selectedSubjectId, // FIX: Changed 'value' to 'initialValue'
                decoration: const InputDecoration(hintText: 'Choose subject'),
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
              const SizedBox(height: 18),

              // Priority Level Selector
              Text(
                'Priority Level',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Low', 'Medium', 'High'].map((String priority) {
                  final bool isSelected = _selectedPriority == priority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(priority),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: priority == 'High'
                          ? AppColors.accentOrange
                          : (priority == 'Medium'
                                ? AppColors.secondaryYellow
                                : AppColors.primaryOlive),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected && priority != 'Medium'
                            ? Colors.white
                            : AppColors.deepBrown,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() => _selectedPriority = priority);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: AnimatedScaleButton(
                  onTap: subjects.isEmpty
                      ? null
                      : () => _updateTask(context, task.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryYellow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBrown,
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

  Future<void> _updateTask(BuildContext context, String taskId) async {
    final AppState appState = context.read<AppState>();

    if (_selectedSubjectId == null) {
      return;
    }

    int hour24 = _selectedHour;
    if (_meridiem == 'PM' && _selectedHour != 12) {
      hour24 += 12;
    } else if (_meridiem == 'AM' && _selectedHour == 12) {
      hour24 = 0;
    }

    final DateTime deadline = DateTime(
      DateTime.now().year,
      _selectedMonth,
      _selectedDay,
      hour24,
      _selectedMinute,
    );

    final String title = _titleController.text.trim();
    final String finalTitle = title.isEmpty ? 'Untitled Task' : title;

    await appState.updateTask(
      id: taskId,
      title: finalTitle,
      subjectId: _selectedSubjectId!,
      deadline: deadline,
      priorityLevel: _selectedPriority,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Widget _pickerChip({
    required String label,
    required int value,
    int min = 1,
    required int max,
    bool padTwoDigits = false,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 96,
      child: DropdownButtonFormField<int>(
        initialValue: value, // FIX: Changed 'value' to 'initialValue'
        decoration: InputDecoration(labelText: label),
        items: List<DropdownMenuItem<int>>.generate(max - min + 1, (int index) {
          final int itemValue = min + index;
          final String text = padTwoDigits
              ? itemValue.toString().padLeft(2, '0')
              : '$itemValue';
          return DropdownMenuItem<int>(value: itemValue, child: Text(text));
        }),
        onChanged: (int? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }
}
