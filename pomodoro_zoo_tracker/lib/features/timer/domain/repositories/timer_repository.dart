import '../entities/timer.dart';

// Abstract Repository — Domain Layer (ห้ามรู้เรื่อง SQLite)
abstract class TimerRepository {
  Future<TimerEntity?> getLastTimer();
  Future<void> saveTimer(TimerEntity timer);
  Future<void> saveTimerSession(
    int durationMinutes,
    String? categoryId,
    DateTime date, {
    String? userId,
    String? goalId,
  });
  Future<void> deleteTimer(int id);
  Future<int> getSessionCountForCategory(String categoryId, {String? userId});
  Future<int> getSessionCountForGoal(String goalId, {String? userId});
}
