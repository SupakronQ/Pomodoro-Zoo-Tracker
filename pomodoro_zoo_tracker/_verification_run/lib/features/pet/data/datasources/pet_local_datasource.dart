import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../models/pet_detail_model.dart';
import '../models/pet_food_inventory_model.dart';
import '../models/pet_summary_model.dart';

class PetLocalDataSource {
  final DatabaseHelper dbHelper;
  final Uuid _uuid = const Uuid();

  static const String _starterPandaItemId = 'starter-panda-item';
  static const String _starterPandaAnimalId = 'starter-panda-item';
  static const String _starterGachaPoolId = 'starter-zoo-pool';
  static const String _starterGachaItemId = 'starter-panda-gacha';

  static const List<Map<String, Object>> _starterFoods = [
    {
      'id': 'food-bamboo-bite',
      'name': 'Bamboo Bite',
      'description': 'A fresh bamboo snack that restores 8 hunger.',
      'price': 4,
      'benefit_value': 8,
      'sprite_url': 'assets/food/bamboo_bite.png',
      'quantity': 3,
    },
    {
      'id': 'food-fruit-bowl',
      'name': 'Fruit Bowl',
      'description': 'Sweet fruit slices that restore 6 hunger.',
      'price': 3,
      'benefit_value': 6,
      'sprite_url': 'assets/food/fruit_bowl.png',
      'quantity': 2,
    },
    {
      'id': 'food-honey-treat',
      'name': 'Honey Treat',
      'description': 'A rare treat that restores 12 hunger.',
      'price': 5,
      'benefit_value': 12,
      'sprite_url': 'assets/food/honey_treat.png',
      'quantity': 2,
    },
  ];

  PetLocalDataSource(this.dbHelper);

  Future<Database> get db async => await dbHelper.database;

  Future<void> ensureStarterData(String userId) async {
    final database = await db;
    await database.transaction((txn) async {
      await _ensureStarterCatalog(txn);

      final petCount = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM user_animals WHERE user_id = ?',
          [userId],
        ),
      );

      if ((petCount ?? 0) > 0) {
        return;
      }

      await txn.insert('user_animals', {
        'id': _uuid.v4(),
        'user_id': userId,
        'animal_id': _starterPandaAnimalId,
        'level': 3,
        'experience_points': 46,
        'hunger_level': 85,
        'experience_to_next_level': 100,
        'is_showcased': 1,
      });

      for (final food in _starterFoods) {
        await txn.insert('user_foods', {
          'id': _uuid.v4(),
          'user_id': userId,
          'food_id': food['id'] as String,
          'quantity': food['quantity'] as int,
        });
      }
    });
  }

  Future<List<PetSummaryModel>> getOwnedPets(String userId) async {
    final database = await db;
    final result = await database.rawQuery(
      '''
      SELECT
        ua.id AS user_animal_id,
        ua.animal_id AS animal_id,
        i.name AS name,
        ua.level AS level,
        ua.hunger_level AS hunger_level,
        ua.is_showcased AS is_showcased,
        COALESCE(r.name, 'Rare') AS rarity_name,
        i.sprite_url AS sprite_url
      FROM user_animals ua
      INNER JOIN animals a ON ua.animal_id = a.id
      INNER JOIN items i ON a.id = i.id
      LEFT JOIN gacha_items gi ON gi.item_id = i.id
      LEFT JOIN rarities r ON gi.rarity_id = r.id
      WHERE ua.user_id = ?
      ORDER BY ua.is_showcased DESC, i.name ASC
      ''',
      [userId],
    );

    return result.map(PetSummaryModel.fromMap).toList();
  }

  Future<PetDetailModel?> getPetDetail(String userId, String userAnimalId) async {
    final database = await db;
    final pets = await database.rawQuery(
      '''
      SELECT
        ua.id AS user_animal_id,
        ua.animal_id AS animal_id,
        i.name AS name,
        COALESCE(r.name, 'Rare') AS rarity_name,
        i.sprite_url AS sprite_url,
        ua.level AS level,
        ua.hunger_level AS hunger_level,
        ua.experience_points AS experience_points,
        ua.experience_to_next_level AS experience_to_next_level,
        ua.is_showcased AS is_showcased,
        a.stage AS stage,
        a.next_stage_level AS next_stage_level
      FROM user_animals ua
      INNER JOIN animals a ON ua.animal_id = a.id
      INNER JOIN items i ON a.id = i.id
      LEFT JOIN gacha_items gi ON gi.item_id = i.id
      LEFT JOIN rarities r ON gi.rarity_id = r.id
      WHERE ua.user_id = ? AND ua.id = ?
      LIMIT 1
      ''',
      [userId, userAnimalId],
    );

    if (pets.isEmpty) {
      return null;
    }

    final foods = await database.rawQuery(
      '''
      SELECT
        uf.id AS user_food_id,
        uf.food_id AS food_id,
        uf.quantity AS quantity,
        f.name AS name,
        f.description AS description,
        f.benefit_value AS benefit_value,
        f.sprite_url AS sprite_url
      FROM user_foods uf
      INNER JOIN food f ON uf.food_id = f.id
      WHERE uf.user_id = ?
      ORDER BY f.price ASC, f.name ASC
      ''',
      [userId],
    );

    final foodModels = foods.map(PetFoodInventoryModel.fromMap).toList();
    return PetDetailModel.fromMap(pets.first, foodModels);
  }

  Future<void> feedPet(String userId, String userAnimalId, String userFoodId) async {
    final database = await db;
    await database.transaction((txn) async {
      final petRows = await txn.query(
        'user_animals',
        columns: ['hunger_level'],
        where: 'id = ? AND user_id = ?',
        whereArgs: [userAnimalId, userId],
        limit: 1,
      );

      if (petRows.isEmpty) {
        throw StateError('Pet not found.');
      }

      final currentHunger = (petRows.first['hunger_level'] as int?) ?? 100;
      if (currentHunger >= 100) {
        throw StateError('Your pet is already full.');
      }

      final foodRows = await txn.rawQuery(
        '''
        SELECT
          uf.quantity AS quantity,
          f.benefit_value AS benefit_value
        FROM user_foods uf
        INNER JOIN food f ON uf.food_id = f.id
        WHERE uf.id = ? AND uf.user_id = ?
        LIMIT 1
        ''',
        [userFoodId, userId],
      );

      if (foodRows.isEmpty) {
        throw StateError('Food not found.');
      }

      final quantity = (foodRows.first['quantity'] as int?) ?? 0;
      if (quantity <= 0) {
        throw StateError('No food remaining.');
      }

      final benefitValue = (foodRows.first['benefit_value'] as int?) ?? 0;
      final nextHunger = min(100, currentHunger + benefitValue);

      await txn.update(
        'user_foods',
        {'quantity': quantity - 1},
        where: 'id = ?',
        whereArgs: [userFoodId],
      );

      await txn.update(
        'user_animals',
        {'hunger_level': nextHunger},
        where: 'id = ?',
        whereArgs: [userAnimalId],
      );
    });
  }

  Future<void> _ensureStarterCatalog(Transaction txn) async {
    final animalTypeId = await _findRequiredId(
      txn,
      tableName: 'item_types',
      whereColumn: 'name',
      whereValue: 'animal',
    );
    final rareRarityId = await _findRequiredId(
      txn,
      tableName: 'rarities',
      whereColumn: 'name',
      whereValue: 'Rare',
    );

    await txn.insert('gacha_pools', {
      'id': _starterGachaPoolId,
      'name': 'Starter Zoo',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await txn.insert('items', {
      'id': _starterPandaItemId,
      'item_type_id': animalTypeId,
      'name': 'Panda',
      'description': 'A gentle panda that thrives when your focus routine is steady.',
      'sprite_url': 'assets/pets/panda.png',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await txn.insert('animals', {
      'id': _starterPandaAnimalId,
      'stage': 1,
      'next_stage_level': 5,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await txn.insert('gacha_items', {
      'id': _starterGachaItemId,
      'rarity_id': rareRarityId,
      'gacha_pool_id': _starterGachaPoolId,
      'item_id': _starterPandaItemId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    for (final food in _starterFoods) {
      await txn.insert('food', {
        'id': food['id'] as String,
        'name': food['name'] as String,
        'description': food['description'] as String,
        'price': food['price'] as int,
        'benefit_value': food['benefit_value'] as int,
        'sprite_url': food['sprite_url'] as String,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<String> _findRequiredId(
    Transaction txn, {
    required String tableName,
    required String whereColumn,
    required String whereValue,
  }) async {
    final result = await txn.query(
      tableName,
      columns: ['id'],
      where: '$whereColumn = ?',
      whereArgs: [whereValue],
      limit: 1,
    );

    if (result.isEmpty) {
      throw StateError('Missing $tableName entry for $whereValue.');
    }

    return result.first['id'] as String;
  }
}
