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
  });
}
