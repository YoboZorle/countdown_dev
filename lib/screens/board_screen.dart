import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../models/task_node.dart';
import '../widgets/board_column_widget.dart';

class BoardScreen extends StatefulWidget {
  final Project project;

  const BoardScreen({super.key, required this.project});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late List<DragAndDropList> _lists;

  @override
  void initState() {
    super.initState();
    _buildLists();
  }

  void _buildLists() {
    final provider = context.read<ProjectProvider>();
    final allTasks = _getAllTasksFlat(provider.getProjectTasks(widget.project.id));

    // Group tasks by status
    final tasksByStatus = <TaskStatus, List<TaskNode>>{};
    for (var status in TaskStatus.values) {
      tasksByStatus[status] = allTasks.where((t) => t.status == status).toList();
    }

    _lists = tasksByStatus.entries.map((entry) {
      return DragAndDropList(
        header: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.key.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entry.value.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        children: entry.value.map((task) {
          return DragAndDropItem(
            child: BoardColumnWidget(
              task: task,
              onTap: () {
                // Show task details
              },
            ),
          );
        }).toList(),
      );
    }).toList();
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
            onPressed: () {
              setState(() {
                _buildLists();
              });
            },
          ),
        ],
      ),
      body: DragAndDropLists(
        children: _lists,
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        listPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemDecorationWhileDragging: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        listDecoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        listWidth: 300,
        axis: Axis.horizontal,
        listDraggingWidth: 300,
      ),
    );
  }

  void _onItemReorder(
      int oldItemIndex,
      int oldListIndex,
      int newItemIndex,
      int newListIndex,
      ) {
    setState(() {
      final item = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, item);

      // Update task status if moved to different column
      if (oldListIndex != newListIndex) {
        final newStatus = TaskStatus.values[newListIndex];
        final task = (item.child as BoardColumnWidget).task;
        final updatedTask = task.copyWith(
          status: newStatus,
          completedDate: newStatus == TaskStatus.done ? DateTime.now() : null,
        );

        context.read<ProjectProvider>().updateTask(updatedTask);
      }
    });
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    // Lists shouldn't be reordered in Kanban board
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