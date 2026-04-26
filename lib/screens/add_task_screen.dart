import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/animated_scale_button.dart';
import 'package:smart_study_planner/widgets/note_input_field.dart';

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
  int _selectedDay = DateTime.now().day;
  int _selectedMonth = DateTime.now().month;
  int _selectedHour = 10;
  int _selectedMinute = 0;
  String _meridiem = 'AM';
  bool _alarmEnabled = true;
  int _selectedColor = 0;

  // UPDATED: Added state for Priority Level
  String _selectedPriority = 'Medium';

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                    ),
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
                            value: _meridiem,
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
              NoteInputField(
                label: 'Task Details',
                controller: _noteController,
                maxLines: 4,
                hint: 'Add details for this task...',
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
                value: _selectedSubjectId,
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

              // UPDATED: Priority Level Selector
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
              const SizedBox(height: 18),

              Text(
                'Color Tag',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: List<Widget>.generate(palette.length, (int index) {
                  final bool selected = _selectedColor == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 34 : 30,
                      height: selected ? 34 : 30,
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
                }),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primaryOlive,
                title: const Text('Set Reminder Alarm'),
                value: _alarmEnabled,
                onChanged: (bool value) =>
                    setState(() => _alarmEnabled = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AnimatedScaleButton(
                  onTap: subjects.isEmpty ? null : () => _saveNote(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryYellow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Task',
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

  Future<void> _saveNote(BuildContext context) async {
    final AppState appState = context.read<AppState>();

    if (_selectedSubjectId == null && appState.subjects.isNotEmpty) {
      _selectedSubjectId = appState.subjects.first.id;
    }

    if (_selectedSubjectId == null) {
      return;
    }

    // UPDATED: Convert the custom picker values into a real DateTime object
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

    final String description = _noteController.text.trim();
    final String baseTitle = _titleController.text.trim();
    final String title = baseTitle.isEmpty ? 'Untitled Task' : baseTitle;
    final String persistedTitle = description.isEmpty
        ? title
        : '$title - $description';

    // UPDATED: Passing the new deadline and priority variables to your state
    await appState.addTask(
      title: persistedTitle,
      subjectId: _selectedSubjectId!,
      deadline: deadline,
      priorityLevel: _selectedPriority,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed(AppRoutes.dashboard);
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
        value: value,
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
