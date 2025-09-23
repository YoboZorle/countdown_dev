import 'package:flutter/material.dart';
import '../models/meeting.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final List<Meeting> _meetings = [];

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  List<Meeting> get meetings => [..._meetings];

  CalendarProvider() {
    _initializeSampleMeetings();
  }

  void _initializeSampleMeetings() {
    final now = DateTime.now();
    _meetings.addAll([
      Meeting(
        id: '1',
        title: 'Daily Standup',
        description: 'Team sync-up meeting',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 30),
        attendees: ['John', 'Sarah', 'Mike', 'Emma'],
        location: 'Conference Room A',
        color: Colors.blue,
        isRecurring: true,
      ),
      Meeting(
        id: '2',
        title: 'Client Presentation',
        description: 'Product demo for client',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 30),
        attendees: ['John', 'Emma'],
        location: 'Virtual - Zoom',
        color: Colors.purple,
      ),
    ]);
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  List<Meeting> getMeetingsForDay(DateTime day) {
    return _meetings.where((meeting) {
      return meeting.startTime.year == day.year &&
          meeting.startTime.month == day.month &&
          meeting.startTime.day == day.day;
    }).toList();
  }

  void addMeeting(Meeting meeting) {
    _meetings.add(meeting);
    notifyListeners();
  }

  void removeMeeting(String meetingId) {
    _meetings.removeWhere((m) => m.id == meetingId);
    notifyListeners();
  }
}