import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/core/widgets/zoo_header.dart';
import '../providers/timer_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/timer_circle.dart';
import '../widgets/timer_controls.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimerProvider>();

    // ถ้า timer ถูก pause อยู่ ให้ resume แทน start ใหม่
    final hasTimer = provider.timer != null;
    final isPaused = hasTimer && !provider.isRunning && !provider.isCompleted;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZooTimerDisplay(
              progress: provider.progress,
              formattedTime: provider.formattedTime,
              isCompleted: provider.isCompleted,
              sessionLabel: provider.sessionLabel,
              currentRound: provider.currentRound,
              totalRounds: provider.totalRounds,
              isBreak: provider.isBreak,
            ),
            const SizedBox(height: 40),
            TimerControls(
              isRunning: provider.isRunning,
              isCompleted: provider.isCompleted,
              onStart: isPaused ? provider.resume : provider.start,
              onPause: provider.pause,
              onReset: provider.reset,
            ),
            if (provider.isCompleted) ...[
              const SizedBox(height: 32),
              Text(
                provider.isBreak
                    ? '☕ Break done — ready to focus!'
                    : '🎉 Pomodoro Complete! 🐾',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      )
    );
  }
}
