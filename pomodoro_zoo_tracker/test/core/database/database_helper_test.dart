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
      if (file.existsSync()) {
        await file.delete();
      }
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('All 12 tables should be created', () async {
      final db = await dbHelper.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();

      final expectedTables = {
        'users',
        'transaction_types',
        'coin_transactions',
        'goals',
        'categories',
        'pomodoro_sessions',
        'rarities',
        'item_types',
        'gacha_items',
        'food_store',
        'user_foods',
        'user_inventory',
      };

      for (final table in expectedTables) {
        expect(tableNames, contains(table), reason: 'Missing table: $table');
      }
    });

    test('Lookup tables should be seeded', () async {
      final db = await dbHelper.database;

      // transaction_types
      final txnTypes = await db.query('transaction_types');
      expect(txnTypes.length, 3);
      final txnNames = txnTypes.map((t) => t['name']).toSet();
      expect(txnNames, containsAll(['pomodoro_reward', 'gacha_pull', 'food_purchase']));

      // rarities
      final rarities = await db.query('rarities');
      expect(rarities.length, 3);
      final rarityNames = rarities.map((r) => r['name']).toSet();
      expect(rarityNames, containsAll(['Common', 'Rare', 'Epic']));

      // item_types
      final itemTypes = await db.query('item_types');
      expect(itemTypes.length, 3);
      final itemTypeNames = itemTypes.map((i) => i['name']).toSet();
      expect(itemTypeNames, containsAll(['animal', 'decoration', 'background']));
    });

    test('Default categories should be seeded', () async {
      final db = await dbHelper.database;

      final categories = await db.query('categories');
      expect(categories.length, 2);

      final names = categories.map((c) => c['name']).toSet();
      expect(names, containsAll(['Work', 'Study']));
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
  });
}
