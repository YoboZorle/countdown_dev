import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../models/task_node.dart';
import '../widgets/board_column_widget.dart';
import 'task_detail_screen.dart';

class BoardScreen extends StatefulWidget {
  final Project project;

  const BoardScreen({super.key, required this.project});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  Map<TaskStatus, List<TaskNode>> _tasksByStatus = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }
  
  void _loadTasks() {
    final provider = context.read<ProjectProvider>();
    final allTasks = _getAllTasksFlat(provider.getProjectTasks(widget.project.id));
    
    setState(() {
      _tasksByStatus = {};
      for (var status in TaskStatus.values) {
        _tasksByStatus[status] = allTasks.where((t) => t.status == status).toList();
      }
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadTasks();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: TaskStatus.values.map((status) {
                          return _buildColumn(status, theme);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildColumn(TaskStatus status, ThemeData theme) {
    final tasks = _tasksByStatus[status] ?? [];
    
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusName(status),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          // Droppable Area
          Expanded(
            child: DragTarget<TaskNode>(
              onWillAccept: (task) => task != null,
              onAccept: (task) {
                _moveTask(task, status);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? theme.colorScheme.primary.withOpacity(0.05)
                        : null,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: tasks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Drop tasks here',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return _buildDraggableTask(task, theme);
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDraggableTask(TaskNode task, ThemeData theme) {
    return Draggable<TaskNode>(
      data: task,
      maxSimultaneousDrags: 1,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          child: _buildTaskCard(task, theme, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTaskCard(task, theme),
      ),
      child: _buildTaskCard(task, theme),
    );
  }
  
  Widget _buildTaskCard(TaskNode task, ThemeData theme, {bool isDragging = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isDragging ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.2),
            ),
            boxShadow: isDragging
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: task.priorityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // Due date
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.isOverdue
                            ? Colors.red.withOpacity(0.1)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: task.isOverdue
                              ? Colors.red.withOpacity(0.3)
                              : theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: task.isOverdue ? Colors.red : null,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.dueDate.day}/${task.dueDate.month}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: task.isOverdue ? Colors.red : null,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Priority
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: task.priorityColor,
                        ),
                      ),
                    ),
                    // Progress if > 0
                    if (task.progress > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(task.progress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _moveTask(TaskNode task, TaskStatus newStatus) async {
    if (task.status == newStatus) return;
    
    // Remove from old status
    setState(() {
      _tasksByStatus[task.status]?.remove(task);
    });
    
    // Update task
    final updatedTask = task.copyWith(
      status: newStatus,
      completedDate: newStatus == TaskStatus.done ? DateTime.now() : null,
      progress: newStatus == TaskStatus.done ? 1.0 : 
                newStatus == TaskStatus.inProgress ? task.progress > 0 ? task.progress : 0.5 : 
                newStatus == TaskStatus.todo ? 0.0 :
                task.progress,
    );
    
    // Add to new status
    setState(() {
      _tasksByStatus[newStatus] ??= [];
      _tasksByStatus[newStatus]!.add(updatedTask);
    });
    
    // Update in provider
    try {
      await context.read<ProjectProvider>().updateTask(updatedTask);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task moved to ${_getStatusName(newStatus)}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _tasksByStatus[newStatus]?.remove(updatedTask);
        _tasksByStatus[task.status] ??= [];
        _tasksByStatus[task.status]!.add(task);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  List<TaskNode> _getAllTasksFlat(List<TaskNode> tasks) {
    final result = <TaskNode>[];
    
    void addTasksRecursively(List<TaskNode> nodes) {
      for (var node in nodes) {
        result.add(node);
        addTasksRecursively(node.children);
      }
    }
    
    addTasksRecursively(tasks);
    return result;
  }
  
  String _getStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'TO DO';
      case TaskStatus.inProgress:
        return 'IN PROGRESS';
      case TaskStatus.review:
        return 'REVIEW';
      case TaskStatus.done:
        return 'DONE';
      case TaskStatus.blocked:
        return 'BLOCKED';
    }
  }
  
  Color _getStatusColor(TaskStatus status) {
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
}