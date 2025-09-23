import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 0 ? Icons.home : Icons.home_outlined,
            ).animate(target: currentIndex == 0 ? 1 : 0).scale(
              end: const Offset(1.2, 1.2),
              duration: 200.ms,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 1
                  ? Icons.calendar_month
                  : Icons.calendar_month_outlined,
            ).animate(target: currentIndex == 1 ? 1 : 0).scale(
              end: const Offset(1.2, 1.2),
              duration: 200.ms,
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 2 ? Icons.task : Icons.task_outlined,
            ).animate(target: currentIndex == 2 ? 1 : 0).scale(
              end: const Offset(1.2, 1.2),
              duration: 200.ms,
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 3 ? Icons.people : Icons.people_outline,
            ).animate(target: currentIndex == 3 ? 1 : 0).scale(
              end: const Offset(1.2, 1.2),
              duration: 200.ms,
            ),
            label: 'Team',
          ),
        ],
      ),
    );
  }
}