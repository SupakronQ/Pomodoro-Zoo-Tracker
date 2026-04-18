import 'package:flutter/material.dart';
import '../../domain/entities/stats_entry.dart';
import '../../domain/entities/stats_period.dart';
import '../../domain/entities/daily_activity.dart';
import '../../domain/repositories/stats_repository.dart';

class StatsProvider extends ChangeNotifier {
  final StatsRepository repository;
  String? currentUserId;

  StatsProvider({required this.repository});

  StatsPeriod _selectedPeriod = StatsPeriod.day;
  List<StatsEntry> _stats = [];
  List<DailyActivity> _weeklyActivity = [];
  Map<String, dynamic> _productivityScore = {'score': 0, 'percent_change': 0};
  bool _isLoading = false;

  StatsPeriod get selectedPeriod => _selectedPeriod;
  List<StatsEntry> get stats => _stats;
  List<DailyActivity> get weeklyActivity => _weeklyActivity;
  Map<String, dynamic> get productivityScore => _productivityScore;
  bool get isLoading => _isLoading;

  int get totalMinutes => _stats.fold(0, (sum, entry) => sum + entry.totalMinutes);

  Future<void> loadStats({String? userId}) async {
    if (userId != null) {
      currentUserId = userId;
    }
    
    _isLoading = true;
    notifyListeners();

    _stats = await repository.getStatsByPeriod(_selectedPeriod, userId: currentUserId);

    // Also load the overarching data regardless of current period selected
    // Note: If you want these to change based on selected period, you'd adjust here.
    // For now, based on mock, 'Weekly Activity' and 'Productivity Score' seem static 
    // or weekly based. We will load them globally.
    _weeklyActivity = await repository.getWeeklyActivity(userId: currentUserId);
    _productivityScore = await repository.getProductivityScore(userId: currentUserId);

    _isLoading = false;
    notifyListeners();
  }

  void setPeriod(StatsPeriod period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      loadStats(); // reload with new period
    }
  }
}

