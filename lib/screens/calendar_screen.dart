import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_provider.dart';
import '../core/theme/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          PopupMenuButton<CalendarFormat>(
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Month'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('2 Weeks'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week'),
              ),
            ],
            icon: const Icon(Icons.view_module),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: calendarProvider.focusedDate,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(calendarProvider.selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  calendarProvider.setSelectedDate(selectedDay);
                  calendarProvider.setFocusedDate(focusedDay);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  calendarProvider.setFocusedDate(focusedDay);
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: theme.textTheme.titleLarge!,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: theme.colorScheme.onSurface,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                eventLoader: (day) {
                  final tasks = taskProvider.tasks.where((task) {
                    return isSameDay(task.dueDate, day);
                  }).toList();
                  return tasks;
                },
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            _buildSelectedDayEvents(context, calendarProvider, taskProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayEvents(
      BuildContext context,
      CalendarProvider calendarProvider,
      TaskProvider taskProvider,
      ) {
    final selectedDayTasks = taskProvider.tasks.where((task) {
      return isSameDay(task.dueDate, calendarProvider.selectedDate);
    }).toList();

    final selectedDayMeetings = calendarProvider.getMeetingsForDay(
      calendarProvider.selectedDate,
    );

    if (selectedDayTasks.isEmpty && selectedDayMeetings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No events for this day',
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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedDayMeetings.isNotEmpty) ...[
            Text(
              'Meetings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...selectedDayMeetings.map((meeting) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: meeting.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(meeting.title),
                subtitle: Text(
                  '${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)} • ${meeting.location}',
                ),
                trailing: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    '${meeting.attendees.length}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn()
                .slideX(begin: 0.1, end: 0)),
          ],
          if (selectedDayTasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...selectedDayTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: task.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: Chip(
                    label: Text(
                      task.status.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
                    side: BorderSide.none,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .slideX(begin: 0.1, end: 0);
            }),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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