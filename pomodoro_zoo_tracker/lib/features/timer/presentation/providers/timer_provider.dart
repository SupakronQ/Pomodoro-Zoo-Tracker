import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/timer.dart';
import '../../domain/usecases/start_timer.dart';
import '../../domain/usecases/pause_timer.dart';
import '../../domain/usecases/reset_timer.dart';
import '../../domain/usecases/save_timer_session.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

// Provider — UI State สำหรับ Timer
// Logic หนักอยู่ใน UseCases ไม่ใช่ที่นี่
class TimerProvider extends ChangeNotifier {
  final StartTimer startTimerUseCase;
  final PauseTimer pauseTimerUseCase;
  final ResetTimer resetTimerUseCase;
  final SaveTimerSession saveTimerSessionUseCase;

  String? selectedCategoryId;
  String? userId;
  Function(int coinsEarned)? onSessionComplete;

  TimerProvider({
    required this.startTimerUseCase,
    required this.pauseTimerUseCase,
    required this.resetTimerUseCase,
    required this.saveTimerSessionUseCase,
    this.userId,
    this.onSessionComplete,
  });

  TimerEntity? _timer;
  Timer? _ticker;
  PomodoroPhase _phase = PomodoroPhase.focus;
  int _completedFocusRounds = 0;

  static const int _focusSeconds = 25 * 60;
  static const int _shortBreakSeconds = 5 * 60;
  static const int _longBreakSeconds = 15 * 60;

  TimerEntity? get timer => _timer;
  PomodoroPhase get phase => _phase;
  int get completedFocusRounds => _completedFocusRounds;
  int get currentRound => (_completedFocusRounds % 4) + 1;
  bool get isBreak => _phase != PomodoroPhase.focus;
  bool get isLongBreak => _phase == PomodoroPhase.longBreak;

  String get phaseLabel {
    switch (_phase) {
      case PomodoroPhase.focus:
        return 'FOCUS';
      case PomodoroPhase.shortBreak:
        return 'SHORT BREAK';
      case PomodoroPhase.longBreak:
        return 'LONG BREAK';
    }
  }

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
    if (_timer != null && !_timer!.isRunning && !_timer!.isCompleted) {
      _timer = TimerEntity(
        id: _timer!.id,
        durationSeconds: _timer!.durationSeconds,
        elapsedSeconds: _timer!.elapsedSeconds,
        isRunning: true,
        isCompleted: false,
      );
    } else {
      _timer = await startTimerUseCase(durationSeconds: 2 * 60);
      _timer = TimerEntity(
        id: _timer!.id,
        durationSeconds: _durationForPhase(_phase),
        elapsedSeconds: 0,
        isRunning: true,
        isCompleted: false,
      );
    }

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
    _phase = PomodoroPhase.focus;
    _completedFocusRounds = 0;
    notifyListeners();
  }

  void _tick() {
    if (_timer == null || !_timer!.isRunning) return;
    final elapsed = _timer!.elapsedSeconds + 1;
    final completed = elapsed >= _timer!.durationSeconds;

    if (!completed) {
      _timer = TimerEntity(
        id: _timer!.id,
        durationSeconds: _timer!.durationSeconds,
        elapsedSeconds: elapsed.clamp(0, _timer!.durationSeconds),
        isRunning: true,
        isCompleted: false,
      );
      notifyListeners();
      return;
    }

    _advanceToNextPhase();
    notifyListeners();
  }

  int _durationForPhase(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return _focusSeconds;
      case PomodoroPhase.shortBreak:
        return _shortBreakSeconds;
      case PomodoroPhase.longBreak:
        return _longBreakSeconds;
    }
  }

  void _advanceToNextPhase() {
    if (_timer == null) {
      return;
    }

    if (_phase == PomodoroPhase.focus) {
      _completedFocusRounds += 1;
      _phase = _completedFocusRounds % 4 == 0
          ? PomodoroPhase.longBreak
          : PomodoroPhase.shortBreak;
    } else {
      _phase = PomodoroPhase.focus;
    }

    _timer = TimerEntity(
      id: _timer!.id,
      durationSeconds: _durationForPhase(_phase),
      elapsedSeconds: 0,
      isRunning: true,
      isCompleted: false,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
