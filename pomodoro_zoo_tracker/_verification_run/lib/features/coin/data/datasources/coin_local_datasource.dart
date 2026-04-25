import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../models/coin_transaction_model.dart';

class CoinLocalDataSource {
  final DatabaseHelper dbHelper;
  final Uuid _uuid = const Uuid();

  CoinLocalDataSource(this.dbHelper);

  Future<Database> get db async => await dbHelper.database;

  Future<int> getBalance(String userId) async {
    final database = await db;
    final result = await database.query(
      'users',
      columns: ['coin_balance'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first['coin_balance'] as int;
    }
    return 0; // default if not found
  }

  Future<void> addCoins(String userId, int amount, String transactionTypeId, {String? referenceId}) async {
    final database = await db;
    await database.transaction((txn) async {
      // Get current balance
      final result = await txn.query('users', columns: ['coin_balance'], where: 'id = ?', whereArgs: [userId]);
      int currentBalance = result.isNotEmpty ? result.first['coin_balance'] as int : 0;
      
      int newBalance = currentBalance + amount;
      
      // Update balance
      await txn.update('users', {'coin_balance': newBalance}, where: 'id = ?', whereArgs: [userId]);
      
      // Get type ID 
      final typeResult = await txn.query('transaction_types', where: 'name = ?', whereArgs: [transactionTypeId]);
      String resolvedTypeId = transactionTypeId;
      if (typeResult.isNotEmpty) {
        resolvedTypeId = typeResult.first['id'] as String;
      }

      // Record transaction
      await txn.insert('transactions', {
        'id': _uuid.v4(),
        'user_id': userId,
        'transaction_type_id': resolvedTypeId,
        'amount': amount,
        'balance_after': newBalance,
        'reference_id': referenceId,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> spendCoins(String userId, int amount, String transactionTypeId, {String? referenceId}) async {
    final database = await db;
    await database.transaction((txn) async {
      final result = await txn.query('users', columns: ['coin_balance'], where: 'id = ?', whereArgs: [userId]);
      int currentBalance = result.isNotEmpty ? result.first['coin_balance'] as int : 0;
      
      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }
      
      int newBalance = currentBalance - amount;
      await txn.update('users', {'coin_balance': newBalance}, where: 'id = ?', whereArgs: [userId]);
      
      final typeResult = await txn.query('transaction_types', where: 'name = ?', whereArgs: [transactionTypeId]);
      String resolvedTypeId = transactionTypeId;
      if (typeResult.isNotEmpty) {
        resolvedTypeId = typeResult.first['id'] as String;
      }

      await txn.insert('transactions', {
        'id': _uuid.v4(),
        'user_id': userId,
        'transaction_type_id': resolvedTypeId,
        'amount': -amount, // negative for spending
        'balance_after': newBalance,
        'reference_id': referenceId,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(String userId) async {
    final database = await db;
    return await database.rawQuery('''
      SELECT t.*, type.name as type_name
      FROM transactions t
      LEFT JOIN transaction_types type ON t.transaction_type_id = type.id
      WHERE t.user_id = ?
      ORDER BY t.created_at DESC
    ''', [userId]);
  }
}
