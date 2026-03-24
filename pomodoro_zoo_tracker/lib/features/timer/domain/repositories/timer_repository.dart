import '../entities/timer.dart';

// Abstract Repository — Domain Layer (ห้ามรู้เรื่อง SQLite)
abstract class TimerRepository {
  Future<TimerEntity?> getLastTimer();
  Future<void> saveTimer(TimerEntity timer);
  Future<void> deleteTimer(int id);
}
