import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? suffix;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    suffix!,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
