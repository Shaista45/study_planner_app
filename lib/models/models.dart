import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_study_planner/utils/encryption_service.dart';

class Subject {
  final String id;
  final String name;
  final int? studyHours;
  final String? teacherName;

  Subject({
    required this.id,
    required this.name,
    this.studyHours,
    this.teacherName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': EncryptionService.encrypt(name),
      'studyHours': studyHours,
      'teacherName': teacherName != null
          ? EncryptionService.encrypt(teacherName!)
          : null,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map, String documentId) {
    return Subject(
      id: documentId,
      name: EncryptionService.decrypt(map['name'] ?? ''),
      studyHours: map['studyHours'],
      teacherName: map['teacherName'] != null
          ? EncryptionService.decrypt(map['teacherName'])
          : null,
    );
  }
}

class StudyTask {
  final String id;
  final String title;
  final String subjectId;
  final DateTime? deadline;
  final String priorityLevel;
  final bool isCompleted;

  StudyTask({
    required this.id,
    required this.title,
    required this.subjectId,
    this.deadline,
    this.priorityLevel = 'Medium',
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': EncryptionService.encrypt(title),
      'subjectId': subjectId,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'priorityLevel': priorityLevel,
      'isCompleted': isCompleted,
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> map, String documentId) {
    return StudyTask(
      id: documentId,
      title: EncryptionService.decrypt(map['title'] ?? ''),
      subjectId: map['subjectId'] ?? '',
      deadline: map['deadline'] != null
          ? (map['deadline'] as Timestamp).toDate()
          : null,
      priorityLevel: map['priorityLevel'] ?? 'Medium',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  StudyTask copyWith({
    String? id,
    String? title,
    String? subjectId,
    DateTime? deadline,
    String? priorityLevel,
    bool? isCompleted,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      deadline: deadline ?? this.deadline,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class StudySession {
  final String id;
  final String subjectId;
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'dayOfWeek': dayOfWeek,
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map, String documentId) {
    return StudySession(
      id: documentId,
      subjectId: map['subjectId'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? 1,
      startTime: TimeOfDay(
        hour: map['startTime']['hour'] ?? 0,
        minute: map['startTime']['minute'] ?? 0,
      ),
      endTime: TimeOfDay(
        hour: map['endTime']['hour'] ?? 0,
        minute: map['endTime']['minute'] ?? 0,
      ),
    );
  }
}
