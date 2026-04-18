import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pomodoro_zoo_tracker/core/database/database_helper.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbHelper = DatabaseHelper();
  
  try {
    print('Opening database...');
    final db = await dbHelper.database;
    
    print('Checking tables...');
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print('Tables: ${tables.map((t) => t['name']).toList()}');

    print('Checking coins...');
    final coins = await db.query('coins');
    print('Coins length: ${coins.length}');
    if (coins.isNotEmpty) {
      print('First coin balance: ${coins.first['balance']}');
    }

    print('Checking categories...');
    final categories = await db.query('categories');
    print('Categories length: ${categories.length}');
    for (var cat in categories) {
      print('Category: ${cat['name']}');
    }

    await db.close();
    print('Success!');
  } catch (e, stack) {
    print('Error: $e');
    print('Stack: $stack');
  }
}
