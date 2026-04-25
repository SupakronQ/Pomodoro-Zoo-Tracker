import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:pomodoro_zoo_tracker/core/database/database_helper.dart';
import 'package:pomodoro_zoo_tracker/features/coin/data/datasources/coin_local_datasource.dart';
import 'package:pomodoro_zoo_tracker/features/coin/data/repositories/coin_repository_impl.dart';
import 'package:pomodoro_zoo_tracker/features/coin/presentation/providers/coin_provider.dart';
import 'package:pomodoro_zoo_tracker/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:pomodoro_zoo_tracker/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:pomodoro_zoo_tracker/features/pet/presentation/pages/pet_detail_page.dart';
import 'package:pomodoro_zoo_tracker/features/pet/presentation/pages/zoo_page.dart';
import 'package:pomodoro_zoo_tracker/features/pet/presentation/providers/pet_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Pet pages', () {
    late DatabaseHelper dbHelper;
    late PetProvider petProvider;
    late CoinProvider coinProvider;
    late String userId;

    setUp(() async {
      dbHelper = DatabaseHelper();
      await dbHelper.close();

      final path = join(await getDatabasesPath(), 'pomodoro_zoo.db');
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }

      final petRepository = PetRepositoryImpl(PetLocalDataSource(dbHelper));
      final coinRepository = CoinRepositoryImpl(CoinLocalDataSource(dbHelper));

      userId = await dbHelper.getOrCreateGuestUser();
      petProvider = PetProvider(repository: petRepository);
      coinProvider = CoinProvider(repository: coinRepository);

      await coinProvider.loadBalance(userId);
      await petProvider.loadZoo(userId);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    testWidgets(
      'guest user can open pet detail, select food, and feed the pet',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PetProvider>.value(value: petProvider),
              ChangeNotifierProvider<CoinProvider>.value(value: coinProvider),
            ],
            child: const MaterialApp(home: ZooPage()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Panda'), findsOneWidget);
        expect(find.byIcon(Icons.pets_rounded), findsWidgets);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Care'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Animal Care'), findsOneWidget);
        expect(find.text('Inventory 7'), findsOneWidget);
        expect(find.text('85%'), findsOneWidget);
        expect(find.text('Feed Panda'), findsNothing);

        await tester.tap(find.text('Honey Treat'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.widgetWithText(ElevatedButton, 'Feed Panda'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Feed Panda'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.text('Inventory 6'), findsOneWidget);
        expect(find.text('97%'), findsOneWidget);
        expect(find.text('Panda enjoyed Honey Treat.'), findsOneWidget);
      },
    );

    testWidgets('missing pet id shows an error state', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PetProvider>.value(value: petProvider),
            ChangeNotifierProvider<CoinProvider>.value(value: coinProvider),
          ],
          child: const MaterialApp(
            home: PetDetailPage(userAnimalId: 'missing-pet'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('This pet could not be found.'), findsOneWidget);
    });

    testWidgets('full pets keep the feed button disabled', (tester) async {
      final db = await dbHelper.database;
      final pets = await db.query(
        'user_animals',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      final petId = pets.first['id'] as String;

      await db.update(
        'user_animals',
        {'hunger_level': 100},
        where: 'id = ?',
        whereArgs: [petId],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PetProvider>.value(value: petProvider),
            ChangeNotifierProvider<CoinProvider>.value(value: coinProvider),
          ],
          child: MaterialApp(home: PetDetailPage(userAnimalId: petId)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Bamboo Bite'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Panda Is Full'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
