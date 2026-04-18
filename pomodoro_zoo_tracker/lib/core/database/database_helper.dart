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
      version: 2,
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
        coin_balance INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        last_active_date TEXT,
        created_at TEXT
      )
    ''');

    // ==========================================
    // 2. transaction_types
    // ==========================================
    await db.execute('''
      CREATE TABLE transaction_types (
        id TEXT PRIMARY KEY,
        name TEXT,
        display_name TEXT
      )
    ''');

    // ==========================================
    // 3. transactions
    // ==========================================
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        transaction_type_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        balance_after INTEGER NOT NULL,
        reference_id TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (transaction_type_id) REFERENCES transaction_types (id)
      )
    ''');

    // ==========================================
    // 4. categories
    // ==========================================
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT,
        color_hex TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // ==========================================
    // 5. goals
    // ==========================================
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id TEXT NOT NULL,
        target_intervals INTEGER NOT NULL,
        deadline TEXT NOT NULL,
        coin_earned INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        finished_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // ==========================================
    // 6. pomodoro_sessions
    // ==========================================
    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        category_id TEXT,
        duration_minutes INTEGER,
        coins_earned INTEGER DEFAULT 0,
        status TEXT,
        created_at TEXT,
        ended_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // ==========================================
    // 7. rarities
    // ==========================================
    await db.execute('''
      CREATE TABLE rarities (
        id TEXT PRIMARY KEY,
        name TEXT,
        drop_weight INTEGER
      )
    ''');

    // ==========================================
    // 8. item_types
    // ==========================================
    await db.execute('''
      CREATE TABLE item_types (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');

    // ==========================================
    // 9. items
    // ==========================================
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        item_type_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        sprite_url TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (item_type_id) REFERENCES item_types (id)
      )
    ''');

    // ==========================================
    // 10. animals
    // ==========================================
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        stage INTEGER NOT NULL,
        next_stage_level INTEGER,
        FOREIGN KEY (id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // ==========================================
    // 11. decorations
    // ==========================================
    await db.execute('''
      CREATE TABLE decorations (
        id TEXT PRIMARY KEY,
        width_cells INTEGER DEFAULT 1,
        height_cells INTEGER DEFAULT 1,
        FOREIGN KEY (id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // ==========================================
    // 12. backgrounds
    // ==========================================
    await db.execute('''
      CREATE TABLE backgrounds (
        id TEXT PRIMARY KEY,
        FOREIGN KEY (id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    // ==========================================
    // 13. gacha_pools
    // ==========================================
    await db.execute('''
      CREATE TABLE gacha_pools (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // ==========================================
    // 14. gacha_items
    // ==========================================
    await db.execute('''
      CREATE TABLE gacha_items (
        id TEXT PRIMARY KEY,
        rarity_id TEXT NOT NULL,
        gacha_pool_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        FOREIGN KEY (rarity_id) REFERENCES rarities (id),
        FOREIGN KEY (gacha_pool_id) REFERENCES gacha_pools (id),
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // ==========================================
    // 15. food
    // ==========================================
    await db.execute('''
      CREATE TABLE food (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price INTEGER DEFAULT 0,
        benefit_value INTEGER DEFAULT 1,
        sprite_url TEXT NOT NULL
      )
    ''');

    // ==========================================
    // 16. user_foods
    // ==========================================
    await db.execute('''
      CREATE TABLE user_foods (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        food_id TEXT,
        quantity INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (food_id) REFERENCES food (id)
      )
    ''');

    // ==========================================
    // 17. user_animals
    // ==========================================
    await db.execute('''
      CREATE TABLE user_animals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        animal_id TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        experience_points INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (animal_id) REFERENCES animals (id)
      )
    ''');

    // ==========================================
    // 18. user_decorations
    // ==========================================
    await db.execute('''
      CREATE TABLE user_decorations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        decoration_id TEXT NOT NULL,
        quantity INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (decoration_id) REFERENCES decorations (id)
      )
    ''');

    // ==========================================
    // 19. user_backgrounds
    // ==========================================
    await db.execute('''
      CREATE TABLE user_backgrounds (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        background_id TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (background_id) REFERENCES backgrounds (id)
      )
    ''');

    // ==========================================
    // 20. zoo
    // ==========================================
    await db.execute('''
      CREATE TABLE zoo (
        id TEXT PRIMARY KEY,
        showcase_animal_id TEXT NOT NULL,
        background_id TEXT NOT NULL,
        FOREIGN KEY (showcase_animal_id) REFERENCES user_animals (id),
        FOREIGN KEY (background_id) REFERENCES user_backgrounds (id)
      )
    ''');

    // ==========================================
    // Seed: lookup tables
    // ==========================================
    await _seedLookupTables(db);
  }

  Future<void> _seedLookupTables(Database db) async {
    // Transaction types
    final txnTypes = [
      {'name': 'pomodoro_session', 'display_name': 'Completed Session'},
      {'name': 'goal_completion', 'display_name': 'Completed Goal'},
      {'name': 'ad_reward', 'display_name': 'Ad Reward'},
      {'name': 'gacha_pull', 'display_name': 'Gacha Pull'},
      {'name': 'food_purchase', 'display_name': 'Food Purchase'}
    ];
    for (final t in txnTypes) {
      await db.insert('transaction_types', {'id': _uuid.v4(), ...t});
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

    // Default categories
    final categories = [
      {'name': 'Work', 'color_hex': '#4CAF50'},
      {'name': 'Study', 'color_hex': '#2196F3'},
    ];
    for (final c in categories) {
      await db.insert('categories', {'id': _uuid.v4(), ...c});
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop all possible existing tables
      final tablesToDrop = [
        'user_inventory',
        'user_foods',
        'food_store',
        'gacha_items',
        'item_types',
        'rarities',
        'pomodoro_sessions',
        'categories',
        'goals',
        'coin_transactions',
        'transaction_types',
        'users',
        'zoo',
        'user_backgrounds',
        'user_decorations',
        'user_animals',
        'food',
        'gacha_pools',
        'backgrounds',
        'decorations',
        'animals',
        'items',
        'transactions'
      ];
      for (final table in tablesToDrop) {
        await db.execute('DROP TABLE IF EXISTS $table');
      }

      // Re-create the tables
      await _onCreate(db, newVersion);
    }
  }

  Future<String> getOrCreateGuestUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    if (result.isNotEmpty) {
      return result.first['id'] as String;
    }

    final newId = _uuid.v4();
    await db.insert('users', {
      'id': newId,
      'username': 'Guest',
      'coin_balance': 0,
      'current_streak': 0,
      'last_active_date': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
    return newId;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
