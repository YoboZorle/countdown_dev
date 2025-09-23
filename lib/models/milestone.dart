import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Milestone {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool completed;
  final DateTime createdAt;

  Milestone({
    String? id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.completed = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'],
      projectId: map['project_id'],
      title: map['title'],
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['due_date']),
      completed: map['completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'completed': completed ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Milestone copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
  }) {
    return Milestone(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }

  bool get isOverdue => !completed && DateTime.now().isAfter(dueDate);

  Duration get timeRemaining => dueDate.difference(DateTime.now());

  IconData get icon {
    if (completed) return Icons.check_circle;
    if (isOverdue) return Icons.warning;
    return Icons.flag;
  }

  Color get color {
    if (completed) return Colors.green;
    if (isOverdue) return Colors.red;
    return Colors.blue;
  }
}