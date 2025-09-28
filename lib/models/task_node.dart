import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TaskStatus { todo, inProgress, review, done, blocked }
enum TaskPriority { low, medium, high, critical }

class TaskNode {
  final String id;
  final String projectId;
  final String? parentId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? startDate;
  final DateTime dueDate;
  final DateTime? completedDate;
  final double progress;
  final int position;
  final int depth;
  final double? estimatedHours;
  final double? actualHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TaskNode> children;
  bool isExpanded;

  TaskNode({
    String? id,
    required this.projectId,
    this.parentId,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assigneeId,
    this.startDate,
    required this.dueDate,
    this.completedDate,
    this.progress = 0.0,
    this.position = 0,
    this.depth = 0,
    this.estimatedHours,
    this.actualHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TaskNode>? children,
    this.isExpanded = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        children = children ?? [];

  factory TaskNode.fromMap(Map<String, dynamic> map) {
    return TaskNode(
      id: map['id'],
      projectId: map['project_id'],
      parentId: map['parent_id'],
      title: map['title'],
      description: map['description'] ?? '',
      status: TaskStatus.values.firstWhere(
        (s) => s.toString().split('.').last == map['status'],
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.toString().split('.').last == map['priority'],
      ),
      assigneeId: map['assignee_id'],
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      dueDate: DateTime.parse(map['due_date']),
      completedDate: map['completed_date'] != null 
          ? DateTime.parse(map['completed_date']) 
          : null,
      progress: map['progress'] ?? 0.0,
      position: map['position'] ?? 0,
      depth: map['depth'] ?? 0,
      estimatedHours: map['estimated_hours']?.toDouble(),
      actualHours: map['actual_hours']?.toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      children: [], // Always start with empty mutable list
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'parent_id': parentId,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'assignee_id': assigneeId,
      'start_date': startDate?.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'progress': progress,
      'position': position,
      'depth': depth,
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TaskNode copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedDate,
    double? progress,
    int? position,
    double? estimatedHours,
    double? actualHours,
    List<TaskNode>? children,
    bool? isExpanded,
  }) {
    return TaskNode(
      id: id,
      projectId: projectId,
      parentId: parentId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      progress: progress ?? this.progress,
      position: position ?? this.position,
      depth: depth,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      children: children ?? List<TaskNode>.from(this.children),
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Duration get timeRemaining => dueDate.difference(DateTime.now());
  
  bool get isOverdue => 
      DateTime.now().isAfter(dueDate) && status != TaskStatus.done;

  Color get statusColor {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.review:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.critical:
        return Colors.purple;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case TaskStatus.todo:
        return Icons.circle_outlined;
      case TaskStatus.inProgress:
        return Icons.access_time;
      case TaskStatus.review:
        return Icons.rate_review;
      case TaskStatus.done:
        return Icons.check_circle;
      case TaskStatus.blocked:
        return Icons.block;
    }
  }
}