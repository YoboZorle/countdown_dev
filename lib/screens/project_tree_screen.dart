import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../models/task_node.dart';
import '../widgets/tree_node_widget.dart';
import '../widgets/countdown_widget.dart';
import 'task_detail_screen.dart';

class ProjectTreeScreen extends StatefulWidget {
  final Project project;

  const ProjectTreeScreen({super.key, required this.project});

  @override
  State<ProjectTreeScreen> createState() => _ProjectTreeScreenState();
}

class _ProjectTreeScreenState extends State<ProjectTreeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _expandedNodes = {};
  bool _expandAll = false;

  @override
  void initState() {
    super.initState();
    // Initially expand root nodes
    final provider = context.read<ProjectProvider>();
    final tasks = provider.getProjectTasks(widget.project.id);
    for (var task in tasks) {
      if (task.children.isNotEmpty) {
        _expandedNodes.add(task.id);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpansion(String nodeId) {
    setState(() {
      if (_expandedNodes.contains(nodeId)) {
        _expandedNodes.remove(nodeId);
      } else {
        _expandedNodes.add(nodeId);
      }
    });
  }

  void _expandAllNodes() {
    setState(() {
      _expandAll = true;
      _expandedNodes.clear();
      // Add all nodes with children to expanded set
      final provider = context.read<ProjectProvider>();
      final tasks = provider.getProjectTasks(widget.project.id);
      _addAllNodesRecursively(tasks);
    });
  }

  void _collapseAllNodes() {
    setState(() {
      _expandAll = false;
      _expandedNodes.clear();
    });
  }

  void _addAllNodesRecursively(List<TaskNode> nodes) {
    for (var node in nodes) {
      if (node.children.isNotEmpty) {
        _expandedNodes.add(node.id);
        _addAllNodesRecursively(node.children);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectProvider>(context);
    final tasks = provider.getProjectTasks(widget.project.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.project.name),
            Text(
              '${widget.project.totalTasks} tasks • ${widget.project.completedTasks} completed',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.expand),
            tooltip: 'Expand All',
            onPressed: _expandAllNodes,
          ),
          IconButton(
            icon: const Icon(Icons.compress),
            tooltip: 'Collapse All',
            onPressed: _collapseAllNodes,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'priority',
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem(
                value: 'due_date',
                child: Text('Sort by Due Date'),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Text('Sort by Status'),
              ),
            ],
            onSelected: (value) {
              // Implement sorting
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add First Task'),
              onPressed: () => _showAddTaskDialog(null),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Project Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Project Progress',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${(widget.project.progress * 100).toInt()}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: widget.project.progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                CountdownWidget(targetDate: widget.project.endDate),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          // Custom Tree View
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _buildTreeNodes(tasks, 0),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(null),
        child: const Icon(Icons.add),
      ).animate().scale(duration: 300.ms),
    );
  }

  List<Widget> _buildTreeNodes(List<TaskNode> nodes, int depth) {
    final widgets = <Widget>[];

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        bool matches = node.title.toLowerCase().contains(_searchQuery) ||
            node.description.toLowerCase().contains(_searchQuery);

        // Check if any children match
        if (!matches && node.children.isNotEmpty) {
          matches = _hasMatchingChild(node.children);
        }

        if (!matches) continue;
      }

      final isExpanded = _expandedNodes.contains(node.id) || _expandAll;

      widgets.add(
        TreeNodeWidget(
          key: Key(node.id),
          node: node,
          depth: depth,
          isExpanded: isExpanded,
          hasChildren: node.children.isNotEmpty,
          onToggleExpansion: () => _toggleExpansion(node.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(task: node),
              ),
            );
          },
          onAddChild: () => _showAddTaskDialog(node),
          onDelete: () => _deleteTask(node),
          onStatusChange: (status) => _updateTaskStatus(node, status),
        ).animate()
            .fadeIn(delay: (50 * i).ms)
            .slideX(begin: 0.05, end: 0),
      );

      // Add children if expanded
      if (isExpanded && node.children.isNotEmpty) {
        widgets.addAll(_buildTreeNodes(node.children, depth + 1));
      }
    }

    return widgets;
  }

  bool _hasMatchingChild(List<TaskNode> children) {
    for (var child in children) {
      if (child.title.toLowerCase().contains(_searchQuery) ||
          child.description.toLowerCase().contains(_searchQuery)) {
        return true;
      }
      if (child.children.isNotEmpty && _hasMatchingChild(child.children)) {
        return true;
      }
    }
    return false;
  }

  void _showAddTaskDialog(TaskNode? parent) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(parent == null ? 'New Task' : 'New Subtask'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<TaskPriority>(
                    segments: const [
                      ButtonSegment(
                        value: TaskPriority.low,
                        label: Text('Low'),
                      ),
                      ButtonSegment(
                        value: TaskPriority.medium,
                        label: Text('Medium'),
                      ),
                      ButtonSegment(
                        value: TaskPriority.high,
                        label: Text('High'),
                      ),
                    ],
                    selected: {selectedPriority},
                    onSelectionChanged: (Set<TaskPriority> newSelection) {
                      setState(() => selectedPriority = newSelection.first);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    final provider = context.read<ProjectProvider>();
                    final tasks = provider.getProjectTasks(widget.project.id);

                    final newTask = TaskNode(
                      projectId: widget.project.id,
                      parentId: parent?.id,
                      title: titleController.text,
                      description: descriptionController.text,
                      dueDate: selectedDate,
                      priority: selectedPriority,
                      depth: (parent?.depth ?? -1) + 1,
                      position: parent?.children.length ?? tasks.length,
                    );

                    provider.addTask(newTask);
                    Navigator.pop(context);

                    // Expand parent node to show new task
                    if (parent != null) {
                      setState(() {
                        _expandedNodes.add(parent.id);
                      });
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteTask(TaskNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          node.children.isNotEmpty
              ? 'This will delete "${node.title}" and all its subtasks. Continue?'
              : 'Delete "${node.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<ProjectProvider>().deleteTask(
                node.id,
                widget.project.id,
              );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(TaskNode node, TaskStatus status) {
    final updatedTask = node.copyWith(
      status: status,
      completedDate: status == TaskStatus.done ? DateTime.now() : null,
      progress: status == TaskStatus.done ? 1.0 : node.progress,
    );

    context.read<ProjectProvider>().updateTask(updatedTask);
  }
}