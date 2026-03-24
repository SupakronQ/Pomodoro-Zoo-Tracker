// Domain Entity — ห้าม import Flutter หรือ sqflite

class TimerEntity {
  final int id;
  final int durationSeconds;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isCompleted;

  const TimerEntity({
    required this.id,
    required this.durationSeconds,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isCompleted,
  });

  int get remainingSeconds => durationSeconds - elapsedSeconds;

  double get progress =>
      durationSeconds > 0 ? elapsedSeconds / durationSeconds : 0;
}
