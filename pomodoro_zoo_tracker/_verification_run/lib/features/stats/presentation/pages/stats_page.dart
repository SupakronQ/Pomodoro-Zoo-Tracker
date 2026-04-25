import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../providers/stats_provider.dart';
import '../../domain/entities/stats_period.dart';
import '../../domain/entities/stats_entry.dart';
import '../../../../core/theme/app_colors.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<StatsProvider>().loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'OVERVIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your focus\necosystem is\nthriving.',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface, // Or a darker green
                ),
              ),
              const SizedBox(height: 24),

              // Period Toggle
              _buildPeriodToggle(),
              const SizedBox(height: 24),

              // Card 1: Total Focus
              _buildTotalFocusCard(),
              const SizedBox(height: 16),

              // Card 2: Productivity Score
              _buildProductivityScoreCard(),
              const SizedBox(height: 16),

              // Card 3: Weekly Activity
              _buildWeeklyActivityCard(),
              const SizedBox(height: 16),

              // Card 4: Focus Distribution
              _buildFocusDistributionCard(),
              const SizedBox(height: 40), // Bottom padding for scroll
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Consumer<StatsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5), // Match faint background
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleOption(provider, StatsPeriod.day, 'Day'),
              _buildToggleOption(provider, StatsPeriod.week, 'Week'),
              _buildToggleOption(provider, StatsPeriod.month, 'Month'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleOption(StatsProvider provider, StatsPeriod period, String label) {
    final isSelected = provider.selectedPeriod == period;
    return GestureDetector(
      onTap: () => provider.setPeriod(period),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalFocusCard() {
    return Consumer<StatsProvider>(
      builder: (context, provider, child) {
        final totalMins = provider.totalMinutes;
        final h = totalMins ~/ 60;
        final m = totalMins % 60;
        final formattedLabel = h > 0 ? '${h}h ${m}m' : '${m}m';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.timer, color: AppColors.secondary, size: 20),
                  ),
                  const Text(
                    'GROWTH METRIC',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Total Focus',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedLabel,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductivityScoreCard() {
    return Consumer<StatsProvider>(
      builder: (context, provider, child) {
        final score = provider.productivityScore['score'] as int? ?? 0;
        final change = provider.productivityScore['percent_change'] as int? ?? 0;
        final changeStr = change >= 0 ? '+$change%' : '$change%';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF356939), // Dark green matching design
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
                  ),
                  Text(
                    'ANALYSIS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Productivity Score',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score%',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$changeStr from last week',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyActivityCard() {
    return Consumer<StatsProvider>(
      builder: (context, provider, child) {
        final acts = provider.weeklyActivity;
        int maxMins = 0;
        for (var a in acts) {
          if (a.totalMinutes > maxMins) maxMins = a.totalMinutes;
        }
        if (maxMins == 0) maxMins = 1; // avoid divide by zero

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
                  const Text(
                    'Weekly Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const Icon(Icons.more_horiz, color: AppColors.secondary),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 150, // Fixed height for bars
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: acts.map((act) {
                    double percentage = act.totalMinutes / maxMins;
                    bool isMax = act.totalMinutes == maxMins && maxMins > 1;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // The Bar
                        Expanded(
                          child: Container(
                            width: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant.withOpacity(0.8), // Background faint bar
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.bottomCenter,
                            child: LayoutBuilder(
                              builder: (ctx, constraints) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  height: constraints.maxHeight * percentage,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: isMax ? AppColors.secondary : AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          act.dayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFocusDistributionCard() {
    return Consumer<StatsProvider>(
      builder: (context, provider, child) {
        if (provider.stats.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text("No focus data yet.", style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        // Setup chart segments
        List<DonutSegment> segments = [];
        String topCategoryName = provider.stats.first.categoryName;
        
        for (var entry in provider.stats) {
          Color c;
          try {
            String hex = entry.colorHex.replaceAll('#', '');
            if (hex.length == 6) hex = 'FF$hex';
            c = Color(int.parse(hex, radix: 16));
          } catch (_) {
            c = AppColors.primaryContainer;
          }
          segments.add(DonutSegment(color: c, percentage: entry.percentage, label: entry.categoryName));
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Focus Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                   height: 180,
                   width: 180,
                   child: CustomPaint(
                     painter: DonutChartPainter(segments: segments),
                     child: Center(
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           const Text(
                             'Top Category',
                             style: TextStyle(
                               fontSize: 10,
                               fontWeight: FontWeight.bold,
                               color: Colors.grey,
                             ),
                           ),
                           Text(
                             topCategoryName,
                             style: const TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                               color: AppColors.secondary,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Legend
              ...segments.map((seg) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: seg.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        seg.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(seg.percentage * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class DonutSegment {
  final Color color;
  final double percentage;
  final String label;

  DonutSegment({required this.color, required this.percentage, required this.label});
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;

  DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final strokeWidth = 24.0; 

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; 

    double startAngle = -pi / 2; // Start at top
    
    // Gap between segments (in radians)
    final double gap = 0.05; 

    for (var seg in segments) {
      final sweepAngle = (seg.percentage * 2 * pi);
      paint.color = seg.color;
      
      // If there's only 1 segment, don't leave a gap
      final actualSweep = segments.length > 1 ? max(0.0, sweepAngle - gap) : sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        actualSweep,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
