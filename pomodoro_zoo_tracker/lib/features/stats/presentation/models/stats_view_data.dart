import 'package:flutter/material.dart';

class SummaryMetricData {
  final String caption;
  final String title;
  final String value;
  final IconData icon;

  const SummaryMetricData({
    required this.caption,
    required this.title,
    required this.value,
    required this.icon,
  });
}

class ProductivityScoreData {
  final String caption;
  final String title;
  final String score;
  final String delta;
  final IconData icon;

  const ProductivityScoreData({
    required this.caption,
    required this.title,
    required this.score,
    required this.delta,
    required this.icon,
  });
}

class WeeklyActivityData {
  final String label;
  final double heightFactor;
  final bool active;
  final bool weekend;

  const WeeklyActivityData({
    required this.label,
    required this.heightFactor,
    this.active = false,
    this.weekend = false,
  });
}

class FocusDistributionData {
  final String label;
  final double percent;
  final Color color;

  const FocusDistributionData({
    required this.label,
    required this.percent,
    required this.color,
  });
}

class HabitatBonusData {
  final String title;
  final String description;
  final String ctaLabel;

  const HabitatBonusData({
    required this.title,
    required this.description,
    required this.ctaLabel,
  });
}

class StatsViewData {
  final String overviewEyebrow;
  final String overviewTitle;
  final SummaryMetricData totalFocus;
  final ProductivityScoreData productivityScore;
  final List<WeeklyActivityData> weeklyActivities;
  final String weeklySectionTitle;
  final String focusSectionTitle;
  final String topCategoryLabel;
  final String topCategoryName;
  final List<FocusDistributionData> distribution;
  final HabitatBonusData habitatBonus;

  const StatsViewData({
    required this.overviewEyebrow,
    required this.overviewTitle,
    required this.totalFocus,
    required this.productivityScore,
    required this.weeklyActivities,
    required this.weeklySectionTitle,
    required this.focusSectionTitle,
    required this.topCategoryLabel,
    required this.topCategoryName,
    required this.distribution,
    required this.habitatBonus,
  });
}
