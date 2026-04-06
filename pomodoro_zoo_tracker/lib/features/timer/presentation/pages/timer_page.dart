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

    return Scaffold(
      // backgroundColor: const Color(0xFFF5F0E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZooTimerDisplay(
              progress: provider.progress,
              formattedTime: provider.formattedTime,
              isCompleted: provider.isCompleted,
            ),
            const SizedBox(height: 40),
            TimerControls(
              isRunning: provider.isRunning,
              isCompleted: provider.isCompleted,
              onStart: provider.start,
              onPause: provider.pause,
              onReset: provider.reset,
            ),
            if (provider.isCompleted) ...[
              const SizedBox(height: 32),
              const Text(
                '🎉 Pomodoro Complete! 🐾',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      )
    );
  }
}
