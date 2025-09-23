import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/task_node.dart';
import '../providers/project_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/view_provider.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/countdown_widget.dart';
import 'create_project_screen.dart';
import 'project_tree_screen.dart';
import 'timeline_screen.dart';
import 'board_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final viewProvider = Provider.of<ViewProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Project Tree'),
        centerTitle: false,
        actions: [
          // View Toggle
          SegmentedButton<ViewType>(
            segments: const [
              ButtonSegment(
                value: ViewType.grid,
                icon: Icon(Icons.grid_view, size: 20),
              ),
              ButtonSegment(
                value: ViewType.tree,
                icon: Icon(Icons.account_tree, size: 20),
              ),
              ButtonSegment(
                value: ViewType.timeline,
                icon: Icon(Icons.timeline, size: 20),
              ),
              ButtonSegment(
                value: ViewType.board,
                icon: Icon(Icons.view_kanban, size: 20),
              ),
            ],
            selected: {viewProvider.currentView},
            onSelectionChanged: (Set<ViewType> newSelection) {
              viewProvider.setView(newSelection.first);

              // Navigate to appropriate screen
              if (projectProvider.selectedProject != null) {
                switch (newSelection.first) {
                  case ViewType.tree:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectTreeScreen(
                          project: projectProvider.selectedProject!,
                        ),
                      ),
                    );
                    break;
                  case ViewType.timeline:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TimelineScreen(
                          project: projectProvider.selectedProject!,
                        ),
                      ),
                    );
                    break;
                  case ViewType.board:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BoardScreen(
                          project: projectProvider.selectedProject!,
                        ),
                      ),
                    );
                    break;
                  default:
                    break;
                }
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: projectProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => projectProvider.loadProjects(),
        child: CustomScrollView(
          slivers: [
            // Dashboard Stats
            SliverToBoxAdapter(
              child: _buildDashboard(context, projectProvider),
            ),

            // Projects Header
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Projects',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('New Project'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateProjectScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Projects Grid
            if (projectProvider.projects.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No projects yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first project to get started',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Project'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateProjectScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final project = projectProvider.projects[index];
                      return ProjectCard(
                        project: project,
                        onTap: () {
                          projectProvider.selectProject(project);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectTreeScreen(
                                project: project,
                              ),
                            ),
                          );
                        },
                      ).animate()
                          .fadeIn(delay: (50 * index).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                    childCount: projectProvider.projects.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateProjectScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ).animate().scale(duration: 300.ms),
    );
  }

  Widget _buildDashboard(BuildContext context, ProjectProvider provider) {
    final theme = Theme.of(context);
    final statusBreakdown = provider.getTaskStatusBreakdown();
    final totalTasks = statusBreakdown.values.fold(0, (a, b) => a + b);
    final completedTasks = statusBreakdown[TaskStatus.done] ?? 0;
    final overallProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Active Projects',
                  provider.projects
                      .where((p) => p.status == ProjectStatus.active)
                      .length
                      .toString(),
                  Icons.folder,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Tasks',
                  totalTasks.toString(),
                  Icons.task,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 40,
                    lineWidth: 8,
                    percent: overallProgress,
                    center: Text(
                      '${(overallProgress * 100).toInt()}%',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedTasks of $totalTasks tasks completed',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideX(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Upcoming Deadlines
          if (provider.getUpcomingTasks().isNotEmpty) ...[
            Text(
              'Upcoming Deadlines',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...provider.getUpcomingTasks().take(3).map((task) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    task.statusIcon,
                    color: task.statusColor,
                  ),
                  title: Text(task.title),
                  subtitle: CountdownWidget(targetDate: task.dueDate),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: task.priorityColor.withOpacity(0.2),
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
                ),
              ).animate().fadeIn().slideX(begin: 0.1, end: 0);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}