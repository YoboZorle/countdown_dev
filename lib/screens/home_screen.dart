import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/animated_nav_bar.dart';
import 'calendar_screen.dart';
import 'tasks_screen.dart';
import 'team_screen.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalendarScreen(),
    const TasksScreen(),
    TeamScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: AnimatedNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
      floatingActionButton: _currentIndex < 3
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ).animate().scale(
        duration: 300.ms,
        curve: Curves.easeOut,
      )
          : null,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getTimeOfDay()}!',
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    'You have ${taskProvider.todayTasks.length} tasks today',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsSection(context, taskProvider),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRecentTasks(context, taskProvider),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildStatsSection(BuildContext context, TaskProvider taskProvider) {
    final stats = [
      {
        'title': 'Today',
        'count': taskProvider.todayTasks.length,
        'color': Colors.blue,
        'icon': Icons.today,
      },
      {
        'title': 'In Progress',
        'count': taskProvider.tasks
            .where((t) => t.status == TaskStatus.inProgress)
            .length,
        'color': Colors.orange,
        'icon': Icons.pending_actions,
      },
      {
        'title': 'Completed',
        'count':
        taskProvider.tasks.where((t) => t.status == TaskStatus.done).length,
        'color': Colors.green,
        'icon': Icons.check_circle,
      },
      {
        'title': 'Overdue',
        'count': taskProvider.overdueTasks.length,
        'color': Colors.red,
        'icon': Icons.warning,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (stat['color'] as Color).withOpacity(0.1),
                  (stat['color'] as Color).withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 24,
                    ),
                    Text(
                      '${stat['count']}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stat['color'] as Color,
                      ),
                    ),
                  ],
                ),
                Text(
                  stat['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (100 * index).ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.add_task, 'label': 'New Task', 'color': Colors.blue},
      {'icon': Icons.calendar_today, 'label': 'Schedule', 'color': Colors.purple},
      {'icon': Icons.people, 'label': 'Team', 'color': Colors.green},
      {'icon': Icons.analytics, 'label': 'Reports', 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTasks(BuildContext context, TaskProvider taskProvider) {
    final recentTasks = taskProvider.upcomingTasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentTasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              tileColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              title: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Chip(
                label: Text(
                  task.priority.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: _getPriorityColor(task.priority).withOpacity(0.2),
                side: BorderSide.none,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideX(begin: 0.1, end: 0);
        }),
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
}