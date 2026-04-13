import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';

enum StatsPeriod { day, week, month }

class StatsPeriodSelector extends StatelessWidget {
  final StatsPeriod selectedPeriod;
  final ValueChanged<StatsPeriod> onChanged;

  const StatsPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodChip(
            label: 'Day',
            selected: selectedPeriod == StatsPeriod.day,
            onTap: () => onChanged(StatsPeriod.day),
          ),
          _PeriodChip(
            label: 'Week',
            selected: selectedPeriod == StatsPeriod.week,
            onTap: () => onChanged(StatsPeriod.week),
          ),
          _PeriodChip(
            label: 'Month',
            selected: selectedPeriod == StatsPeriod.month,
            onTap: () => onChanged(StatsPeriod.month),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
