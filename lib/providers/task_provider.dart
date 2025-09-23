import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => [..._tasks];

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate.year == today.year &&
          task.dueDate.month == today.month &&
          task.dueDate.day == today.day;
    }).toList();
  }

  List<Task> get upcomingTasks {
    return _tasks.where((task) {
      return task.dueDate.isAfter(DateTime.now()) &&
          task.status != TaskStatus.done;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate.isBefore(now) && task.status != TaskStatus.done;
    }).toList();
  }

  TaskProvider() {
    _initializeSampleTasks();
  }

  void _initializeSampleTasks() {
    _tasks.addAll([
      Task(
        title: 'Sprint Planning Meeting',
        description: 'Plan next sprint with the development team',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: TaskPriority.high,
        color: Colors.blue,
        tags: ['meeting', 'sprint'],
        assignedTo: ['John', 'Sarah', 'Mike'],
      ),
      Task(
        title: 'Code Review',
        description: 'Review pull requests for authentication module',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: TaskPriority.medium,
        color: Colors.orange,
        tags: ['development', 'review'],
        assignedTo: ['John'],
      ),
      Task(
        title: 'Update Documentation',
        description: 'Update API documentation for v2.0',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.low,
        color: Colors.green,
        tags: ['documentation'],
        assignedTo: ['Sarah'],
      ),
      Task(
        title: 'Bug Fix: Login Issue',
        description: 'Fix critical login bug reported by QA',
        dueDate: DateTime.now(),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        color: Colors.red,
        tags: ['bug', 'critical'],
        assignedTo: ['Mike'],
      ),
    ]);
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void toggleTaskStatus(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      TaskStatus newStatus;
      DateTime? completedAt;

      switch (task.status) {
        case TaskStatus.todo:
          newStatus = TaskStatus.inProgress;
          break;
        case TaskStatus.inProgress:
          newStatus = TaskStatus.done;
          completedAt = DateTime.now();
          break;
        case TaskStatus.done:
          newStatus = TaskStatus.todo;
          completedAt = null;
          break;
      }

      _tasks[index] = task.copyWith(
        status: newStatus,
        completedAt: completedAt,
      );
      notifyListeners();
    }
  }
}