import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pomodoro_zoo_tracker/core/database/database_helper.dart';

void main() {
  // Init ffi for testing on desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper();
      // Ensure fresh database
      await dbHelper.close();
      final path = join(await getDatabasesPath(), 'pomodoro_zoo.db');
      final file = File(path);
      try {
        if (file.existsSync()) {
          await file.delete();
        }
      } catch (e) {
        // Ignored. Another running test might lock the db file since they execute concurrently.
      }
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('All 20 v2 tables should be created', () async {
      final db = await dbHelper.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();

      final expectedTables = {
        'users', 'transaction_types', 'transactions', 'goals', 'categories',
        'pomodoro_sessions', 'rarities', 'item_types', 'gacha_items', 
        'animals', 'gacha_pools', 'user_animals', 'zoo',
        'decorations', 'backgrounds', 'user_decorations', 'user_backgrounds',
        'items', 'user_foods', 'food'
      };

      for (final table in expectedTables) {
        expect(tableNames, contains(table), reason: 'Missing table: $table');
      }
    });

    test('user_animals should include pet care columns in v4 schema', () async {
      final db = await dbHelper.database;
      final columns = await db.rawQuery('PRAGMA table_info(user_animals)');
      final columnNames = columns
          .map((column) => column['name'] as String)
          .toSet();

      expect(columnNames, contains('hunger_level'));
      expect(columnNames, contains('experience_to_next_level'));
      expect(columnNames, contains('is_showcased'));
    });

    test('Lookup tables should be seeded', () async {
      final db = await dbHelper.database;

      // transaction_types
      final txnTypes = await db.query('transaction_types');
      expect(txnTypes.length, greaterThanOrEqualTo(3));

      // rarities
      final rarities = await db.query('rarities');
      expect(rarities.length, greaterThanOrEqualTo(3));

      // item_types
      final itemTypes = await db.query('item_types');
      expect(itemTypes.length, greaterThanOrEqualTo(3));
    });

    test('Default categories should be seeded', () async {
      final db = await dbHelper.database;

      final categories = await db.query('categories');
      expect(categories.length, greaterThanOrEqualTo(2));
    });

    test('All UUID primary keys should be valid', () async {
      final db = await dbHelper.database;

      final categories = await db.query('categories');
      for (final row in categories) {
        final id = row['id'] as String;
        expect(id.length, 36, reason: 'UUID should be 36 chars');
        expect(id.contains('-'), isTrue, reason: 'UUID should contain dashes');
      }
    });

    test('v4 upgrade should preserve pet rows and add new defaults', () async {
      await dbHelper.close();

      final path = join(await getDatabasesPath(), 'pomodoro_zoo.db');
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }

      final legacyDb = await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
              id TEXT PRIMARY KEY
            )
          ''');
          await db.execute('''
            CREATE TABLE items (
              id TEXT PRIMARY KEY,
              item_type_id TEXT,
              name TEXT,
              description TEXT,
              sprite_url TEXT,
              created_at TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE animals (
              id TEXT PRIMARY KEY,
              stage INTEGER NOT NULL,
              next_stage_level INTEGER
            )
          ''');
          await db.execute('''
            CREATE TABLE user_animals (
              id TEXT PRIMARY KEY,
              user_id TEXT NOT NULL,
              animal_id TEXT NOT NULL,
              level INTEGER DEFAULT 1,
              experience_points INTEGER DEFAULT 0
            )
          ''');

          await db.insert('users', {'id': 'legacy-user'});
          await db.insert('items', {
            'id': 'legacy-animal',
            'item_type_id': 'animal',
            'name': 'Legacy Panda',
            'description': 'Before v4 upgrade.',
            'sprite_url': 'legacy.png',
            'created_at': DateTime.now().toIso8601String(),
          });
          await db.insert('animals', {
            'id': 'legacy-animal',
            'stage': 1,
            'next_stage_level': 5,
          });
          await db.insert('user_animals', {
            'id': 'legacy-pet',
            'user_id': 'legacy-user',
            'animal_id': 'legacy-animal',
            'level': 2,
            'experience_points': 40,
          });
        },
      );
      await legacyDb.close();

      final upgradedDb = await dbHelper.database;
      final upgradedPet = await upgradedDb.query(
        'user_animals',
        where: 'id = ?',
        whereArgs: ['legacy-pet'],
        limit: 1,
      );

      expect(upgradedPet, isNotEmpty);
      expect(upgradedPet.first['level'], 2);
      expect(upgradedPet.first['experience_points'], 40);
      expect(upgradedPet.first['hunger_level'], 100);
      expect(upgradedPet.first['experience_to_next_level'], 100);
      expect(upgradedPet.first['is_showcased'], 0);
    });
  });
}
