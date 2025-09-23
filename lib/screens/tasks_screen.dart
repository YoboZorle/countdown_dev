import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskPriority? _filterPriority;
  TaskStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'To Do'),
            Tab(text: 'In Progress'),
            Tab(text: 'Done'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'header',
                enabled: false,
                child: Text('Filter by Priority'),
              ),
              PopupMenuItem<String>(
                value: 'high',
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.red, size: 12),
                    const SizedBox(width: 8),
                    const Text('High'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'medium',
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.orange, size: 12),
                    const SizedBox(width: 8),
                    const Text('Medium'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'low',
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                    const SizedBox(width: 8),
                    const Text('Low'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'clear',
                child: const Text('Clear Filter'),
              ),
            ],
            onSelected: (String value) {
              setState(() {
                switch (value) {
                  case 'high':
                    _filterPriority = TaskPriority.high;
                    break;
                  case 'medium':
                    _filterPriority = TaskPriority.medium;
                    break;
                  case 'low':
                    _filterPriority = TaskPriority.low;
                    break;
                  case 'clear':
                    _filterPriority = null;
                    _filterStatus = null;
                    break;
                }
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(taskProvider.tasks, taskProvider),
          _buildTaskList(
            taskProvider.tasks
                .where((t) => t.status == TaskStatus.todo)
                .toList(),
            taskProvider,
          ),
          _buildTaskList(
            taskProvider.tasks
                .where((t) => t.status == TaskStatus.inProgress)
                .toList(),
            taskProvider,
          ),
          _buildTaskList(
            taskProvider.tasks
                .where((t) => t.status == TaskStatus.done)
                .toList(),
            taskProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider taskProvider) {
    List<Task> filteredTasks = tasks;

    if (_filterPriority != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _filterPriority)
          .toList();
    }

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return TaskCard(
          task: task,
          onTap: () => _showTaskDetails(context, task),
          onStatusChange: () => taskProvider.toggleTaskStatus(task.id),
          onDelete: () => taskProvider.deleteTask(task.id),
        ).animate().fadeIn(delay: (50 * index).ms).slideY(
          begin: 0.1,
          end: 0,
          curve: Curves.easeOut,
        );
      },
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: task.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              context,
              Icons.flag,
              'Priority',
              task.priority.name.toUpperCase(),
              _getPriorityColor(task.priority),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Due Date',
              '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
              Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.access_time,
              'Status',
              task.status.name.toUpperCase(),
              _getStatusColor(task.status),
            ),
            if (task.assignedTo.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                Icons.people,
                'Assigned To',
                task.assignedTo.join(', '),
                Theme.of(context).colorScheme.secondary,
              ),
            ],
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tags:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: task.tags
                        .map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      side: BorderSide.none,
                    ))
                        .toList(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }
}