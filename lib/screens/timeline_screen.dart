import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../models/task_node.dart';
import '../widgets/timeline_item_widget.dart';

class TimelineScreen extends StatefulWidget {
  final Project project;

  const TimelineScreen({super.key, required this.project});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  TaskStatus? _filterStatus;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectProvider>(context);
    
    // Get all tasks flat and sort by date
    final allTasks = _getAllTasksFlat(provider.getProjectTasks(widget.project.id));
    allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    // Apply filter
    final filteredTasks = _filterStatus != null
        ? allTasks.where((t) => t.status == _filterStatus).toList()
        : allTasks;
    
    // Group tasks by month
    final tasksByMonth = <String, List<TaskNode>>{};
    for (var task in filteredTasks) {
      final monthKey = '${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}';
      tasksByMonth.putIfAbsent(monthKey, () => []).add(task);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} Timeline'),
        actions: [
          PopupMenuButton<TaskStatus?>(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Tasks'),
              ),
              ...TaskStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 20,
                      color: _getStatusColor(status),
                    ),
                    const SizedBox(width: 8),
                    Text(status.name),
                  ],
                ),
              )),
            ],
            onSelected: (status) {
              setState(() {
                _filterStatus = status;
              });
            },
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(
              child: Text(
                'No tasks to show',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasksByMonth.length,
              itemBuilder: (context, monthIndex) {
                final monthKey = tasksByMonth.keys.elementAt(monthIndex);
                final monthTasks = tasksByMonth[monthKey]!;
                final monthDate = DateTime.parse('$monthKey-01');
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_getMonthName(monthDate.month)} ${monthDate.year}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    // Tasks for this month
                    ...monthTasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      final isFirst = monthIndex == 0 && index == 0;
                      final isLast = monthIndex == tasksByMonth.length - 1 && 
                                     index == monthTasks.length - 1;
                      
                      return TimelineTile(
                        isFirst: isFirst,
                        isLast: isLast,
                        indicatorStyle: IndicatorStyle(
                          width: 40,
                          height: 40,
                          indicator: Container(
                            decoration: BoxDecoration(
                              color: task.statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: task.statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              task.statusIcon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        beforeLineStyle: LineStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          thickness: 2,
                        ),
                        afterLineStyle: LineStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          thickness: 2,
                        ),
                        endChild: Container(
                          margin: const EdgeInsets.only(left: 16, bottom: 16),
                          child: TimelineItemWidget(
                            task: task,
                            onTap: () {
                              // Show task details
                            },
                          ),
                        ),
                      ).animate()
                          .fadeIn(delay: (50 * index).ms)
                          .slideX(begin: 0.1, end: 0);
                    }),
                  ],
                );
              },
            ),
    );
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
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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