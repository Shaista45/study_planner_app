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

    _selectedSubjectId ??= appState.selectedSubject?.id;
    _selectedSubjectId ??= subjects.isNotEmpty ? subjects.first.id : null;

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
                    'Add Note',
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
                      'Date and Time',
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
                label: 'Title',
                controller: _titleController,
                hint: 'Exam prep checklist',
              ),
              const SizedBox(height: 14),
              NoteInputField(
                label: 'Note Description',
                controller: _noteController,
                maxLines: 4,
                hint: 'Add details for this note...',
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              Text(
                'Color',
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
                title: const Text('Alarm'),
                value: _alarmEnabled,
                onChanged: (bool value) =>
                    setState(() => _alarmEnabled = value),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: AnimatedScaleButton(
                  onTap: subjects.isEmpty ? null : () => _saveNote(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryYellow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBrown,
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

    final String description = _noteController.text.trim();
    final String baseTitle = _titleController.text.trim();
    final String fallbackTitle =
        'Note on $_selectedDay/$_selectedMonth at $_selectedHour:${_selectedMinute.toString().padLeft(2, '0')} $_meridiem';
    final String title = baseTitle.isEmpty ? fallbackTitle : baseTitle;
    final String persistedTitle = description.isEmpty
        ? title
        : '$title - $description';

    await appState.addTask(
      title: persistedTitle,
      subjectId: _selectedSubjectId!,
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
