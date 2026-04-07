// Domain Entity — ห้าม import Flutter หรือ sqflite

enum TimerSessionType { focus, shortBreak, longBreak }

class TimerEntity {
  final int id;
  final int durationSeconds;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isCompleted;
  final TimerSessionType sessionType;
  final int currentRound;
  final int totalRounds;

  const TimerEntity({
    required this.id,
    required this.durationSeconds,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isCompleted,
    this.sessionType = TimerSessionType.focus,
    this.currentRound = 1,
    this.totalRounds = 4,
  });

  int get remainingSeconds => durationSeconds - elapsedSeconds;

  double get progress =>
      durationSeconds > 0 ? elapsedSeconds / durationSeconds : 0;

  TimerEntity copyWith({
    int? id,
    int? durationSeconds,
    int? elapsedSeconds,
    bool? isRunning,
    bool? isCompleted,
    TimerSessionType? sessionType,
    int? currentRound,
    int? totalRounds,
  }) {
    return TimerEntity(
      id: id ?? this.id,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      sessionType: sessionType ?? this.sessionType,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
    );
  }
}
