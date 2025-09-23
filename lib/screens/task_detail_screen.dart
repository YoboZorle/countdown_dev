import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_node.dart';
import '../providers/project_provider.dart';
import '../widgets/countdown_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskNode task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskStatus _status;
  late TaskPriority _priority;
  late DateTime _dueDate;
  late double _progress;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _status = widget.task.status;
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
    _progress = widget.task.progress;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset values
                  _titleController.text = widget.task.title;
                  _descriptionController.text = widget.task.description;
                  _status = widget.task.status;
                  _priority = widget.task.priority;
                  _dueDate = widget.task.dueDate;
                  _progress = widget.task.progress;
                });
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saveTask,
              child: const Text('Save'),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Priority
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          if (_isEditing)
                            DropdownButton<TaskStatus>(
                              value: _status,
                              isExpanded: true,
                              items: TaskStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(status),
                                        color: _getStatusColor(status),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(status.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                  if (value == TaskStatus.done) {
                                    _progress = 1.0;
                                  }
                                });
                              },
                            )
                          else
                            Row(
                              children: [
                                Icon(
                                  widget.task.statusIcon,
                                  color: widget.task.statusColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.task.status.name,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          if (_isEditing)
                            DropdownButton<TaskPriority>(
                              value: _priority,
                              isExpanded: true,
                              items: TaskPriority.values.map((priority) {
                                return DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _priority = value!;
                                });
                              },
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.task.priorityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.task.priority.name.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.task.priorityColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    if (_isEditing)
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      Text(
                        widget.task.title,
                        style: theme.textTheme.titleLarge,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    if (_isEditing)
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      Text(
                        widget.task.description.isEmpty
                            ? 'No description'
                            : widget.task.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Due Date and Countdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Due Date',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (_isEditing)
                          TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dueDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _dueDate = date;
                                });
                              }
                            },
                            child: const Text('Change'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    CountdownWidget(targetDate: _dueDate),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isEditing)
                      Slider(
                        value: _progress,
                        onChanged: (value) {
                          setState(() {
                            _progress = value;
                            if (value == 1.0) {
                              _status = TaskStatus.done;
                            } else if (_status == TaskStatus.done) {
                              _status = TaskStatus.inProgress;
                            }
                          });
                        },
                      )
                    else
                      LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
      progress: _progress,
      completedDate: _status == TaskStatus.done ? DateTime.now() : null,
    );

    context.read<ProjectProvider>().updateTask(updatedTask);

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
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