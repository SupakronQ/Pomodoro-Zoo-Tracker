import '../../domain/entities/timer.dart';
import '../../domain/repositories/timer_repository.dart';
import '../datasources/timer_local_datasource.dart';
import '../models/timer_model.dart';

// Implement abstract domain repository ด้วย SQLite
class TimerRepositoryImpl implements TimerRepository {
  final TimerLocalDataSource dataSource;

  TimerRepositoryImpl(this.dataSource);

  @override
  Future<TimerEntity?> getLastTimer() async {
    return await dataSource.getLastTimer();
  }

  @override
  Future<void> saveTimer(TimerEntity timer) async {
    final model = TimerModel.fromEntity(timer);
    await dataSource.insertTimer(model);
  }

  @override
  Future<void> deleteTimer(int id) async {
    await dataSource.deleteTimer(id);
  }

  @override
  Future<void> saveTimerSession(int durationMinutes, String? categoryId, DateTime date, {String? userId}) async {
    await dataSource.saveTimerSession(durationMinutes, categoryId, date, userId: userId);
  }
}
