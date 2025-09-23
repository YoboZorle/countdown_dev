import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final List<String> assignedTo;
  final List<String> tags;
  final Color color;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.status = TaskStatus.todo,
    this.assignedTo = const [],
    this.tags = const [],
    required this.color,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? assignedTo,
    List<String>? tags,
    Color? color,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}