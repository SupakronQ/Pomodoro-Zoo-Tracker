import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pomodoro_zoo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Enable foreign keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // ==========================================
    // 1. users
    // ==========================================
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT,
        coin_balance INTEGER NOT NULL DEFAULT 0,
        showcased_animal_id TEXT,
        current_streak INTEGER NOT NULL DEFAULT 0,
        last_active_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ==========================================
    // 2. transaction_types (lookup)
    // ==========================================
    await db.execute('''
      CREATE TABLE transaction_types (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // ==========================================
    // 3. coin_transactions
    // ==========================================
    await db.execute('''
      CREATE TABLE coin_transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        transaction_type_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        reference_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (transaction_type_id) REFERENCES transaction_types (id)
      )
    ''');

    // ==========================================
    // 4. goals
    // ==========================================
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        target_intervals INTEGER NOT NULL,
        deadline TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ==========================================
    // 5. categories
    // ==========================================
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ==========================================
    // 6. pomodoro_sessions
    // ==========================================
    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        goal_id TEXT,
        duration_minutes INTEGER NOT NULL,
        coins_earned INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'completed',
        created_at TEXT NOT NULL,
        ended_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (goal_id) REFERENCES goals (id)
      )
    ''');

    // ==========================================
    // 7. rarities (lookup)
    // ==========================================
    await db.execute('''
      CREATE TABLE rarities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        drop_weight INTEGER NOT NULL
      )
    ''');

    // ==========================================
    // 8. item_types (lookup)
    // ==========================================
    await db.execute('''
      CREATE TABLE item_types (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // ==========================================
    // 9. gacha_items
    // ==========================================
    await db.execute('''
      CREATE TABLE gacha_items (
        id TEXT PRIMARY KEY,
        rarity_id TEXT NOT NULL,
        item_type_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        sprite_url TEXT,
        FOREIGN KEY (rarity_id) REFERENCES rarities (id),
        FOREIGN KEY (item_type_id) REFERENCES item_types (id)
      )
    ''');

    // ==========================================
    // 10. food_store
    // ==========================================
    await db.execute('''
      CREATE TABLE food_store (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price INTEGER NOT NULL,
        benefit_value INTEGER NOT NULL,
        sprite_url TEXT
      )
    ''');

    // ==========================================
    // 11. user_foods
    // ==========================================
    await db.execute('''
      CREATE TABLE user_foods (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        food_store_id TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (food_store_id) REFERENCES food_store (id)
      )
    ''');

    // ==========================================
    // 12. user_inventory
    // ==========================================
    await db.execute('''
      CREATE TABLE user_inventory (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        gacha_item_id TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        experience_points INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'in_storage',
        acquired_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (gacha_item_id) REFERENCES gacha_items (id)
      )
    ''');

    // ==========================================
    // Seed: lookup tables
    // ==========================================
    await _seedLookupTables(db);
  }

  Future<void> _seedLookupTables(Database db) async {
    // Transaction types
    final txnTypes = ['pomodoro_reward', 'gacha_pull', 'food_purchase'];
    for (final name in txnTypes) {
      await db.insert('transaction_types', {'id': _uuid.v4(), 'name': name});
    }

    // Rarities
    final rarities = [
      {'name': 'Common', 'drop_weight': 70},
      {'name': 'Rare', 'drop_weight': 25},
      {'name': 'Epic', 'drop_weight': 5},
    ];
    for (final r in rarities) {
      await db.insert('rarities', {'id': _uuid.v4(), ...r});
    }

    // Item types
    final itemTypes = ['animal', 'decoration', 'background'];
    for (final name in itemTypes) {
      await db.insert('item_types', {'id': _uuid.v4(), 'name': name});
    }

    // Default categories (no user_id → global)
    final categories = [
      {'name': 'Work', 'color_hex': '#4CAF50'},
      {'name': 'Study', 'color_hex': '#2196F3'},
    ];
    for (final c in categories) {
      await db.insert('categories', {'id': _uuid.v4(), ...c});
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration system: add migration steps as versions increase
    // if (oldVersion < 2) { ... }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
