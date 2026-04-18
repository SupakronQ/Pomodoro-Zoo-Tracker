import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/stats_period.dart';
import '../../domain/entities/stats_entry.dart';
import '../../domain/entities/daily_activity.dart';

class StatsLocalDataSource {
  final DatabaseHelper dbHelper;

  StatsLocalDataSource(this.dbHelper);

  Future<Database> get db async => await dbHelper.database;

  Future<List<StatsEntry>> getStatsByPeriod(StatsPeriod period, {String? userId}) async {
    final database = await db;
    String dateFilter = '';
    
    // SQLite date functions
    switch (period) {
      case StatsPeriod.day:
        // Today
        dateFilter = "DATE(ps.created_at) = DATE('now', 'localtime')";
        break;
      case StatsPeriod.week:
        // This week (Monday to Sunday usually, 'now' '%Y-%W' can be tricky, so let's use > 7 days or 'now', '-7 days')
        // Or cleaner: This week number
        dateFilter = "strftime('%Y-%W', ps.created_at) = strftime('%Y-%W', 'now', 'localtime')";
        break;
      case StatsPeriod.month:
        // This month
        dateFilter = "strftime('%Y-%m', ps.created_at) = strftime('%Y-%m', 'now', 'localtime')";
        break;
    }

    String whereClause = dateFilter;
    List<dynamic> whereArgs = [];

    if (userId != null) {
      // Allow ps.user_id IS NULL to also include guests or missing user ids during session tests
      whereClause += " AND (ps.user_id = ? OR ps.user_id IS NULL)";
      whereArgs.add(userId);
    }

    // Query grouping by category
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT 
        ps.category_id,
        CASE WHEN c.name IS NULL THEN 'Uncategorized' ELSE c.name END as category_name,
        CASE WHEN c.color_hex IS NULL THEN '#9E9E9E' ELSE c.color_hex END as color_hex,
        SUM(ps.duration_minutes) as total_minutes
      FROM pomodoro_sessions ps
      LEFT JOIN categories c ON ps.category_id = c.id
      WHERE $whereClause
      GROUP BY ps.category_id
      ORDER BY total_minutes DESC
    ''', whereArgs);

    // Calculate total for percentage
    int grandTotal = 0;
    for (var row in result) {
      grandTotal += (row['total_minutes'] as num).toInt();
    }

    List<StatsEntry> entries = [];
    for (var row in result) {
      int minutes = (row['total_minutes'] as num).toInt();
      double percentage = grandTotal > 0 ? (minutes / grandTotal) : 0.0;
      
      entries.add(StatsEntry(
        categoryId: row['category_id'] as String?,
        categoryName: row['category_name'] as String,
        colorHex: row['color_hex'] as String,
        totalMinutes: minutes,
        percentage: percentage,
      ));
    }

    return entries;
  }

  Future<List<DailyActivity>> getWeeklyActivity({String? userId}) async {
    final database = await db;
    String whereClause = "ps.created_at >= date('now', 'localtime', '-6 days')";
    List<dynamic> whereArgs = [];
    if (userId != null) {
      whereClause += " AND (ps.user_id = ? OR ps.user_id IS NULL)";
      whereArgs.add(userId);
    }
    
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT 
        strftime('%w', ps.created_at) as weekday_str,
        SUM(ps.duration_minutes) as total_minutes
      FROM pomodoro_sessions ps
      WHERE $whereClause
      GROUP BY weekday_str
    ''', whereArgs);

    Map<int, int> activityMap = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 0:0};
    for (var row in result) {
      int w = int.parse(row['weekday_str'] as String);
      activityMap[w] = (row['total_minutes'] as num).toInt();
    }
    
    return [
      DailyActivity(dayName: 'M', weekday: 1, totalMinutes: activityMap[1]!),
      DailyActivity(dayName: 'T', weekday: 2, totalMinutes: activityMap[2]!),
      DailyActivity(dayName: 'W', weekday: 3, totalMinutes: activityMap[3]!),
      DailyActivity(dayName: 'T', weekday: 4, totalMinutes: activityMap[4]!),
      DailyActivity(dayName: 'F', weekday: 5, totalMinutes: activityMap[5]!),
      DailyActivity(dayName: 'S', weekday: 6, totalMinutes: activityMap[6]!),
      DailyActivity(dayName: 'S', weekday: 0, totalMinutes: activityMap[0]!),
    ];
  }

  Future<Map<String, dynamic>> getProductivityScore({String? userId}) async {
    final database = await db;
    String baseWhere = "";
    List<dynamic> args = [];
    if (userId != null) {
      baseWhere = " AND (user_id = ? OR user_id IS NULL)";
      args = [userId];
    }

    final currentRes = await database.rawQuery('''
      SELECT SUM(duration_minutes) as current_total
      FROM pomodoro_sessions
      WHERE created_at >= date('now', 'localtime', '-6 days')
      $baseWhere
    ''', args);
      
    int currentTotal = 0;
    if (currentRes.isNotEmpty && currentRes.first['current_total'] != null) {
      currentTotal = (currentRes.first['current_total'] as num).toInt();
    }

    final prevRes = await database.rawQuery('''
      SELECT SUM(duration_minutes) as prev_total
      FROM pomodoro_sessions
      WHERE created_at >= date('now', 'localtime', '-13 days') AND created_at < date('now', 'localtime', '-6 days')
      $baseWhere
    ''', args);
      
    int prevTotal = 0;
    if (prevRes.isNotEmpty && prevRes.first['prev_total'] != null) {
      prevTotal = (prevRes.first['prev_total'] as num).toInt();
    }
    
    int goalPerWeek = 24 * 60; // 24 hours a week
    double scoreNum = (currentTotal / goalPerWeek) * 100;
    if (scoreNum > 100) scoreNum = 100;
    if (scoreNum < 0) scoreNum = 0;
    
    double percentChange = 0;
    if (prevTotal > 0) {
      percentChange = ((currentTotal - prevTotal) / prevTotal) * 100;
    } else if (currentTotal > 0) {
      percentChange = 100; 
    }
    
    return {
      'score': int.parse(scoreNum.toStringAsFixed(0)),
      'percent_change': int.parse(percentChange.toStringAsFixed(0)),
    };
  }
}
