import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW: Firebase Import

class AppState extends ChangeNotifier {
  static const String _subjectsKey = 'subjects_v1';
  static const String _tasksKey = 'tasks_v1';
  static const String _userNameKey = 'user_name_v1';
  static const String _userRoleKey = 'user_role_v1';

  final List<Subject> _subjects = <Subject>[];
  final List<StudyTask> _tasks = <StudyTask>[];
  final List<StudySession> _sessions = [];

  bool _isLoggedIn = false;
  String _userName = 'Student Profile';
  String _userRole = 'Computer Science Dept.';
  String? _selectedSubjectId;
  String? _selectedTaskId;
  bool _isReady = false;
  static int _idCounter = 0;

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  List<Subject> get subjects => List<Subject>.unmodifiable(_subjects);
  List<StudyTask> get tasks => List<StudyTask>.unmodifiable(_tasks);
  List<StudyTask> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();
  List<StudyTask> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  String get userName => _userName;
  String get userRole => _userRole;
  List<StudySession> get sessions => _sessions;

  Subject? get selectedSubject {
    if (_subjects.isEmpty) return null;
    return _subjects.firstWhere(
      (subject) => subject.id == _selectedSubjectId,
      orElse: () => _subjects.first,
    );
  }

  StudyTask? get selectedTask {
    if (_tasks.isEmpty) return null;
    return _tasks.firstWhere(
      (task) => task.id == _selectedTaskId,
      orElse: () => _tasks.first,
    );
  }

  Future<void> initialize() async {
    if (_isReady) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _userName = prefs.getString(_userNameKey) ?? 'Student Profile';
    _userRole = prefs.getString(_userRoleKey) ?? 'Computer Science Dept.';

    final String? savedSubjects = prefs.getString(_subjectsKey);
    final String? savedTasks = prefs.getString(_tasksKey);

    if (kIsWeb) {
      _isLoggedIn = false;

      if (savedSubjects != null && savedSubjects.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedSubjects);
        _subjects.addAll(decoded.map((item) => Subject.fromJson(item)));
      }

      if (savedTasks != null && savedTasks.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedTasks);
        _tasks.addAll(decoded.map((item) => StudyTask.fromJson(item)));
      }

      if (_subjects.isEmpty) {
        _seedDefaults();
        await _save();
      }

      _isReady = true;
      notifyListeners();
      return;
    }

    // NEW: Listen to Firebase Auth state in real-time!
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _isLoggedIn = user != null;
      if (user != null &&
          user.displayName != null &&
          user.displayName!.isNotEmpty) {
        _userName = user.displayName!;
      }
      notifyListeners();
    });

    if (savedSubjects != null && savedSubjects.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(savedSubjects);
      _subjects.addAll(decoded.map((item) => Subject.fromJson(item)));
    }

    if (savedTasks != null && savedTasks.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(savedTasks);
      _tasks.addAll(decoded.map((item) => StudyTask.fromJson(item)));
    }

    if (_subjects.isEmpty) {
      _seedDefaults();
      await _save();
    }

    _isReady = true;
    notifyListeners();
  }

  // --- NEW FIREBASE AUTH METHODS ---
  Future<void> login(String email, String password) async {
    if (kIsWeb) {
      _isLoggedIn = true;
      _userName = email.trim().split('@').first;
      notifyListeners();
      return;
    }

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    if (kIsWeb) {
      _isLoggedIn = true;
      _userName = name.trim().isEmpty
          ? email.trim().split('@').first
          : name.trim();
      _userRole = 'New Student';
      await updateProfile(_userName, _userRole);
      notifyListeners();
      return;
    }

    UserCredential credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
    // Save their name to their Firebase profile
    await credential.user?.updateDisplayName(name.trim());
    await updateProfile(name.trim(), 'New Student');
  }

  Future<void> logout() async {
    if (kIsWeb) {
      _isLoggedIn = false;
      notifyListeners();
      return;
    }

    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
  // ---------------------------------

  // Get sessions for a specific day and sort them by start time
  List<StudySession> getSessionsForDay(int dayOfWeek) {
    final daySessions = _sessions
        .where((s) => s.dayOfWeek == dayOfWeek)
        .toList();
    daySessions.sort(
      (a, b) => (a.startTime.hour * 60 + a.startTime.minute).compareTo(
        b.startTime.hour * 60 + b.startTime.minute,
      ),
    );
    return daySessions;
  }

  Future<void> addStudySession({
    required String subjectId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final newSession = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      subjectId: subjectId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    _sessions.add(newSession);
    notifyListeners();
  }

  Future<void> deleteStudySession(String id) async {
    _sessions.removeWhere((session) => session.id == id);
    notifyListeners();
  }

  Future<void> updateProfile(String name, String role) async {
    _userName = name.isEmpty ? 'Student Profile' : name;
    _userRole = role.isEmpty ? 'Computer Science Dept.' : role;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, _userName);
    await prefs.setString(_userRoleKey, _userRole);
  }

  Future<void> addSubject(
    String name, {
    int hours = 0,
    String? teacherName,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final Subject newSubject = Subject(
      id: _newId(),
      name: trimmed,
      studyHours: hours,
      teacherName: teacherName,
    );

    _subjects.add(newSubject);
    await _save();
    notifyListeners();
  }

  Future<void> updateSubject({
    required String id,
    required String newName,
    int? studyHours,
    String? teacherName,
  }) async {
    final int index = _subjects.indexWhere((subject) => subject.id == id);
    if (index == -1) return;

    final String trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    _subjects[index] = Subject(
      id: id,
      name: trimmed,
      teacherName: teacherName,
      studyHours: studyHours,
    );

    await _save();
    notifyListeners();
  }

  Future<void> deleteSubject(String id) async {
    final int beforeSubjects = _subjects.length;
    _subjects.removeWhere((subject) => subject.id == id);
    final bool removedSubject = _subjects.length < beforeSubjects;
    if (!removedSubject) return;

    final List<String> removedTaskIds = _tasks
        .where((task) => task.subjectId == id)
        .map((task) => task.id)
        .toList();
    _tasks.removeWhere((task) => task.subjectId == id);

    for (final taskId in removedTaskIds) {
      await NotificationService().cancelNotification(taskId.hashCode);
      if (_selectedTaskId == taskId) {
        _selectedTaskId = _tasks.isNotEmpty ? _tasks.first.id : null;
      }
    }

    if (_selectedSubjectId == id) {
      _selectedSubjectId = _subjects.isNotEmpty ? _subjects.first.id : null;
    }

    await _save();
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String subjectId,
    DateTime? deadline,
    String priorityLevel = 'Medium',
  }) async {
    final String trimmed = title.trim();
    if (trimmed.isEmpty || !_subjectExists(subjectId)) return;

    final String newTaskId = _newId();
    _tasks.add(
      StudyTask(
        id: newTaskId,
        title: trimmed,
        subjectId: subjectId,
        deadline: deadline,
        priorityLevel: priorityLevel,
      ),
    );

    if (deadline != null) {
      final DateTime reminderTime = deadline.subtract(const Duration(hours: 1));
      try {
        await NotificationService().scheduleNotification(
          id: newTaskId.hashCode,
          title: 'Study Reminder',
          body: 'Your task "$trimmed" is due in 1 hour!',
          scheduledDate: reminderTime,
        );
      } catch (e) {
        debugPrint('Failed to schedule: $e');
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String subjectId,
    DateTime? deadline,
    String priorityLevel = 'Medium',
  }) async {
    final int index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final String trimmed = title.trim();
    if (trimmed.isEmpty || !_subjectExists(subjectId)) return;

    _tasks[index] = _tasks[index].copyWith(
      title: trimmed,
      subjectId: subjectId,
      deadline: deadline,
      priorityLevel: priorityLevel,
    );

    if (deadline != null) {
      final DateTime reminderTime = deadline.subtract(const Duration(hours: 1));
      try {
        await NotificationService().scheduleNotification(
          id: id.hashCode,
          title: 'Study Reminder',
          body: 'Your task "$trimmed" is due in 1 hour!',
          scheduledDate: reminderTime,
        );
      } catch (e) {
        debugPrint('Failed to update: $e');
      }
    } else {
      await NotificationService().cancelNotification(id.hashCode);
    }
    await _save();
    notifyListeners();
  }

  Future<void> markTaskCompleted(String id) async {
    final int index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(isCompleted: true);
    await NotificationService().cancelNotification(id.hashCode);
    await _save();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final int before = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    final bool removed = _tasks.length < before;
    if (!removed) return;

    if (_selectedTaskId == id) {
      _selectedTaskId = _tasks.isNotEmpty ? _tasks.first.id : null;
    }

    await NotificationService().cancelNotification(id.hashCode);
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

  List<StudyTask> tasksForSubject(String subjectId) =>
      _tasks.where((task) => task.subjectId == subjectId).toList();
  List<StudyTask> searchTasks(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return List.unmodifiable(_tasks);
    return _tasks
        .where((task) => task.title.toLowerCase().contains(value))
        .toList();
  }

  String subjectName(String id) => _subjects
      .firstWhere(
        (subject) => subject.id == id,
        orElse: () => Subject(id: '', name: 'Unknown Subject'),
      )
      .name;
  int pendingCountBySubject(String subjectId) => _tasks
      .where((task) => task.subjectId == subjectId && !task.isCompleted)
      .length;

  void _seedDefaults() {
    final math = Subject(
      id: _newId(),
      name: 'Mathematics',
      teacherName: 'Prof. Ahmed',
      studyHours: 4,
    );
    final biology = Subject(
      id: _newId(),
      name: 'Biology',
      teacherName: 'Dr. Sarah',
      studyHours: 3,
    );
    _subjects
      ..clear()
      ..addAll([math, biology]);
    _tasks
      ..clear()
      ..addAll([
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

  bool _subjectExists(String subjectId) =>
      _subjects.any((subject) => subject.id == subjectId);

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _subjectsKey,
      jsonEncode(_subjects.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _tasksKey,
      jsonEncode(_tasks.map((item) => item.toJson()).toList()),
    );
  }

  String _newId() {
    _idCounter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }
}
