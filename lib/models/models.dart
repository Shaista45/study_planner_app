class Subject {
  Subject({required this.id, required this.name});

  final String id;
  final String name;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(id: json['id'] as String, name: json['name'] as String);
  }

  Subject copyWith({String? id, String? name}) {
    return Subject(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name};
  }
}

class StudyTask {
  StudyTask({
    required this.id,
    required this.title,
    required this.subjectId,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subjectId;
  final bool isCompleted;

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'] as String,
      title: json['title'] as String,
      subjectId: json['subjectId'] as String,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
    );
  }

  StudyTask copyWith({
    String? id,
    String? title,
    String? subjectId,
    bool? isCompleted,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subjectId': subjectId,
      'isCompleted': isCompleted,
    };
  }
}
