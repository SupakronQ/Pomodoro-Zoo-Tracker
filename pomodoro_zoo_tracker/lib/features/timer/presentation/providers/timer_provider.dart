import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/timer.dart';
import '../../domain/usecases/start_timer.dart';
import '../../domain/usecases/pause_timer.dart';
import '../../domain/usecases/reset_timer.dart';

// Provider — UI State สำหรับ Timer
// รองรับ Focus / Break, Round system (4 รอบ → long break), App lifecycle
class TimerProvider extends ChangeNotifier with WidgetsBindingObserver {
  final StartTimer startTimerUseCase;
  final PauseTimer pauseTimerUseCase;
  final ResetTimer resetTimerUseCase;

  // ตั้งค่า duration (วินาที)
  static const int focusDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 15 * 60;
  static const int defaultTotalRounds = 4;

  TimerProvider({
    required this.startTimerUseCase,
    required this.pauseTimerUseCase,
    required this.resetTimerUseCase,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  TimerEntity? _timer;
  Timer? _ticker;
  DateTime? _backgroundedAt; // เวลาที่ app ไป background

  // round state ที่อยู่นอก timer entity เพื่อให้ persist ข้าม session
  int _currentRound = 1;
  TimerSessionType _sessionType = TimerSessionType.focus;

  // Getters
  TimerEntity? get timer => _timer;
  int get currentRound => _currentRound;
  int get totalRounds => defaultTotalRounds;
  TimerSessionType get sessionType => _sessionType;

  int get remainingSeconds => _timer?.remainingSeconds ?? _durationForSession(_sessionType);
  bool get isRunning => _timer?.isRunning ?? false;
  bool get isCompleted => _timer?.isCompleted ?? false;
  double get progress => _timer?.progress ?? 0;

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get sessionLabel {
    switch (_sessionType) {
      case TimerSessionType.focus:
        return 'FOCUS';
      case TimerSessionType.shortBreak:
        return 'SHORT BREAK';
      case TimerSessionType.longBreak:
        return 'LONG BREAK';
    }
  }

  bool get isBreak =>
      _sessionType == TimerSessionType.shortBreak ||
      _sessionType == TimerSessionType.longBreak;

  // --- Actions ---

  Future<void> start() async {
    final duration = _durationForSession(_sessionType);
    _timer = await startTimerUseCase(
      durationSeconds: duration,
      sessionType: _sessionType,
      currentRound: _currentRound,
      totalRounds: defaultTotalRounds,
    );
    _startTicker();
    notifyListeners();
  }

  Future<void> resume() async {
    if (_timer == null || _timer!.isRunning) return;
    _timer = _timer!.copyWith(isRunning: true);
    _startTicker();
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
    _currentRound = 1;
    _sessionType = TimerSessionType.focus;
    notifyListeners();
  }

  /// เรียกเมื่อ session เสร็จ → ข้ามไป session ถัดไปอัตโนมัติ
  void _onSessionComplete() {
    _ticker?.cancel();

    if (_sessionType == TimerSessionType.focus) {
      // จบ focus → เข้า break
      if (_currentRound >= defaultTotalRounds) {
        _sessionType = TimerSessionType.longBreak;
      } else {
        _sessionType = TimerSessionType.shortBreak;
      }
    } else {
      // จบ break → เข้า focus รอบถัดไป
      if (_sessionType == TimerSessionType.longBreak) {
        _currentRound = 1; // ครบ cycle กลับรอบ 1
      } else {
        _currentRound++;
      }
      _sessionType = TimerSessionType.focus;
    }

    // หยุดแล้วรอ user กด start เอง (ไม่ auto-start)
    _timer = _timer?.copyWith(isRunning: false, isCompleted: true);
    notifyListeners();
  }

  // --- Ticker ---

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_timer == null || !_timer!.isRunning) return;

    final elapsed = _timer!.elapsedSeconds + 1;
    final completed = elapsed >= _timer!.durationSeconds;

    _timer = _timer!.copyWith(
      elapsedSeconds: elapsed.clamp(0, _timer!.durationSeconds),
      isRunning: !completed,
      isCompleted: completed,
    );

    if (completed) {
      _onSessionComplete();
    } else {
      notifyListeners();
    }
  }

  // --- App Lifecycle ---

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App ไป background: จำเวลาที่ออกไป
      if (_timer != null && _timer!.isRunning) {
        _backgroundedAt = DateTime.now();
        _ticker?.cancel();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App กลับมา: คำนวณเวลาที่หายไปแล้วบวกเข้า elapsed
      if (_timer != null && _backgroundedAt != null) {
        final away = DateTime.now().difference(_backgroundedAt!).inSeconds;
        _backgroundedAt = null;

        final newElapsed = (_timer!.elapsedSeconds + away)
            .clamp(0, _timer!.durationSeconds);
        final completed = newElapsed >= _timer!.durationSeconds;

        _timer = _timer!.copyWith(
          elapsedSeconds: newElapsed,
          isRunning: !completed,
          isCompleted: completed,
        );

        if (completed) {
          _onSessionComplete();
        } else {
          _startTicker();
          notifyListeners();
        }
      }
    }
  }

  // --- Helpers ---

  int _durationForSession(TimerSessionType type) {
    switch (type) {
      case TimerSessionType.focus:
        return focusDuration;
      case TimerSessionType.shortBreak:
        return shortBreakDuration;
      case TimerSessionType.longBreak:
        return longBreakDuration;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
