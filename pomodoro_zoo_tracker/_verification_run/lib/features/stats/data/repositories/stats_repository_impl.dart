import '../../domain/entities/stats_entry.dart';
import '../../domain/entities/stats_period.dart';
import '../../domain/entities/daily_activity.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_datasource.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsLocalDataSource dataSource;

  StatsRepositoryImpl(this.dataSource);

  @override
  Future<List<StatsEntry>> getStatsByPeriod(StatsPeriod period, {String? userId}) async {
    return await dataSource.getStatsByPeriod(period, userId: userId);
  }

  @override
  Future<List<DailyActivity>> getWeeklyActivity({String? userId}) async {
    return await dataSource.getWeeklyActivity(userId: userId);
  }

  @override
  Future<Map<String, dynamic>> getProductivityScore({String? userId}) async {
    return await dataSource.getProductivityScore(userId: userId);
  }
}
