import '../../../../core/database/database_helper.dart';
import '../models/timer_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// Data Source: ทำงานกับ SQLite โดยตรง
class TimerLocalDataSource {
  final DatabaseHelper dbHelper;

  TimerLocalDataSource(this.dbHelper);

  Future<Database> get db async => await dbHelper.database;

  Future<TimerModel?> getLastTimer() async {
    // TODO: query SELECT * FROM timers ORDER BY id DESC LIMIT 1
    return null;
  }

  Future<void> insertTimer(TimerModel model) async {
    // TODO: db.insert('timers', model.toMap(), ...)
  }

  Future<void> updateTimer(TimerModel model) async {
    // TODO: db.update('timers', model.toMap(), where: 'id = ?', ...)
  }

  Future<void> deleteTimer(int id) async {
    // TODO: db.delete('timers', where: 'id = ?', whereArgs: [id])
  }

  Future<void> saveTimerSession(int durationMinutes, String? categoryId, DateTime date, {String? userId}) async {
    final sessionDb = await db;
    await sessionDb.insert('pomodoro_sessions', {
      'id': const Uuid().v4(),
      'user_id': userId,
      'category_id': categoryId,
      'duration_minutes': durationMinutes,
      'coins_earned': durationMinutes, // Assuming 1 coin per minute to give some coins
      'status': 'completed',
      'created_at': date.toIso8601String(),
      'ended_at': date.toIso8601String(),
    });
  }
}
