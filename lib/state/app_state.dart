import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_study_planner/models/models.dart';

class AppState extends ChangeNotifier {
  static const String _subjectsKey = 'subjects_v1';
  static const String _tasksKey = 'tasks_v1';

  final List<Subject> _subjects = <Subject>[];
  final List<StudyTask> _tasks = <StudyTask>[];

  String? _selectedSubjectId;
  String? _selectedTaskId;
  bool _isReady = false;

  static int _idCounter = 0;

  bool get isReady => _isReady;
  List<Subject> get subjects => List<Subject>.unmodifiable(_subjects);
  List<StudyTask> get tasks => List<StudyTask>.unmodifiable(_tasks);
  List<StudyTask> get pendingTasks =>
      _tasks.where((StudyTask task) => !task.isCompleted).toList();
  List<StudyTask> get completedTasks =>
      _tasks.where((StudyTask task) => task.isCompleted).toList();

  Subject? get selectedSubject {
    if (_subjects.isEmpty) {
      return null;
    }

    return _subjects.firstWhere(
      (Subject subject) => subject.id == _selectedSubjectId,
      orElse: () => _subjects.first,
    );
  }

  StudyTask? get selectedTask {
    if (_tasks.isEmpty) {
      return null;
    }

    return _tasks.firstWhere(
      (StudyTask task) => task.id == _selectedTaskId,
      orElse: () => _tasks.first,
    );
  }

  Future<void> initialize() async {
    if (_isReady) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedSubjects = prefs.getString(_subjectsKey);
    final String? savedTasks = prefs.getString(_tasksKey);

    if (savedSubjects != null && savedSubjects.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(savedSubjects) as List<dynamic>;
      _subjects
        ..clear()
        ..addAll(
          decoded.map(
            (dynamic item) => Subject.fromJson(item as Map<String, dynamic>),
          ),
        );
    }

    if (savedTasks != null && savedTasks.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(savedTasks) as List<dynamic>;
      _tasks
        ..clear()
        ..addAll(
          decoded.map(
            (dynamic item) => StudyTask.fromJson(item as Map<String, dynamic>),
          ),
        );
    }

    if (_subjects.isEmpty) {
      _seedDefaults();
      await _save();
    }

    _isReady = true;
    notifyListeners();
  }

  // UPDATED: Now accepts teacherName and studyHours
  Future<void> addSubject(
    String name, {
    String? teacherName,
    int? studyHours,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _subjects.add(
      Subject(
        id: _newId(),
        name: trimmed,
        teacherName: teacherName,
        studyHours: studyHours,
      ),
    );
    await _save();
    notifyListeners();
  }

  // UPDATED: Now accepts deadline and priorityLevel
  Future<void> addTask({
    required String title,
    required String subjectId,
    DateTime? deadline,
    String priorityLevel = 'Medium',
  }) async {
    final String trimmed = title.trim();
    if (trimmed.isEmpty || !_subjectExists(subjectId)) {
      return;
    }

    _tasks.add(
      StudyTask(
        id: _newId(),
        title: trimmed,
        subjectId: subjectId,
        deadline: deadline,
        priorityLevel: priorityLevel,
      ),
    );
    await _save();
    notifyListeners();
  }

  // UPDATED: Now accepts deadline and priorityLevel for editing tasks
  Future<void> updateTask({
    required String id,
    required String title,
    required String subjectId,
    DateTime? deadline,
    String priorityLevel = 'Medium',
  }) async {
    final int index = _tasks.indexWhere((StudyTask task) => task.id == id);
    if (index == -1) {
      return;
    }

    final String trimmed = title.trim();
    if (trimmed.isEmpty || !_subjectExists(subjectId)) {
      return;
    }

    _tasks[index] = _tasks[index].copyWith(
      title: trimmed,
      subjectId: subjectId,
      deadline: deadline,
      priorityLevel: priorityLevel,
    );
    await _save();
    notifyListeners();
  }

  Future<void> markTaskCompleted(String id) async {
    final int index = _tasks.indexWhere((StudyTask task) => task.id == id);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].copyWith(isCompleted: true);
    await _save();
    notifyListeners();
  }

  void setSelectedSubject(String? subjectId) {
    _selectedSubjectId = subjectId;
    notifyListeners();
  }

  void setSelectedTask(String? taskId) {
    _selectedTaskId = taskId;
    notifyListeners();
  }

  List<StudyTask> tasksForSubject(String subjectId) {
    return _tasks
        .where((StudyTask task) => task.subjectId == subjectId)
        .toList();
  }

  List<StudyTask> searchTasks(String query) {
    final String value = query.trim().toLowerCase();
    if (value.isEmpty) {
      return List<StudyTask>.unmodifiable(_tasks);
    }

    return _tasks
        .where((StudyTask task) => task.title.toLowerCase().contains(value))
        .toList();
  }

  String subjectName(String id) {
    return _subjects
        .firstWhere(
          (Subject subject) => subject.id == id,
          orElse: () => Subject(id: '', name: 'Unknown Subject'),
        )
        .name;
  }

  int pendingCountBySubject(String subjectId) {
    return _tasks
        .where(
          (StudyTask task) => task.subjectId == subjectId && !task.isCompleted,
        )
        .length;
  }

  void _seedDefaults() {
    final Subject math = Subject(
      id: _newId(),
      name: 'Mathematics',
      teacherName: 'Prof. Ahmed',
      studyHours: 4,
    );
    final Subject biology = Subject(
      id: _newId(),
      name: 'Biology',
      teacherName: 'Dr. Sarah',
      studyHours: 3,
    );

    _subjects
      ..clear()
      ..addAll(<Subject>[math, biology]);

    _tasks
      ..clear()
      ..addAll(<StudyTask>[
        StudyTask(
          id: _newId(),
          title: 'Practice derivatives',
          subjectId: math.id,
          priorityLevel: 'High',
          deadline: DateTime.now().add(const Duration(days: 2)),
        ),
        StudyTask(
          id: _newId(),
          title: 'Review probability notes',
          subjectId: math.id,
        ),
        StudyTask(
          id: _newId(),
          title: 'Read chapter 5 history',
          subjectId: biology.id,
          isCompleted: true,
        ),
      ]);
  }

  bool _subjectExists(String subjectId) {
    return _subjects.any((Subject subject) => subject.id == subjectId);
  }

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _subjectsKey,
      jsonEncode(_subjects.map((Subject item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _tasksKey,
      jsonEncode(_tasks.map((StudyTask item) => item.toJson()).toList()),
    );
  }

  String _newId() {
    _idCounter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }
}
