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

  Future<void> saveTimerSession(
    int durationMinutes,
    String? categoryId,
    DateTime date, {
    String? userId,
    String? goalId,
  }) async {
    final sessionDb = await db;
    await sessionDb.insert('pomodoro_sessions', {
      'id': const Uuid().v4(),
      'user_id': userId,
      'category_id': categoryId,
      'goal_id': goalId,
      'duration_minutes': durationMinutes,
      'coins_earned': durationMinutes,
      'status': 'completed',
      'created_at': date.toIso8601String(),
      'ended_at': date.toIso8601String(),
    });
  }

  /// Returns completed session count for a category (all-time).
  Future<int> getSessionCountForCategory(
    String categoryId, {
    String? userId,
  }) async {
    final sessionDb = await db;
    String where = "category_id = ? AND status = 'completed'";
    List<dynamic> args = [categoryId];
    if (userId != null) {
      where += ' AND (user_id = ? OR user_id IS NULL)';
      args.add(userId);
    }
    final result = await sessionDb.rawQuery(
      'SELECT COUNT(*) as cnt FROM pomodoro_sessions WHERE $where',
      args,
    );
    return (result.first['cnt'] as num).toInt();
  }

  /// Returns completed session count for a specific goal (all-time).
  Future<int> getSessionCountForGoal(String goalId, {String? userId}) async {
    final sessionDb = await db;
    String where = "goal_id = ? AND status = 'completed'";
    List<dynamic> args = [goalId];
    if (userId != null) {
      where += ' AND (user_id = ? OR user_id IS NULL)';
      args.add(userId);
    }
    final result = await sessionDb.rawQuery(
      'SELECT COUNT(*) as cnt FROM pomodoro_sessions WHERE $where',
      args,
    );
    return (result.first['cnt'] as num).toInt();
  }
}
