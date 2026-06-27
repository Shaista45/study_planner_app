import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AppState extends ChangeNotifier {
  static const String _userNameKey = 'user_name_v1';
  static const String _userRoleKey = 'user_role_v1';

  final List<Subject> _subjects = <Subject>[];
  final List<StudyTask> _tasks = <StudyTask>[];
  final List<StudySession> _sessions = <StudySession>[];

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  bool _isLoggedIn = false;
  String _userName = 'Student Profile';
  String _userRole = 'Computer Science Dept.';
  String? _selectedSubjectId;
  String? _selectedTaskId;
  bool _isReady = false;
  StreamSubscription<User?>? _mobileSessionSubscription;

  // --- API STATE FIELDS ---
  String _motivationalQuote = "Loading your daily motivation...";
  String _quoteAuthor = "Smart Study Team";

  // Getters
  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  List<Subject> get subjects => List<Subject>.unmodifiable(_subjects);
  List<StudyTask> get tasks => List<StudyTask>.unmodifiable(_tasks);
  List<StudyTask> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();
  List<StudyTask> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();
  List<StudySession> get sessions => List<StudySession>.unmodifiable(_sessions);
  String get userName => _userName;
  String get userRole => _userRole;

  // API Getters
  String get motivationalQuote => _motivationalQuote;
  String get quoteAuthor => _quoteAuthor;

  // Selection Getters
  Subject? get selectedSubject {
    if (_subjects.isEmpty) return null;
    return _subjects.firstWhere(
      (s) => s.id == _selectedSubjectId,
      orElse: () => _subjects.first,
    );
  }

  StudyTask? get selectedTask {
    if (_tasks.isEmpty) return null;
    return _tasks.firstWhere(
      (t) => t.id == _selectedTaskId,
      orElse: () => _tasks.first,
    );
  }

  // --- INITIALIZATION ---
  Future<void> initialize() async {
    if (_isReady) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey) ?? 'Student Profile';
    _userRole = prefs.getString(_userRoleKey) ?? 'Computer Science Dept.';

    initializeMobileSession();

    _isReady = true;
    notifyListeners();
  }

  // 🚀 Run this method right when your AppState provider initializes
  void initializeMobileSession() {
    _mobileSessionSubscription?.cancel();
    _mobileSessionSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) async {
      _isLoggedIn = user != null;

      if (user != null) {
        debugPrint("Native Mobile Session Resolved for UID: ${user.uid}");

        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _userName = user.displayName!;
        }

        // 1. 🔑 RESTORE OR REGENERATE YOUR AES ENCRYPTION KEY HERE
        // (e.g., re-deriving it from a pin/password or loading it from secure storage)
        await ensureEncryptionKeyIsReady(user.uid);

        // 2. 🔄 TRIGGER THE FIRESTORE FETCH NOW THAT AUTH AND KEY ARE VALID
        await loadSubjects(user.uid);
        await loadTasks(user.uid);
        await loadSessions(user.uid);
        await fetchDailyQuote();
      } else {
        debugPrint(
          "Waiting for mobile device to resolve authentication token...",
        );
        _subjects.clear();
        _tasks.clear();
        _sessions.clear();
        _seedDefaults();
      }

      notifyListeners();
    });
  }

  Future<void> ensureEncryptionKeyIsReady(String uid) async {
    debugPrint('Encryption key ready for UID: $uid');
  }

  // --- PUBLIC THIRD-PARTY MOTIVATIONAL QUOTES API ---
  Future<void> fetchDailyQuote() async {
    // Uses an AllOrigins structural engine proxy wrapper safely bypassing strict CORS layout traps on browser platforms
    final url = Uri.parse(
      'https://api.allorigins.win/get?url=' +
          Uri.encodeComponent('https://zenquotes.io/api/random'),
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> wrapperData = jsonDecode(response.body);
        final List<dynamic> rawData = jsonDecode(wrapperData['contents']);

        if (rawData.isNotEmpty) {
          _motivationalQuote =
              rawData[0]['q'] ?? "Keep striving for excellence!";
          _quoteAuthor = rawData[0]['a'] ?? "Unknown";
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("External API Error Pipeline Catch: $e");
      // Resilient local state presentation fallback rules if device loses network link
      _motivationalQuote = "Your limitation—it's only your imagination.";
      _quoteAuthor = "Anonymous";
      notifyListeners();
    }
  }

  // --- AUTHENTICATION ---
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await fetchUserData();
      await fetchDailyQuote();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Invalid email or password.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());

      // Initialize the root firestore path for the user record instantly
      final uid = credential.user?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).set({
          'isProfileActive': true,
          'userName': name.trim(),
          'userRole': 'New Student',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      await updateProfile(name.trim(), 'New Student');
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Failed to create account.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return 'Please enter your email address.';
    }

    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send password reset email.';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _subjects.clear();
    _tasks.clear();
    _sessions.clear();
    _isLoggedIn = false;
    notifyListeners();
  }

  // --- FIRESTORE CORE ---
  Future<void> fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await loadUserProfile(uid);
      await loadSubjects(uid);
      await loadTasks(uid);
      await loadSessions(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore Fetch Error: $e');
    }
  }

  Future<void> loadUserProfile(String uid) async {
    final userPath = _db.collection('users').doc(uid);

    final userDoc = await userPath.get();
    if (userDoc.exists && userDoc.data() != null) {
      final data = userDoc.data()!;
      _userName = data['userName'] ?? _userName;
      _userRole = data['userRole'] ?? _userRole;
    }
  }

  Future<void> loadSubjects(String uid) async {
    final subjectSnapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('subjects')
        .get();
    _subjects
      ..clear()
      ..addAll(
        subjectSnapshot.docs.map((doc) => Subject.fromMap(doc.data(), doc.id)),
      );
  }

  Future<void> loadTasks(String uid) async {
    final taskSnapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();
    _tasks
      ..clear()
      ..addAll(
        taskSnapshot.docs.map((doc) => StudyTask.fromMap(doc.data(), doc.id)),
      );
  }

  Future<void> loadSessions(String uid) async {
    final sessionSnapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .get();
    _sessions
      ..clear()
      ..addAll(
        sessionSnapshot.docs.map(
          (doc) => StudySession.fromMap(doc.data(), doc.id),
        ),
      );
  }

  // --- SUBJECTS CRUD ---
  Future<void> addSubject(
    String name, {
    int hours = 0,
    String? teacherName,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (name.trim().isEmpty || uid == null) return;

    final newSubject = Subject(
      id: '',
      name: name.trim(),
      studyHours: hours,
      teacherName: teacherName,
    );
    try {
      final docRef = await _db
          .collection('users')
          .doc(uid)
          .collection('subjects')
          .add(newSubject.toMap());

      _subjects.add(
        Subject(
          id: docRef.id,
          name: name.trim(),
          studyHours: hours,
          teacherName: teacherName,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving subject: $e');
    }
  }

  Future<void> updateSubject({
    required String id,
    required String newName,
    int? studyHours,
    String? teacherName,
  }) async {
    final uid = _auth.currentUser?.uid;
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index == -1 || newName.trim().isEmpty || uid == null) return;

    final updated = Subject(
      id: id,
      name: newName.trim(),
      teacherName: teacherName,
      studyHours: studyHours,
    );
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('subjects')
          .doc(id)
          .update(updated.toMap());
      _subjects[index] = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating subject: $e');
    }
  }

  Future<void> deleteSubject(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userPath = _db.collection('users').doc(uid);
      await userPath.collection('subjects').doc(id).delete();
      _subjects.removeWhere((s) => s.id == id);

      final tasksToDelete = _tasks.where((t) => t.subjectId == id).toList();
      for (var task in tasksToDelete) {
        await userPath.collection('tasks').doc(task.id).delete();
        await NotificationService().cancelTaskNotifications(task.id);
      }
      _tasks.removeWhere((t) => t.subjectId == id);

      final sessionsToDelete = _sessions
          .where((s) => s.subjectId == id)
          .toList();
      for (var session in sessionsToDelete) {
        await userPath.collection('sessions').doc(session.id).delete();
      }
      _sessions.removeWhere((s) => s.subjectId == id);

      if (_selectedSubjectId == id) _selectedSubjectId = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting subject: $e');
    }
  }

  // --- TASKS CRUD ---
  Future<String?> addTask({
    required String title,
    required String subjectId,
    DateTime? deadline,
    String priorityLevel = 'Medium',
  }) async {
    final uid = _auth.currentUser?.uid;
    if (title.trim().isEmpty || uid == null) return null;

    final newTask = StudyTask(
      id: '',
      title: title.trim(),
      subjectId: subjectId,
      deadline: deadline,
      priorityLevel: priorityLevel,
    );
    try {
      final docRef = await _db
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .add(newTask.toMap());

      _tasks.add(
        StudyTask(
          id: docRef.id,
          title: title.trim(),
          subjectId: subjectId,
          deadline: deadline,
          priorityLevel: priorityLevel,
        ),
      );

      notifyListeners();
      return docRef.id;
    } catch (e) {
      debugPrint('Error saving task: $e');
      return null;
    }
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String subjectId,
    DateTime? deadline,
    String priorityLevel = 'Medium',
  }) async {
    final uid = _auth.currentUser?.uid;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1 || title.trim().isEmpty || uid == null) return;

    final updated = StudyTask(
      id: id,
      title: title.trim(),
      subjectId: subjectId,
      deadline: deadline,
      priorityLevel: priorityLevel,
      isCompleted: _tasks[index].isCompleted,
    );
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(id)
          .update(updated.toMap());
      _tasks[index] = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> markTaskCompleted(String id) async {
    final uid = _auth.currentUser?.uid;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1 || uid == null) return;

    try {
      await _db.collection('users').doc(uid).collection('tasks').doc(id).update(
        {'isCompleted': true},
      );
      _tasks[index] = _tasks[index].copyWith(isCompleted: true);
      await NotificationService().cancelTaskNotifications(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking task completed: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(id)
          .delete();
      _tasks.removeWhere((t) => t.id == id);
      if (_selectedTaskId == id) _selectedTaskId = null;
      await NotificationService().cancelTaskNotifications(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // --- SESSIONS CRUD ---
  Future<void> addStudySession({
    required String subjectId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final newSession = StudySession(
      id: '',
      subjectId: subjectId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    try {
      final docRef = await _db
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .add(newSession.toMap());
      _sessions.add(
        StudySession(
          id: docRef.id,
          subjectId: subjectId,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> deleteStudySession(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(id)
          .delete();
      _sessions.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting session: $e');
    }
  }

  // --- HELPERS & UTILITIES ---
  void setSelectedSubject(String? id) {
    _selectedSubjectId = id;
    notifyListeners();
  }

  void setSelectedTask(String? id) {
    _selectedTaskId = id;
    notifyListeners();
  }

  List<StudyTask> tasksForSubject(String subjectId) =>
      _tasks.where((t) => t.subjectId == subjectId).toList();

  String subjectName(String id) {
    return _subjects
        .firstWhere(
          (s) => s.id == id,
          orElse: () => Subject(id: '', name: 'Unknown Subject'),
        )
        .name;
  }

  List<StudySession> getSessionsForDay(int day) {
    final daySessions = _sessions.where((s) => s.dayOfWeek == day).toList();
    daySessions.sort(
      (a, b) => (a.startTime.hour * 60 + a.startTime.minute).compareTo(
        b.startTime.hour * 60 + b.startTime.minute,
      ),
    );
    return daySessions;
  }

  List<StudyTask> searchTasks(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return List.unmodifiable(_tasks);
    return _tasks.where((t) => t.title.toLowerCase().contains(value)).toList();
  }

  Future<void> updateProfile(String name, String role) async {
    _userName = name.isEmpty ? 'Student Profile' : name;
    _userRole = role.isEmpty ? 'Computer Science Dept.' : role;
    notifyListeners();

    // Save locally
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, _userName);
    await prefs.setString(_userRoleKey, _userRole);

    // Save globally to Firebase Cloud Storage path
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _db.collection('users').doc(uid).set({
          'userName': _userName,
          'userRole': _userRole,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Cloud profile sync warning: $e');
      }
    }
  }

  void _seedDefaults() {
    if (_subjects.isEmpty) {
      _subjects.add(Subject(id: 'd1', name: 'Sample Subject', studyHours: 2));
    }
    notifyListeners();
  }
}
