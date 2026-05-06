import 'package:flutter/material.dart';
import '../models/brief_analysis.dart';
import '../theme/app_theme.dart';
import 'priority_badge.dart';

class RequirementCard extends StatelessWidget {
  final Requirement requirement;

  const RequirementCard({super.key, required this.requirement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.requirementAccentBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              requirement.id,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.requirementAccent,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requirement.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    PriorityBadge(priority: requirement.priority),
                    _CategoryBadge(label: requirement.category),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.requirementAccentBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.requirementAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.requirementAccent,
        ),
      ),
    );
  }
}
