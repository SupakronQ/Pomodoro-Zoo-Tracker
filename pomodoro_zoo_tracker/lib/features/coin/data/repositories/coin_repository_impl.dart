import '../../domain/entities/coin_transaction.dart';
import '../../domain/repositories/coin_repository.dart';
import '../datasources/coin_local_datasource.dart';
import '../models/coin_transaction_model.dart';

class CoinRepositoryImpl implements CoinRepository {
  final CoinLocalDataSource dataSource;

  CoinRepositoryImpl(this.dataSource);

  @override
  Future<int> getBalance(String userId) async {
    return await dataSource.getBalance(userId);
  }

  @override
  Future<void> addCoins(String userId, int amount, String transactionTypeId, {String? referenceId}) async {
    await dataSource.addCoins(userId, amount, transactionTypeId, referenceId: referenceId);
  }

  @override
  Future<void> spendCoins(String userId, int amount, String transactionTypeId, {String? referenceId}) async {
    await dataSource.spendCoins(userId, amount, transactionTypeId, referenceId: referenceId);
  }

  @override
  Future<List<CoinTransaction>> getTransactionHistory(String userId) async {
    final rawList = await dataSource.getTransactionHistory(userId);
    return rawList.map((map) => CoinTransactionModel.fromMap(map)).toList();
  }
}
