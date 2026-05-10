import 'package:flutter/material.dart';

class Subject {
  Subject({
    required this.id,
    required this.name,
    this.teacherName,
    this.studyHours,
  });

  final String id;
  final String name;
  final String? teacherName; // Added for 5.1 Subject Management
  final int? studyHours; // Added for 5.1 Subject Management

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherName: json['teacherName'] as String?,
      studyHours: json['studyHours'] as int?,
    );
  }

  Subject copyWith({
    String? id,
    String? name,
    String? teacherName,
    int? studyHours,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
      studyHours: studyHours ?? this.studyHours,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'teacherName': teacherName,
      'studyHours': studyHours,
    };
  }
}

class StudyTask {
  StudyTask({
    required this.id,
    required this.title,
    required this.subjectId,
    this.isCompleted = false,
    this.deadline,
    this.priorityLevel = 'Medium', // Added for 5.2 Task Management
  });

  final String id;
  final String title;
  final String subjectId;
  final bool isCompleted;
  final DateTime? deadline; // Added for 5.2 Task Management
  final String priorityLevel;

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'] as String,
      title: json['title'] as String,
      subjectId: json['subjectId'] as String,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      priorityLevel: json['priorityLevel'] as String? ?? 'Medium',
    );
  }

  StudyTask copyWith({
    String? id,
    String? title,
    String? subjectId,
    bool? isCompleted,
    DateTime? deadline,
    String? priorityLevel,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      priorityLevel: priorityLevel ?? this.priorityLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subjectId': subjectId,
      'isCompleted': isCompleted,
      'deadline': deadline?.toIso8601String(),
      'priorityLevel': priorityLevel,
    };
  }
}

class StudySession {
  final String id;
  final String subjectId;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}
