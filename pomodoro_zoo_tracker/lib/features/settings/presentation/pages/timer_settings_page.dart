import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/timer_settings_provider.dart';

class TimerSettingsPage extends StatelessWidget {
  const TimerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<TimerSettingsProvider>(
                builder: (context, settings, _) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      // ─── Timer Durations ───
                      _TimerDurationCard(
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.primary,
                        label: 'Focus Session',
                        value: settings.focusMinutes,
                        min: 5,
                        max: 60,
                        onChanged: settings.setFocusMinutes,
                      ),
                      const SizedBox(height: 12),
                      _TimerDurationCard(
                        icon: Icons.coffee_outlined,
                        iconColor: AppColors.secondary,
                        label: 'Short Break',
                        value: settings.shortBreakMinutes,
                        min: 1,
                        max: 15,
                        onChanged: settings.setShortBreakMinutes,
                      ),
                      const SizedBox(height: 12),
                      _TimerDurationCard(
                        icon: Icons.nature_people_outlined,
                        iconColor: const Color(0xFF71796E),
                        label: 'Long Break',
                        value: settings.longBreakMinutes,
                        min: 10,
                        max: 45,
                        onChanged: settings.setLongBreakMinutes,
                      ),
                      const SizedBox(height: 32),

                      // ─── Atmosphere & Alerts header ───
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 16),
                        child: Text(
                          'ATMOSPHERE & ALERTS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      // ─── Ambient Sounds ───
                      _AmbientSoundsCard(
                        enabled: settings.ambientSounds,
                        selectedPreset: settings.ambientPreset,
                        presets: TimerSettingsProvider.ambientPresets,
                        onToggle: settings.setAmbientSounds,
                        onSelectPreset: settings.setAmbientPreset,
                      ),
                      const SizedBox(height: 12),

                      // ─── Notification Sound ───
                      _NotificationSoundCard(
                        selected: settings.notificationSound,
                        options: TimerSettingsProvider.notificationSounds,
                        onChanged: settings.setNotificationSound,
                      ),
                      const SizedBox(height: 12),

                      // ─── Vibrate on Finish ───
                      _ToggleCard(
                        icon: Icons.vibration,
                        label: 'Vibrate on Finish',
                        value: settings.vibrateOnFinish,
                        onChanged: settings.setVibrateOnFinish,
                      ),
                      const SizedBox(height: 12),

                      // ─── Haptic Feedback ───
                      _ToggleCard(
                        icon: Icons.touch_app_outlined,
                        label: 'Haptic Feedback',
                        value: settings.hapticFeedback,
                        onChanged: settings.setHapticFeedback,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF5E7F62),
          ),
          const Text(
            'Timer Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101F16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Timer Duration Card — slider + live label
// ─────────────────────────────────────────
class _TimerDurationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int value;
  final int min;
  final int max;
  final Future<void> Function(int) onChanged;

  const _TimerDurationCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = '${value.toString().padLeft(2, '0')}:00';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101F16).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101F16),
                  ),
                ),
              ),
              Text(
                timeLabel,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7FB77E),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: const Color(0xFF7FB77E),
              inactiveTrackColor: const Color(0xFFD5E7D9),
              thumbColor: const Color(0xFF7FB77E),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayColor: const Color(0xFF7FB77E).withValues(alpha: 0.15),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min}m',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF71796E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${max}m',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF71796E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Toggle Card
// ─────────────────────────────────────────
class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101F16).withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101F16),
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            activeTrackColor: const Color(0xFF7FB77E),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Ambient Sounds Card — toggle + preset chips
// ─────────────────────────────────────────
class _AmbientSoundsCard extends StatelessWidget {
  final bool enabled;
  final String selectedPreset;
  final List<String> presets;
  final Future<void> Function(bool) onToggle;
  final Future<void> Function(String) onSelectPreset;

  const _AmbientSoundsCard({
    required this.enabled,
    required this.selectedPreset,
    required this.presets,
    required this.onToggle,
    required this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF101F16).withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.volume_up_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ambient Sounds',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101F16),
                      ),
                    ),
                    Text(
                      enabled ? selectedPreset : 'Off',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF71796E),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                activeColor: AppColors.primary,
                activeTrackColor: const Color(0xFF7FB77E),
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: presets.map((preset) {
                  final isSelected = preset == selectedPreset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onSelectPreset(preset),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFD5E7D9),
                          ),
                        ),
                        child: Text(
                          preset,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5E7F62),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Notification Sound Card — dropdown picker
// ─────────────────────────────────────────
class _NotificationSoundCard extends StatelessWidget {
  final String selected;
  final List<String> options;
  final Future<void> Function(String) onChanged;

  const _NotificationSoundCard({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF101F16).withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Notification Sound',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101F16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD5E7D9)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101F16),
                ),
                items: options
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(o == 'Zen Chime' ? '$o (Default)' : o),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
