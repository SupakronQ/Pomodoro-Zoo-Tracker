import '../entities/timer.dart';
import '../repositories/timer_repository.dart';

// UseCase: หยุดพัก Timer ชั่วคราว
class PauseTimer {
  final TimerRepository repository;

  PauseTimer(this.repository);

  Future<TimerEntity> call(TimerEntity current) async {
    final paused = current.copyWith(isRunning: false);
    await repository.saveTimer(paused);
    return paused;
  }
}
