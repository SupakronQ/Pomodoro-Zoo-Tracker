import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/models/stats_view_data.dart';

class StatsFocusDistributionCard extends StatelessWidget {
  final String title;
  final String topCategoryLabel;
  final String topCategoryName;
  final List<FocusDistributionData> entries;

  const StatsFocusDistributionCard({
    super.key,
    required this.title,
    required this.topCategoryLabel,
    required this.topCategoryName,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: _DonutChart(
              entries: entries,
              topCategoryLabel: topCategoryLabel,
              topCategoryName: topCategoryName,
            ),
          ),
          const SizedBox(height: 18),
          ...entries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == entries.length - 1 ? 0 : 12,
              ),
              child: _LegendItem(
                label: item.label,
                percent: '${(item.percent * 100).round()}%',
                color: item.color,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final String topCategoryLabel;
  final String topCategoryName;
  final List<FocusDistributionData> entries;

  const _DonutChart({
    required this.topCategoryLabel,
    required this.topCategoryName,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Transform.rotate(
                angle: -1.57,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _DonutPainter(progress: value, entries: entries),
                ),
              );
            },
          ),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A101F16),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  topCategoryLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topCategoryName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final List<FocusDistributionData> entries;

  _DonutPainter({required this.progress, required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 26.0;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.surfaceContainer
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 6.28318, false, base);

    var start = 0.0;
    for (final segment in entries) {
      final sweep = 6.28318 * segment.percent * progress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += 6.28318 * segment.percent;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ArcSegment {
  final Color color;
  final double percent;

  _ArcSegment({required this.color, required this.percent});
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String percent;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          percent,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
