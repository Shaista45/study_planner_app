import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/screens/subject_detail_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  // --- BOTTOM SHEET FOR ADDING OR EDITING ---
  void _showSubjectSheet(
    BuildContext context,
    AppState appState, {
    Subject? subjectToEdit,
  }) {
    final TextEditingController nameController = TextEditingController(
      text: subjectToEdit?.name ?? '',
    );
    final TextEditingController hoursController = TextEditingController(
      text: subjectToEdit?.studyHours != null && subjectToEdit!.studyHours! > 0
          ? subjectToEdit.studyHours.toString()
          : '',
    );
    final TextEditingController teacherController = TextEditingController(
      text: subjectToEdit?.teacherName ?? '',
    );
    final bool isEditing = subjectToEdit != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
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
              Text(
                isEditing ? 'Edit Subject' : 'New Subject',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBrown,
                ),
              ),
              const SizedBox(height: 24),

              // Subject Name Text Field
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization
                    .words, // Capitalizes course initials automatically
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  labelStyle: const TextStyle(color: AppColors.primaryOlive),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(
                    Icons.book_outlined,
                    color: AppColors.primaryOlive,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Teacher Name Text Field
              TextField(
                controller: teacherController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Teacher Name (Optional)',
                  labelStyle: const TextStyle(color: AppColors.primaryOlive),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryOlive,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Study Hours Text Field
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Study Hours / Week (Optional)',
                  labelStyle: const TextStyle(color: AppColors.primaryOlive),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(
                    Icons.hourglass_empty_rounded,
                    color: AppColors.primaryOlive,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Action Button
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
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Subject name cannot be empty'),
                        ),
                      );
                      return;
                    }

                    final teacher = teacherController.text.trim();
                    final hours = int.tryParse(hoursController.text.trim());

                    // Close keyboard and sheet immediately to provide rapid UX transition
                    Navigator.pop(sheetContext);

                    try {
                      if (isEditing) {
                        await appState.updateSubject(
                          id: subjectToEdit.id,
                          newName: name,
                          studyHours: hours,
                          teacherName: teacher.isNotEmpty ? teacher : null,
                        );
                      } else {
                        await appState.addSubject(
                          name,
                          hours: hours ?? 0,
                          teacherName: teacher.isNotEmpty ? teacher : null,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to persist change: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    isEditing ? 'Save Changes' : 'Add Subject',
                    style: const TextStyle(
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
  }

  // --- DELETE CONFIRMATION ---
  void _showDeleteConfirmation(
    BuildContext context,
    AppState appState,
    Subject subject,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Subject?',
          style: TextStyle(
            color: AppColors.deepBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${subject.name}"? This will also delete ALL tasks associated with this subject.',
          style: const TextStyle(color: AppColors.deepBrown, height: 1.5),
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
              Navigator.pop(ctx); // Close dialog window first
              await appState.deleteSubject(subject.id);
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
    final appState = context.watch<AppState>();
    final subjects = appState.subjects;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondaryYellow,
        onPressed: () => _showSubjectSheet(context, appState),
        icon: const Icon(Icons.add, color: AppColors.deepBrown),
        label: const Text(
          "New Subject",
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
            // 1. HEADER NAV STRIP
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
                    'Manage Subjects',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),

            // 2. SUBJECTS DYNAMIC SCROLL CONTAINER
            Expanded(
              child: subjects.isEmpty
                  ? Center(
                      child: Text(
                        'No subjects added yet.',
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
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final Subject subject = subjects[index];
                        final int taskCount = appState
                            .tasksForSubject(subject.id)
                            .length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SubjectDetailScreen(
                                      subjectId: subject.id,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.primaryOlive,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Primary Meta Text Structure
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subject.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.deepBrown,
                                            ),
                                          ),
                                          if (subject.teacherName != null &&
                                              subject
                                                  .teacherName!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person_rounded,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  subject.teacherName!,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .secondaryYellow
                                                      .withValues(alpha: 0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '$taskCount Tasks',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: AppColors.deepBrown,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (subject.studyHours != null &&
                                                  subject.studyHours! > 0)
                                                Text(
                                                  '${subject.studyHours} hrs/wk',
                                                  style: TextStyle(
                                                    color: AppColors.deepBrown
                                                        .withValues(alpha: 0.6),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Local Execution Control Triggers
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_rounded,
                                            color: AppColors.primaryOlive,
                                            size: 22,
                                          ),
                                          onPressed: () => _showSubjectSheet(
                                            context,
                                            appState,
                                            subjectToEdit: subject,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                context,
                                                appState,
                                                subject,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
    );
  }
}
