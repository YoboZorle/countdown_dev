import 'package:flutter/material.dart';
import '../models/task_node.dart';
import 'countdown_widget.dart';

class TreeNodeWidget extends StatelessWidget {
  final TaskNode node;
  final int depth;
  final bool isExpanded;
  final bool hasChildren;
  final VoidCallback onToggleExpansion;
  final VoidCallback onTap;
  final VoidCallback onAddChild;
  final VoidCallback onDelete;
  final Function(TaskStatus) onStatusChange;

  const TreeNodeWidget({
    super.key,
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.hasChildren,
    required this.onToggleExpansion,
    required this.onTap,
    required this.onAddChild,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indentSize = 24.0;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Indentation based on depth
            SizedBox(width: depth * indentSize),
            
            // Tree lines and expand/collapse button
            Container(
              width: 40,
              height: 60,
              child: Stack(
                children: [
                  // Vertical line for tree structure
                  if (depth > 0)
                    Positioned(
                      left: -12 + (depth * indentSize),
                      top: 0,
                      bottom: 30,
                      child: Container(
                        width: 1,
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                  
                  // Horizontal line to node
                  if (depth > 0)
                    Positioned(
                      left: -12 + (depth * indentSize),
                      top: 30,
                      child: Container(
                        width: 12,
                        height: 1,
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                  
                  // Expand/Collapse button
                  if (hasChildren)
                    Center(
                      child: IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_more : Icons.chevron_right,
                          size: 20,
                        ),
                        onPressed: onToggleExpansion,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Status Icon Button
            IconButton(
              icon: Icon(
                node.statusIcon,
                color: node.statusColor,
              ),
              onPressed: () {
                _showStatusMenu(context);
              },
            ),
            
            // Task Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Card(
                  elevation: 1,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: node.isOverdue
                              ? Colors.red.withOpacity(0.5)
                              : Colors.transparent,
                          width: node.isOverdue ? 2 : 0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  node.title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: node.status == TaskStatus.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              // Priority Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: node.priorityColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  node.priority.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: node.priorityColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (node.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              node.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Due Date with countdown
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: node.isOverdue ? Colors.red : null,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: CountdownWidget(
                                        targetDate: node.dueDate,
                                        compact: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Progress indicator
                              if (node.progress > 0 || hasChildren) ...[
                                SizedBox(
                                  width: 80,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            LinearProgressIndicator(
                                              value: node.progress,
                                              minHeight: 4,
                                              backgroundColor:
                                                  theme.colorScheme.primary.withOpacity(0.2),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                hasChildren 
                                                    ? theme.colorScheme.tertiary
                                                    : theme.colorScheme.primary,
                                              ),
                                            ),
                                            if (hasChildren)
                                              Text(
                                                'auto',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontSize: 9,
                                                  color: theme.colorScheme.tertiary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(node.progress * 100).toInt()}%',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Action Buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: onAddChild,
                                    tooltip: 'Add Subtask',
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    onPressed: onDelete,
                                    tooltip: 'Delete',
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Show child count if collapsed
                          if (hasChildren && !isExpanded) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${node.children.length} subtask${node.children.length > 1 ? 's' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = 
        Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    showMenu<TaskStatus>(
      context: context,
      position: position,
      items: TaskStatus.values.map((status) {
        return PopupMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(_getStatusName(status)),
            ],
          ),
        );
      }).toList(),
    ).then((status) {
      if (status != null) {
        onStatusChange(status);
      }
    });
  }
  
  String _getStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.blocked:
        return 'Blocked';
    }
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