class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String startTime;
  final String endTime;
  final String day;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.day,
    this.isCompleted = false,
    required this.createdAt,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? startTime,
    String? endTime,
    String? day,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      day: day ?? this.day,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
      day: map['day'] as String? ?? '',
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'startTime': startTime,
      'endTime': endTime,
      'day': day,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'TaskModel(id: $id, title: $title, category: $category, '
      'startTime: $startTime, endTime: $endTime, day: $day)';
}
