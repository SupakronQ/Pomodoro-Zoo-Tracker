import '../entities/timer.dart';
import '../repositories/timer_repository.dart';

// UseCase: เริ่มต้น Timer ใหม่
class StartTimer {
  final TimerRepository repository;

  StartTimer(this.repository);

  Future<TimerEntity> call({int durationSeconds = 25 * 60}) async {
    final timer = TimerEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      durationSeconds: durationSeconds,
      elapsedSeconds: 0,
      isRunning: true,
      isCompleted: false,
    );
    await repository.saveTimer(timer);
    return timer;
  }
}
