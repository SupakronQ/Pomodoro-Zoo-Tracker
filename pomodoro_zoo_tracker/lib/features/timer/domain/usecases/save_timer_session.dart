import '../repositories/timer_repository.dart';

class SaveTimerSession {
  final TimerRepository repository;

  SaveTimerSession(this.repository);

  Future<void> call({
    required int durationMinutes,
    String? categoryId,
    required DateTime date,
    String? userId,
  }) async {
    await repository.saveTimerSession(durationMinutes, categoryId, date, userId: userId);
  }
}
