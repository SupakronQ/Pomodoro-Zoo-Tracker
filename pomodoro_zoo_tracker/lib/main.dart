import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/presentation/main_page.dart';
import 'package:provider/provider.dart';

import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';

// Timer feature
import 'features/timer/data/datasources/timer_local_datasource.dart';
import 'features/timer/data/repositories/timer_repository_impl.dart';
import 'features/timer/domain/usecases/start_timer.dart';
import 'features/timer/domain/usecases/pause_timer.dart';
import 'features/timer/domain/usecases/reset_timer.dart';
import 'features/timer/domain/usecases/save_timer_session.dart';
import 'features/timer/presentation/providers/timer_provider.dart';

// Category feature
import 'features/category/data/datasources/category_local_datasource.dart';
import 'features/category/data/repositories/category_repository_impl.dart';
import 'features/category/presentation/providers/category_provider.dart';

// Coin feature
import 'features/coin/data/datasources/coin_local_datasource.dart';
import 'features/coin/data/repositories/coin_repository_impl.dart';
import 'features/coin/presentation/providers/coin_provider.dart';

// Stats feature
import 'features/stats/data/datasources/stats_local_datasource.dart';
import 'features/stats/data/repositories/stats_repository_impl.dart';
import 'features/stats/presentation/providers/stats_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  
  // Get or Create Guest User
  final guestUserId = await dbHelper.getOrCreateGuestUser();

  runApp(MyApp(guestUserId: guestUserId));
}

class MyApp extends StatelessWidget {
  final String guestUserId;

  const MyApp({super.key, required this.guestUserId});

  @override
  Widget build(BuildContext context) {
    // Wiring dependency injection
    final dbHelper = DatabaseHelper();
    
    // Timer
    final timerDataSource = TimerLocalDataSource(dbHelper);
    final timerRepository = TimerRepositoryImpl(timerDataSource);
    
    // Category
    final categoryDataSource = CategoryLocalDataSource(dbHelper);
    final categoryRepository = CategoryRepositoryImpl(categoryDataSource);

    // Coin
    final coinDataSource = CoinLocalDataSource(dbHelper);
    final coinRepository = CoinRepositoryImpl(coinDataSource);

    // Stats
    final statsDataSource = StatsLocalDataSource(dbHelper);
    final statsRepository = StatsRepositoryImpl(statsDataSource);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(repository: categoryRepository)..loadCategories(userId: guestUserId),
        ),
        ChangeNotifierProvider(
          create: (_) => CoinProvider(repository: coinRepository)..loadBalance(guestUserId),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(repository: statsRepository)..loadStats(userId: guestUserId),
        ),
        ChangeNotifierProxyProvider2<CoinProvider, StatsProvider, TimerProvider>(
          create: (context) => TimerProvider(
            startTimerUseCase: StartTimer(timerRepository),
            pauseTimerUseCase: PauseTimer(timerRepository),
            resetTimerUseCase: ResetTimer(timerRepository),
            saveTimerSessionUseCase: SaveTimerSession(timerRepository),
            userId: guestUserId,
          ),
          update: (context, coinProvider, statsProvider, previous) {
            return previous!
              ..userId = guestUserId
              ..onSessionComplete = (int coins) {
                // Award coins and reload stats
                coinProvider.addCoins(coins, 'pomodoro_session');
                statsProvider.loadStats(userId: guestUserId);
              };
          },
        ),
      ],
      child: MaterialApp(
        title: 'Pomodoro Zoo Tracker',
        theme: AppTheme.lightTheme,
        home: const MainPage(),
      ),
    );
  }
}
