import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/project.dart';
import 'countdown_widget.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: project.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                project.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Progress
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 25,
                    lineWidth: 5,
                    percent: project.progress,
                    center: Text(
                      '${(project.progress * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: project.color,
                    backgroundColor: project.color.withOpacity(0.2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${project.completedTasks}/${project.totalTasks} tasks',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        LinearProgressIndicator(
                          value: project.progress,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(project.color),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Status & Deadline
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      project.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(project.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (project.isOverdue)
                    const Icon(Icons.warning, color: Colors.red, size: 16),
                  if (project.isOverdue) const SizedBox(width: 4),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${project.daysRemaining}d',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: project.isOverdue ? Colors.red : null,
                      fontWeight: project.isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.grey;
      case ProjectStatus.active:
        return Colors.blue;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
    }
  }
}