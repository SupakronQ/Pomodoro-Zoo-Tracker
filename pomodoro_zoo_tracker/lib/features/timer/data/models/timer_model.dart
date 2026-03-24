import '../../domain/entities/timer.dart';

// Model สำหรับแปลง Entity <-> Row ใน SQLite
class TimerModel extends TimerEntity {
  const TimerModel({
    required super.id,
    required super.durationSeconds,
    required super.elapsedSeconds,
    required super.isRunning,
    required super.isCompleted,
  });

  factory TimerModel.fromMap(Map<String, dynamic> map) {
    return TimerModel(
      id: map['id'] as int,
      durationSeconds: map['duration_seconds'] as int,
      elapsedSeconds: map['elapsed_seconds'] as int,
      isRunning: (map['is_running'] as int) == 1,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration_seconds': durationSeconds,
      'elapsed_seconds': elapsedSeconds,
      'is_running': isRunning ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory TimerModel.fromEntity(TimerEntity entity) {
    return TimerModel(
      id: entity.id,
      durationSeconds: entity.durationSeconds,
      elapsedSeconds: entity.elapsedSeconds,
      isRunning: entity.isRunning,
      isCompleted: entity.isCompleted,
    );
  }
}
