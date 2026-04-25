import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pomodoro_zoo_tracker/core/database/database_helper.dart';
import 'package:pomodoro_zoo_tracker/features/timer/data/datasources/timer_local_datasource.dart';

void main() {
  late DatabaseHelper dbHelper;
  late TimerLocalDataSource dataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    dataSource = TimerLocalDataSource(dbHelper);
    
    // Clear sessions table for clean testing
    final db = await dbHelper.database;
    await db.execute('DELETE FROM pomodoro_sessions');
  });

  test('should insert and save timer session correctly to database', () async {
    // Arrange
    final testDate = DateTime.now();
    const testDuration = 25;
    
    // Act
    await dataSource.saveTimerSession(testDuration, null, testDate);

    // Assert
    final db = await dbHelper.database;
    final sessions = await db.query('pomodoro_sessions');
    
    print('✅ Saved session count: \${sessions.length}');
    print('✅ Saved session data: \${sessions.first}');
    
    expect(sessions.length, 1);
    expect(sessions.first['duration_minutes'], testDuration);
    expect(sessions.first['status'], 'completed');
  });
}
