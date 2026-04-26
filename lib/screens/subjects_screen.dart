import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/screens/subject_detail_screen.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/widgets/animated_scale_button.dart';
import 'package:smart_study_planner/widgets/note_input_field.dart';

class SubjectsScreen extends StatelessWidget {
  // UPDATED: Added scrollController parameter
  const SubjectsScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  void _showAddSubjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const _AddSubjectForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final List<Subject> subjects = appState.subjects;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondaryYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _showAddSubjectSheet(context),
        icon: const Icon(Icons.add, color: AppColors.deepBrown),
        label: const Text(
          "Add Subject",
          style: TextStyle(
            color: AppColors.deepBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'My Subjects',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: subjects.isEmpty
                  ? Center(
                      child: Text(
                        'No subjects added yet.\nTap + to create one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.deepBrown.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      // UPDATED: Passed the scroll controller to the list view
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final Subject subject = subjects[index];
                        final int pendingTasks = appState.pendingCountBySubject(
                          subject.id,
                        );

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubjectDetailScreen(subjectId: subject.id),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
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
                              border: Border.all(
                                color: AppColors.primaryOlive.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subject.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.deepBrown,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pendingTasks > 0
                                            ? AppColors.accentOrange.withValues(
                                                alpha: 0.2,
                                              )
                                            : AppColors.primaryOlive.withValues(
                                                alpha: 0.2,
                                              ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$pendingTasks Pending',
                                        style: TextStyle(
                                          color: pendingTasks > 0
                                              ? AppColors.accentOrange
                                              : AppColors.primaryOlive,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 18,
                                      color: AppColors.primaryOlive,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      subject.teacherName?.isNotEmpty == true
                                          ? subject.teacherName!
                                          : 'Teacher not set',
                                      style: TextStyle(
                                        color: AppColors.deepBrown.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 18,
                                      color: AppColors.primaryOlive,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      subject.studyHours != null
                                          ? '${subject.studyHours} Hours/Week'
                                          : 'Hours not set',
                                      style: TextStyle(
                                        color: AppColors.deepBrown.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

// -----------------------------------------------------------------------------
// Form Widget for adding a new subject (pops up from the bottom)
// -----------------------------------------------------------------------------
class _AddSubjectForm extends StatefulWidget {
  const _AddSubjectForm();

  @override
  State<_AddSubjectForm> createState() => _AddSubjectFormState();
}

class _AddSubjectFormState extends State<_AddSubjectForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _saveSubject() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) return;

    final String teacher = _teacherController.text.trim();
    final int? hours = int.tryParse(_hoursController.text.trim());

    // Save to global state
    context.read<AppState>().addSubject(
      name,
      teacherName: teacher.isNotEmpty ? teacher : null,
      studyHours: hours,
    );

    // Close the bottom sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // This padding ensures the form moves up when the keyboard opens
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add New Subject',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.deepBrown,
              ),
            ),
            const SizedBox(height: 20),
            NoteInputField(
              label: 'Subject Name (Required)',
              controller: _nameController,
              hint: 'e.g., Mathematics',
            ),
            const SizedBox(height: 16),
            NoteInputField(
              label: 'Teacher Name (Optional)',
              controller: _teacherController,
              hint: 'e.g., Prof. Ahmed',
            ),
            const SizedBox(height: 16),
            // Custom input for numbers
            Text(
              'Study Hours / Week (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.deepBrown,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 4',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AnimatedScaleButton(
                onTap: _saveSubject,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOlive,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Save Subject',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
