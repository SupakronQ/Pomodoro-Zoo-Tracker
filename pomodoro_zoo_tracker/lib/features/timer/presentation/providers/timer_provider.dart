import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/timer.dart';
import '../../domain/repositories/timer_repository.dart';
import '../../domain/usecases/start_timer.dart';
import '../../domain/usecases/pause_timer.dart';
import '../../domain/usecases/reset_timer.dart';
import '../../domain/usecases/save_timer_session.dart';
import '../../../settings/presentation/providers/timer_settings_provider.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

// Provider — UI State สำหรับ Timer
// Logic หนักอยู่ใน UseCases ไม่ใช่ที่นี่
class TimerProvider extends ChangeNotifier {
  final StartTimer startTimerUseCase;
  final PauseTimer pauseTimerUseCase;
  final ResetTimer resetTimerUseCase;
  final SaveTimerSession saveTimerSessionUseCase;
  final TimerRepository repository;
  TimerSettingsProvider settingsProvider;

  String? selectedCategoryId;
  String? selectedGoalId;
  String? userId;
  Function(int coinsEarned)? onSessionComplete;

  TimerProvider({
    required this.startTimerUseCase,
    required this.pauseTimerUseCase,
    required this.resetTimerUseCase,
    required this.saveTimerSessionUseCase,
    required this.repository,
    required this.settingsProvider,
    this.userId,
    this.onSessionComplete,
  });

  // categoryId → completed session count
  Map<String, int> _sessionCounts = {};
  int getSessionCount(String categoryId) => _sessionCounts[categoryId] ?? 0;

  // goalId → completed session count
  Map<String, int> _goalSessionCounts = {};
  int getGoalSessionCount(String goalId) => _goalSessionCounts[goalId] ?? 0;

  Future<void> loadSessionCounts(
    List<String> categoryIds, {
    List<String> goalIds = const [],
  }) async {
    for (final id in categoryIds) {
      _sessionCounts[id] = await repository.getSessionCountForCategory(
        id,
        userId: userId,
      );
    }
    for (final id in goalIds) {
      _goalSessionCounts[id] = await repository.getSessionCountForGoal(
        id,
        userId: userId,
      );
    }
    notifyListeners();
  }

  TimerEntity? _timer;
  Timer? _ticker;
  PomodoroPhase _phase = PomodoroPhase.focus;
  int _completedFocusRounds = 0;

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

  int get remainingSeconds =>
      _timer?.remainingSeconds ?? _durationForPhase(_phase);
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
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
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

  Future<void> _tick() async {
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

    // Save session and award coins only when a focus round completes
    if (_phase == PomodoroPhase.focus) {
      final durationMinutes = _timer!.durationSeconds ~/ 60;
      await saveTimerSessionUseCase(
        durationMinutes: durationMinutes,
        categoryId: selectedCategoryId,
        goalId: selectedGoalId,
        date: DateTime.now(),
        userId: userId,
      );
      // Refresh session counts for saved category and goal
      if (selectedCategoryId != null) {
        _sessionCounts[selectedCategoryId!] = await repository
            .getSessionCountForCategory(selectedCategoryId!, userId: userId);
      }
      if (selectedGoalId != null) {
        _goalSessionCounts[selectedGoalId!] = await repository
            .getSessionCountForGoal(selectedGoalId!, userId: userId);
      }
      onSessionComplete?.call(10);
    }

    _advanceToNextPhase();
    notifyListeners();
  }

  int _durationForPhase(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return settingsProvider.focusMinutes * 60;
      case PomodoroPhase.shortBreak:
        return settingsProvider.shortBreakMinutes * 60;
      case PomodoroPhase.longBreak:
        return settingsProvider.longBreakMinutes * 60;
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
