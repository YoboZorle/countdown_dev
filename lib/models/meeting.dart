import 'package:flutter/material.dart';

class Meeting {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> attendees;
  final String location;
  final Color color;
  final bool isRecurring;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.attendees,
    required this.location,
    required this.color,
    this.isRecurring = false,
  });
}