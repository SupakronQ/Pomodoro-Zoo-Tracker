import '../repositories/timer_repository.dart';

// UseCase: รีเซ็ต Timer กลับไปต้น
class ResetTimer {
  final TimerRepository repository;

  ResetTimer(this.repository);

  Future<void> call(int timerId) async {
    await repository.deleteTimer(timerId);
  }
}
