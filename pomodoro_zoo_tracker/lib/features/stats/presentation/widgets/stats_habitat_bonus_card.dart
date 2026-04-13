import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/stats/presentation/models/stats_view_data.dart';

class StatsHabitatBonusCard extends StatelessWidget {
  final HabitatBonusData data;
  final VoidCallback? onPressed;

  const StatsHabitatBonusCard({super.key, required this.data, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 760;
          if (isNarrow) {
            return Column(
              children: [
                const _BonusAvatar(),
                SizedBox(height: 12),
                _BonusContent(centerText: true, data: data),
                SizedBox(height: 14),
                _BonusButton(
                  fullWidth: true,
                  label: data.ctaLabel,
                  onPressed: onPressed,
                ),
              ],
            );
          }

          return Row(
            children: [
              const _BonusAvatar(),
              SizedBox(width: 18),
              Expanded(child: _BonusContent(centerText: false, data: data)),
              SizedBox(width: 18),
              _BonusButton(
                fullWidth: false,
                label: data.ctaLabel,
                onPressed: onPressed,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BonusAvatar extends StatelessWidget {
  const _BonusAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryContainer.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A101F16),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _BonusContent extends StatelessWidget {
  final bool centerText;
  final HabitatBonusData data;

  const _BonusContent({required this.centerText, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerText
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          textAlign: centerText ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.description,
          textAlign: centerText ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BonusButton extends StatelessWidget {
  final bool fullWidth;
  final String label;
  final VoidCallback? onPressed;

  const _BonusButton({
    required this.fullWidth,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
