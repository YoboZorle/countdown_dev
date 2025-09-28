import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/project.dart';
import '../models/task_node.dart';

class ProjectProvider extends ChangeNotifier {
  final List<Project> _projects = [];
  final Map<String, List<TaskNode>> _projectTasks = {};
  Project? _selectedProject;
  TaskNode? _selectedTask;
  bool _isLoading = false;

  List<Project> get projects => [..._projects];
  Project? get selectedProject => _selectedProject;
  TaskNode? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;

  List<TaskNode> getProjectTasks(String projectId) {
    return _projectTasks[projectId] ?? [];
  }

  ProjectProvider() {
    loadProjects();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final projectMaps = await DatabaseHelper.instance.getProjects();
      _projects.clear();
      
      for (var projectMap in projectMaps) {
        final project = Project.fromMap(projectMap);
        _projects.add(project);
        
        // Load tasks for each project
        await loadProjectTasks(project.id);
      }
    } catch (e) {
      debugPrint('Error loading projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjectTasks(String projectId) async {
    try {
      final taskMaps = await DatabaseHelper.instance.getTaskNodes(projectId);
      final tasks = taskMaps.map((map) => TaskNode.fromMap(map)).toList();
      
      // Build task hierarchy
      _projectTasks[projectId] = _buildTaskHierarchy(tasks);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  List<TaskNode> _buildTaskHierarchy(List<TaskNode> flatTasks) {
    final Map<String, TaskNode> taskMap = {};
    final List<TaskNode> rootTasks = [];

    // First pass: create all task nodes with mutable children lists
    for (var task in flatTasks) {
      taskMap[task.id] = TaskNode(
        id: task.id,
        projectId: task.projectId,
        parentId: task.parentId,
        title: task.title,
        description: task.description,
        status: task.status,
        priority: task.priority,
        assigneeId: task.assigneeId,
        startDate: task.startDate,
        dueDate: task.dueDate,
        completedDate: task.completedDate,
        progress: task.progress,
        position: task.position,
        depth: task.depth,
        estimatedHours: task.estimatedHours,
        actualHours: task.actualHours,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
        children: [], // Ensure mutable list
        isExpanded: task.isExpanded,
      );
    }

    // Second pass: build hierarchy
    for (var task in flatTasks) {
      if (task.parentId == null) {
        rootTasks.add(taskMap[task.id]!);
      } else {
        final parent = taskMap[task.parentId];
        if (parent != null) {
          parent.children.add(taskMap[task.id]!);
        }
      }
    }

    // Sort by position
    rootTasks.sort((a, b) => a.position.compareTo(b.position));
    for (var task in taskMap.values) {
      task.children.sort((a, b) => a.position.compareTo(b.position));
    }

    return rootTasks;
  }

  Future<void> addProject(Project project) async {
    try {
      await DatabaseHelper.instance.insertProject(project.toMap());
      _projects.add(project);
      _projectTasks[project.id] = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding project: $e');
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await DatabaseHelper.instance.updateProject(project.toMap());
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await DatabaseHelper.instance.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      _projectTasks.remove(projectId);
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }

  Future<void> addTask(TaskNode task) async {
    try {
      await DatabaseHelper.instance.insertTaskNode(task.toMap());
      
      if (!_projectTasks.containsKey(task.projectId)) {
        _projectTasks[task.projectId] = [];
      }
      
      if (task.parentId == null) {
        _projectTasks[task.projectId]!.add(task);
      } else {
        // Find parent and add as child
        final parent = _findTaskInHierarchy(task.parentId!, task.projectId);
        if (parent != null) {
          parent.children.add(task);
          // Recalculate parent progress after adding child
          await updateTask(parent);
        }
      }
      
      // Update project progress
      await _updateProjectProgress(task.projectId);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  TaskNode? _findTaskInHierarchy(String taskId, String projectId) {
    final tasks = _projectTasks[projectId] ?? [];
    
    TaskNode? findInList(List<TaskNode> list) {
      for (var task in list) {
        if (task.id == taskId) return task;
        final found = findInList(task.children);
        if (found != null) return found;
      }
      return null;
    }
    
    return findInList(tasks);
  }

  Future<void> updateTask(TaskNode task) async {
    try {
      // Calculate progress based on children if it has any
      TaskNode updatedTask = task;
      if (task.children.isNotEmpty) {
        double childrenProgress = _calculateNodeProgress(task);
        updatedTask = task.copyWith(
          progress: childrenProgress,
          status: childrenProgress == 1.0 ? TaskStatus.done : task.status,
        );
      }
      
      await DatabaseHelper.instance.updateTaskNode(updatedTask.toMap());
      
      // Update in memory
      final existing = _findTaskInHierarchy(updatedTask.id, updatedTask.projectId);
      if (existing != null) {
        // Update the task in the hierarchy
        final parent = updatedTask.parentId != null 
            ? _findTaskInHierarchy(updatedTask.parentId!, updatedTask.projectId) 
            : null;
            
        if (parent != null) {
          final index = parent.children.indexWhere((t) => t.id == updatedTask.id);
          if (index != -1) {
            parent.children[index] = updatedTask;
          }
          // Recursively update parent progress
          await updateTask(parent);
        } else {
          final rootTasks = _projectTasks[updatedTask.projectId]!;
          final index = rootTasks.indexWhere((t) => t.id == updatedTask.id);
          if (index != -1) {
            rootTasks[index] = updatedTask;
          }
        }
      }
      
      // Update project progress
      await _updateProjectProgress(updatedTask.projectId);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  double _calculateNodeProgress(TaskNode node) {
    if (node.children.isEmpty) {
      // Leaf node - use its own progress or status
      if (node.status == TaskStatus.done) return 1.0;
      if (node.status == TaskStatus.blocked) return node.progress;
      return node.progress;
    }
    
    // Parent node - calculate based on children
    double totalProgress = 0.0;
    int totalChildren = 0;
    
    void calculateRecursively(List<TaskNode> nodes) {
      for (var child in nodes) {
        if (child.children.isEmpty) {
          // Leaf node contributes to progress
          totalProgress += child.status == TaskStatus.done ? 1.0 : child.progress;
          totalChildren++;
        } else {
          // Recursive calculation for nested children
          calculateRecursively(child.children);
        }
      }
    }
    
    calculateRecursively(node.children);
    
    return totalChildren > 0 ? totalProgress / totalChildren : 0.0;
  }

  Future<void> _updateProjectProgress(String projectId) async {
    final tasks = _getAllTasksFlat(projectId);
    if (tasks.isEmpty) return;
    
    // Calculate overall project progress based on all leaf tasks
    double totalProgress = 0.0;
    int leafTaskCount = 0;
    
    for (var task in tasks) {
      if (task.children.isEmpty) {
        totalProgress += task.status == TaskStatus.done ? 1.0 : task.progress;
        leafTaskCount++;
      }
    }
    
    final progress = leafTaskCount > 0 ? totalProgress / leafTaskCount : 0.0;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex != -1) {
      final project = _projects[projectIndex];
      final updatedProject = project.copyWith(
        progress: progress,
        totalTasks: tasks.length,
        completedTasks: completedTasks,
      );
      
      _projects[projectIndex] = updatedProject;
      await DatabaseHelper.instance.updateProject(updatedProject.toMap());
    }
  }

  List<TaskNode> _getAllTasksFlat(String projectId) {
    final tasks = <TaskNode>[];
    
    void addTasksRecursively(List<TaskNode> nodes) {
      for (var node in nodes) {
        tasks.add(node);
        addTasksRecursively(node.children);
      }
    }
    
    addTasksRecursively(_projectTasks[projectId] ?? []);
    return tasks;
  }

  Future<void> deleteTask(String taskId, String projectId) async {
    try {
      // Find the task to get parent info before deletion
      final taskToDelete = _findTaskInHierarchy(taskId, projectId);
      final parentId = taskToDelete?.parentId;
      
      await DatabaseHelper.instance.deleteTaskNode(taskId);
      
      // Remove from hierarchy
      void removeFromList(List<TaskNode> list) {
        list.removeWhere((t) => t.id == taskId);
        for (var task in list) {
          removeFromList(task.children);
        }
      }
      
      removeFromList(_projectTasks[projectId] ?? []);
      
      // Recalculate parent progress if task had a parent
      if (parentId != null) {
        final parent = _findTaskInHierarchy(parentId, projectId);
        if (parent != null) {
          await updateTask(parent);
        }
      }
      
      await _updateProjectProgress(projectId);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  void selectTask(TaskNode? task) {
    _selectedTask = task;
    notifyListeners();
  }

  void toggleTaskExpansion(TaskNode task) {
    task.isExpanded = !task.isExpanded;
    notifyListeners();
  }

  Future<void> reorderTasks(String projectId, List<TaskNode> reorderedTasks) async {
    try {
      // Update positions
      final updates = <Map<String, dynamic>>[];
      for (int i = 0; i < reorderedTasks.length; i++) {
        updates.add({
          'id': reorderedTasks[i].id,
          'position': i,
          'parent_id': reorderedTasks[i].parentId,
        });
      }
      
      await DatabaseHelper.instance.updateTaskPositions(updates);
      _projectTasks[projectId] = reorderedTasks;
      notifyListeners();
    } catch (e) {
      debugPrint('Error reordering tasks: $e');
    }
  }

  List<TaskNode> getUpcomingTasks() {
    final allTasks = <TaskNode>[];
    for (var projectId in _projectTasks.keys) {
      final tasks = _projectTasks[projectId];
      if (tasks != null && tasks.isNotEmpty) {
        allTasks.addAll(_getAllTasksFlat(projectId));
      }
    }
    
    allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return allTasks.take(10).toList();
  }

  Map<TaskStatus, int> getTaskStatusBreakdown() {
    final breakdown = <TaskStatus, int>{};
    for (var status in TaskStatus.values) {
      breakdown[status] = 0;
    }
    
    for (var projectId in _projectTasks.keys) {
      final tasks = _getAllTasksFlat(projectId);
      for (var task in tasks) {
        breakdown[task.status] = (breakdown[task.status] ?? 0) + 1;
      }
    }
    
    return breakdown;
  }
}