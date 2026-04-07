import '../../../../core/database/database_helper.dart';
import '../models/timer_model.dart';
import 'package:sqflite/sqflite.dart';

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
}
