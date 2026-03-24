import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/timer.dart';
import '../../domain/usecases/start_timer.dart';
import '../../domain/usecases/pause_timer.dart';
import '../../domain/usecases/reset_timer.dart';

// Provider — UI State สำหรับ Timer
// Logic หนักอยู่ใน UseCases ไม่ใช่ที่นี่
class TimerProvider extends ChangeNotifier {
  final StartTimer startTimerUseCase;
  final PauseTimer pauseTimerUseCase;
  final ResetTimer resetTimerUseCase;

  TimerProvider({
    required this.startTimerUseCase,
    required this.pauseTimerUseCase,
    required this.resetTimerUseCase,
  });

  TimerEntity? _timer;
  Timer? _ticker;

  TimerEntity? get timer => _timer;

  int get remainingSeconds => _timer?.remainingSeconds ?? 25 * 60;
  bool get isRunning => _timer?.isRunning ?? false;
  bool get isCompleted => _timer?.isCompleted ?? false;
  double get progress => _timer?.progress ?? 0;

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> start() async {
    _timer = await startTimerUseCase();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  Future<void> pause() async {
    if (_timer == null) return;
    _ticker?.cancel();
    _timer = await pauseTimerUseCase(_timer!);
    notifyListeners();
  }

  Future<void> reset() async {
    _ticker?.cancel();
    if (_timer != null) {
      await resetTimerUseCase(_timer!.id);
      _timer = null;
    }
    notifyListeners();
  }

  void _tick() {
    if (_timer == null || !_timer!.isRunning) return;
    final elapsed = _timer!.elapsedSeconds + 1;
    final completed = elapsed >= _timer!.durationSeconds;
    _timer = TimerEntity(
      id: _timer!.id,
      durationSeconds: _timer!.durationSeconds,
      elapsedSeconds: elapsed.clamp(0, _timer!.durationSeconds),
      isRunning: !completed,
      isCompleted: completed,
    );
    if (completed) _ticker?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
