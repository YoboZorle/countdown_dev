import 'dart:async';
import 'package:flutter/material.dart';

class CountdownWidget extends StatefulWidget {
  final DateTime targetDate;
  final bool compact;

  const CountdownWidget({
    super.key,
    required this.targetDate,
    this.compact = false,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    setState(() {
      _timeRemaining = widget.targetDate.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = _timeRemaining.isNegative;

    if (widget.compact) {
      return Text(
        _getCompactTimeString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: isOverdue ? Colors.red : null,
          fontWeight: isOverdue ? FontWeight.bold : null,
        ),
      );
    }

    final days = _timeRemaining.inDays.abs();
    final hours = _timeRemaining.inHours.remainder(24).abs();
    final minutes = _timeRemaining.inMinutes.remainder(60).abs();
    final seconds = _timeRemaining.inSeconds.remainder(60).abs();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withOpacity(0.1)
            : theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOverdue)
            const Icon(Icons.warning, color: Colors.red, size: 16),
          if (isOverdue) const SizedBox(width: 8),
          _buildTimeUnit(days.toString(), 'Days', isOverdue),
          _buildSeparator(),
          _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours', isOverdue),
          _buildSeparator(),
          _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Min', isOverdue),
          _buildSeparator(),
          _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Sec', isOverdue),
        ],
      ),
    );
  }

  String _getCompactTimeString() {
    final isOverdue = _timeRemaining.isNegative;
    final absTime = _timeRemaining.abs();

    if (absTime.inDays > 30) {
      final months = (absTime.inDays / 30).floor();
      return isOverdue ? '$months months overdue' : 'in $months months';
    } else if (absTime.inDays > 0) {
      return isOverdue ? '${absTime.inDays}d overdue' : 'in ${absTime.inDays}d';
    } else if (absTime.inHours > 0) {
      return isOverdue ? '${absTime.inHours}h overdue' : 'in ${absTime.inHours}h';
    } else {
      return isOverdue ? '${absTime.inMinutes}m overdue' : 'in ${absTime.inMinutes}m';
    }
  }

  Widget _buildTimeUnit(String value, String label, bool isOverdue) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isOverdue ? Colors.red : theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}