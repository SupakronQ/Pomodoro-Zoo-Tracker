import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:pomodoro_zoo_tracker/core/database/database_helper.dart';
import 'package:pomodoro_zoo_tracker/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('PetLocalDataSource', () {
    late DatabaseHelper dbHelper;
    late PetLocalDataSource dataSource;
    late String userId;

    setUp(() async {
      dbHelper = DatabaseHelper();
      await dbHelper.close();

      final path = join(await getDatabasesPath(), 'pomodoro_zoo.db');
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }

      dataSource = PetLocalDataSource(dbHelper);
      userId = await dbHelper.getOrCreateGuestUser();
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('ensureStarterData should seed starter pet and foods only once', () async {
      final db = await dbHelper.database;

      await dataSource.ensureStarterData(userId);
      await dataSource.ensureStarterData(userId);

      final pets = await db.query(
        'user_animals',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      final userFoods = await db.query(
        'user_foods',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      final totalFood = userFoods.fold<int>(
        0,
        (sum, row) => sum + ((row['quantity'] as int?) ?? 0),
      );

      expect(pets.length, 1);
      expect(userFoods.length, 3);
      expect(totalFood, 7);
      expect(pets.first['level'], 3);
      expect(pets.first['experience_points'], 46);
      expect(pets.first['experience_to_next_level'], 100);
      expect(pets.first['hunger_level'], 85);
      expect(pets.first['is_showcased'], 1);
    });

    test('feedPet should consume food and clamp hunger at 100', () async {
      final db = await dbHelper.database;

      await dataSource.ensureStarterData(userId);

      final pet = await db.query(
        'user_animals',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      final petId = pet.first['id'] as String;

      await db.update(
        'user_animals',
        {'hunger_level': 95},
        where: 'id = ?',
        whereArgs: [petId],
      );

      final honeyFood = await db.rawQuery(
        '''
        SELECT uf.id AS user_food_id, uf.quantity AS quantity
        FROM user_foods uf
        INNER JOIN food f ON uf.food_id = f.id
        WHERE uf.user_id = ? AND f.name = ?
        LIMIT 1
        ''',
        [userId, 'Honey Treat'],
      );
      final userFoodId = honeyFood.first['user_food_id'] as String;

      await dataSource.feedPet(userId, petId, userFoodId);

      final refreshedPet = await db.query(
        'user_animals',
        where: 'id = ?',
        whereArgs: [petId],
        limit: 1,
      );
      final refreshedFood = await db.query(
        'user_foods',
        where: 'id = ?',
        whereArgs: [userFoodId],
        limit: 1,
      );

      expect(refreshedPet.first['hunger_level'], 100);
      expect(refreshedFood.first['quantity'], 1);
    });

    test('feedPet should fail cleanly when food quantity is zero', () async {
      final db = await dbHelper.database;

      await dataSource.ensureStarterData(userId);

      final pet = await db.query(
        'user_animals',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      final petId = pet.first['id'] as String;

      final bambooFood = await db.rawQuery(
        '''
        SELECT uf.id AS user_food_id
        FROM user_foods uf
        INNER JOIN food f ON uf.food_id = f.id
        WHERE uf.user_id = ? AND f.name = ?
        LIMIT 1
        ''',
        [userId, 'Bamboo Bite'],
      );
      final userFoodId = bambooFood.first['user_food_id'] as String;

      await db.update(
        'user_foods',
        {'quantity': 0},
        where: 'id = ?',
        whereArgs: [userFoodId],
      );

      await expectLater(
        dataSource.feedPet(userId, petId, userFoodId),
        throwsA(isA<StateError>()),
      );

      final refreshedPet = await db.query(
        'user_animals',
        where: 'id = ?',
        whereArgs: [petId],
        limit: 1,
      );

      expect(refreshedPet.first['hunger_level'], 85);
    });
  });
}
