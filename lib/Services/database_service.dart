import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart'; // Ensure this points to your models.dart

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the current user's root path
  DocumentReference get _userDoc =>
      _db.collection('users').doc(_auth.currentUser?.uid ?? 'unknown');

  // --- SUBJECTS ---

  // Get all subjects as a Stream
  Stream<List<Subject>> getSubjects() {
    return _userDoc.collection('subjects').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Subject.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new subject
  Future<void> addSubject(Subject subject) async {
    await _userDoc.collection('subjects').add(subject.toMap());
  }

  // --- TASKS ---

  // Get all tasks as a Stream
  Stream<List<StudyTask>> getTasks() {
    return _userDoc.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudyTask.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new task
  Future<void> addTask(StudyTask task) async {
    await _userDoc.collection('tasks').add(task.toMap());
  }

  // Update a task (e.g., toggling completion)
  Future<void> updateTask(StudyTask task) async {
    await _userDoc.collection('tasks').doc(task.id).update(task.toMap());
  }

  // --- SESSIONS ---

  // Add a study session
  Future<void> addSession(StudySession session) async {
    await _userDoc.collection('sessions').add(session.toMap());
  }
}
