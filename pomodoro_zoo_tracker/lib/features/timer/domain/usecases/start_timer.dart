import '../entities/timer.dart';
import '../repositories/timer_repository.dart';

// UseCase: เริ่มต้น Timer ใหม่
class StartTimer {
  final TimerRepository repository;

  StartTimer(this.repository);

  Future<TimerEntity> call({
    int durationSeconds = 25 * 60,
    TimerSessionType sessionType = TimerSessionType.focus,
    int currentRound = 1,
    int totalRounds = 4,
  }) async {
    final timer = TimerEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      durationSeconds: durationSeconds,
      elapsedSeconds: 0,
      isRunning: true,
      isCompleted: false,
      sessionType: sessionType,
      currentRound: currentRound,
      totalRounds: totalRounds,
    );
    await repository.saveTimer(timer);
    return timer;
  }
}
