import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/routes/app_routes.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/widgets/app_illustration.dart';
import 'package:smart_study_planner/widgets/app_nav_drawer.dart';
import 'package:smart_study_planner/widgets/custom_button.dart';
import 'package:smart_study_planner/widgets/custom_text_field.dart';
import 'package:smart_study_planner/widgets/subject_card.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.subjects),
      appBar: AppBar(title: const Text('Subjects')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (appState.subjects.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: AppIllustration(
                icon: Icons.menu_book_rounded,
                title: 'No subjects yet',
                subtitle: 'Add your first subject to organize study tasks.',
                small: true,
              ),
            ),
          ...appState.subjects.map(
            (Subject subject) => SubjectCard(
              title: subject.name,
              subtitle:
                  '${appState.pendingCountBySubject(subject.id)} pending tasks',
              onTap: () {
                context.read<AppState>().setSelectedSubject(subject.id);
                Navigator.pushNamed(context, AppRoutes.subjectDetail);
              },
            ),
          ),
          CustomButton(
            label: 'Add Subject',
            icon: Icons.add,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addSubject),
          ),
        ],
      ),
    );
  }
}

class AddSubjectScreen extends StatelessWidget {
  const AddSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AddSubjectView();
}

class _AddSubjectView extends StatefulWidget {
  const _AddSubjectView();

  @override
  State<_AddSubjectView> createState() => _AddSubjectViewState();
}

class _AddSubjectViewState extends State<_AddSubjectView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavDrawer(currentRoute: AppRoutes.addSubject),
      appBar: AppBar(title: const Text('Add Subject')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            CustomTextField(controller: _nameController, label: 'Subject name'),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Save Subject',
              onPressed: () async {
                await context.read<AppState>().addSubject(_nameController.text);
                if (!context.mounted) {
                  return;
                }
                Navigator.pushReplacementNamed(context, AppRoutes.subjects);
              },
            ),
          ],
        ),
      ),
    );
  }
}
