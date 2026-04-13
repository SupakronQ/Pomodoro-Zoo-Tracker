import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/models/stats_view_data.dart';

class StatsWeeklyActivityCard extends StatelessWidget {
  final String title;
  final List<WeeklyActivityData> items;

  const StatsWeeklyActivityCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Icon(Icons.more_horiz, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 200,
            child: Row(
              children: items
                  .map(
                    (item) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _BarColumn(item: item),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final WeeklyActivityData item;

  const _BarColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    final barColor = item.active
        ? AppColors.primary
        : item.weekend
        ? AppColors.secondaryContainer
        : AppColors.primaryContainer;

    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 28),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: item.heightFactor,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.label,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
