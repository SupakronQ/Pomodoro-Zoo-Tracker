import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/presentation/main_page.dart';
import 'package:provider/provider.dart';
import 'features/timer/data/datasources/timer_local_datasource.dart';
import 'features/timer/data/repositories/timer_repository_impl.dart';
import 'features/timer/domain/usecases/start_timer.dart';
import 'features/timer/domain/usecases/pause_timer.dart';
import 'features/timer/domain/usecases/reset_timer.dart';
import 'features/timer/presentation/providers/timer_provider.dart';
import 'features/coin/domain/usecases/calculate_coins.dart';
import 'features/coin/presentation/providers/coin_provider.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wiring dependency injection แบบ manual
    final dataSource = TimerLocalDataSource();
    final repository = TimerRepositoryImpl(dataSource);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CoinProvider(
            calculateCoinsUseCase: CalculateCoins(),
          ),
        ),
        ChangeNotifierProxyProvider<CoinProvider, TimerProvider>(
          create: (_) => TimerProvider(
            startTimerUseCase: StartTimer(repository),
            pauseTimerUseCase: PauseTimer(repository),
            resetTimerUseCase: ResetTimer(repository),
          ),
          update: (_, coinProvider, timerProvider) {
            timerProvider!.onFocusTick = coinProvider.addFocusSecond;
            return timerProvider;
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
