import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/presentation/main_page.dart';
import 'package:provider/provider.dart';
import 'features/timer/data/datasources/timer_local_datasource.dart';
import 'features/timer/data/repositories/timer_repository_impl.dart';
import 'features/timer/domain/usecases/start_timer.dart';
import 'features/timer/domain/usecases/pause_timer.dart';
import 'features/timer/domain/usecases/reset_timer.dart';
import 'features/timer/presentation/providers/timer_provider.dart';
import 'features/timer/presentation/pages/timer_page.dart';
import 'core/theme/app_theme.dart';

import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wiring dependency injection แบบ manual
    final dbHelper = DatabaseHelper();
    final dataSource = TimerLocalDataSource(dbHelper);
    final repository = TimerRepositoryImpl(dataSource);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TimerProvider(
            startTimerUseCase: StartTimer(repository),
            pauseTimerUseCase: PauseTimer(repository),
            resetTimerUseCase: ResetTimer(repository),
          ),
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
