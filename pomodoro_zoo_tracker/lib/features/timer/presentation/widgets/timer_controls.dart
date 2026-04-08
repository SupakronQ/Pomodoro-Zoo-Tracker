import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool isCompleted;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.isCompleted,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ใช้ ConstrainedBox เพื่อกำหนด maxWidth แทน SizedBox
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320), // เทียบเท่า max-w-xs
          child: Container(
            width: double.infinity, // ขยายเต็มที่ภายใต้ 320px
            height: 64,
            decoration: BoxDecoration(
              // Organic Gradient ตามดีไซน์ HTML
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF356939), Color(0xFF7FB77E)],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF356939).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isRunning ? onPause : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: const StadiumBorder(),
              ),
              child: Text(
                isRunning ? 'PAUSE SESSION' : 'START FOCUS SESSION',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans', //
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),

        // ปุ่ม Reset แบบ Minimal
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.replay, size: 20),
          label: const Text(
            'RESET TIMER',
            style: TextStyle(
              fontFamily: 'Inter', //
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary, //
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}