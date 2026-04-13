import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/data/stats_mock_data.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/models/stats_view_data.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/widgets/stats_focus_distribution_card.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/widgets/stats_habitat_bonus_card.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/widgets/stats_overview_header.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/widgets/stats_period_selector.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/widgets/stats_summary_cards.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/widgets/stats_weekly_activity_card.dart';

class StatsPage extends StatefulWidget {
  final StatsViewData viewData;
  final ValueChanged<StatsPeriod>? onPeriodChanged;
  final VoidCallback? onViewZooPressed;

  const StatsPage({
    super.key,
    this.viewData = defaultStatsViewData,
    this.onPeriodChanged,
    this.onViewZooPressed,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsPeriod _selectedPeriod = StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 680;
                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatsOverviewHeader(
                          eyebrow: widget.viewData.overviewEyebrow,
                          title: widget.viewData.overviewTitle,
                        ),
                        const SizedBox(height: 18),
                        StatsPeriodSelector(
                          selectedPeriod: _selectedPeriod,
                          onChanged: _onPeriodChanged,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: StatsOverviewHeader(
                          eyebrow: widget.viewData.overviewEyebrow,
                          title: widget.viewData.overviewTitle,
                        ),
                      ),
                      const SizedBox(width: 24),
                      StatsPeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onChanged: _onPeriodChanged,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              StatsSummaryCards(
                totalFocus: widget.viewData.totalFocus,
                productivity: widget.viewData.productivityScore,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 920;
                  if (isNarrow) {
                    return Column(
                      children: [
                        StatsWeeklyActivityCard(
                          title: widget.viewData.weeklySectionTitle,
                          items: widget.viewData.weeklyActivities,
                        ),
                        const SizedBox(height: 16),
                        StatsFocusDistributionCard(
                          title: widget.viewData.focusSectionTitle,
                          topCategoryLabel: widget.viewData.topCategoryLabel,
                          topCategoryName: widget.viewData.topCategoryName,
                          entries: widget.viewData.distribution,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: StatsWeeklyActivityCard(
                          title: widget.viewData.weeklySectionTitle,
                          items: widget.viewData.weeklyActivities,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: StatsFocusDistributionCard(
                          title: widget.viewData.focusSectionTitle,
                          topCategoryLabel: widget.viewData.topCategoryLabel,
                          topCategoryName: widget.viewData.topCategoryName,
                          entries: widget.viewData.distribution,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              StatsHabitatBonusCard(
                data: widget.viewData.habitatBonus,
                onPressed: widget.onViewZooPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPeriodChanged(StatsPeriod value) {
    setState(() => _selectedPeriod = value);
    widget.onPeriodChanged?.call(value);
  }
}
