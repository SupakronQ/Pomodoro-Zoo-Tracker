import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/models/stats_view_data.dart';

const defaultStatsViewData = StatsViewData(
  overviewEyebrow: 'OVERVIEW',
  overviewTitle: 'Your focus ecosystem is thriving.',
  totalFocus: SummaryMetricData(
    caption: 'GROWTH METRIC',
    title: 'Total Focus',
    value: '12h 30m',
    icon: Icons.timer_outlined,
  ),
  productivityScore: ProductivityScoreData(
    caption: 'ANALYSIS',
    title: 'Productivity Score',
    score: '85%',
    delta: '+12% from last week',
    icon: Icons.trending_up,
  ),
  weeklySectionTitle: 'Weekly Activity',
  focusSectionTitle: 'Focus Distribution',
  topCategoryLabel: 'Top Category',
  topCategoryName: 'Work',
  weeklyActivities: [
    WeeklyActivityData(label: 'M', heightFactor: 0.60),
    WeeklyActivityData(label: 'T', heightFactor: 0.45),
    WeeklyActivityData(label: 'W', heightFactor: 0.90, active: true),
    WeeklyActivityData(label: 'T', heightFactor: 0.75),
    WeeklyActivityData(label: 'F', heightFactor: 0.55),
    WeeklyActivityData(label: 'S', heightFactor: 0.30, weekend: true),
    WeeklyActivityData(label: 'S', heightFactor: 0.25, weekend: true),
  ],
  distribution: [
    FocusDistributionData(
      label: 'Work',
      percent: 0.55,
      color: AppColors.primary,
    ),
    FocusDistributionData(
      label: 'Study',
      percent: 0.30,
      color: AppColors.primaryContainer,
    ),
    FocusDistributionData(
      label: 'Relax',
      percent: 0.15,
      color: AppColors.secondaryContainer,
    ),
  ],
  habitatBonus: HabitatBonusData(
    title: 'Zoo Status: Flourishing',
    description:
        'Your consistent focus this week has unlocked a new Savannah habitat slot. Keep the momentum to welcome your next companion.',
    ctaLabel: 'View My Zoo',
  ),
);
