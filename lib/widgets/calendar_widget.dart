import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<dynamic> Function(DateTime) eventLoader;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: widget.focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(widget.selectedDay, day);
      },
      onDaySelected: widget.onDaySelected,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      eventLoader: widget.eventLoader,
      startingDayOfWeek: StartingDayOfWeek.monday,
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
          color: theme.colorScheme.primary.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: TextStyle(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}