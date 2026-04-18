import '../entities/stats_entry.dart';
import '../entities/stats_period.dart';
import '../entities/daily_activity.dart';

abstract class StatsRepository {
  Future<List<StatsEntry>> getStatsByPeriod(StatsPeriod period, {String? userId});
  Future<List<DailyActivity>> getWeeklyActivity({String? userId});
  Future<Map<String, dynamic>> getProductivityScore({String? userId});
}
