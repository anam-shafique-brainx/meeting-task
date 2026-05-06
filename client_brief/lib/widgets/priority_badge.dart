import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final label = priority.isNotEmpty
        ? '${priority[0].toUpperCase()}${priority.substring(1)}'
        : 'Medium';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.priorityBgColor(priority),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.priorityColor(priority).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.priorityColor(priority),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
