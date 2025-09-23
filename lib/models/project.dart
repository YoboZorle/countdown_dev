import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ProjectStatus { planning, active, onHold, completed }

class Project {
  final String id;
  final String name;
  final String description;
  final Color color;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStatus status;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> memberIds;
  final int totalTasks;
  final int completedTasks;

  Project({
    String? id,
    required this.name,
    required this.description,
    required this.color,
    required this.startDate,
    required this.endDate,
    this.status = ProjectStatus.planning,
    this.progress = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.memberIds = const [],
    this.totalTasks = 0,
    this.completedTasks = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      color: Color(map['color']),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      status: ProjectStatus.values.firstWhere(
            (s) => s.toString().split('.').last == map['status'],
      ),
      progress: map['progress'] ?? 0.0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Project copyWith({
    String? name,
    String? description,
    Color? color,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    double? progress,
    List<String>? memberIds,
    int? totalTasks,
    int? completedTasks,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      memberIds: memberIds ?? this.memberIds,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }

  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays;
  }

  Duration get timeRemaining {
    return endDate.difference(DateTime.now());
  }

  bool get isOverdue {
    return DateTime.now().isAfter(endDate) && status != ProjectStatus.completed;
  }
}