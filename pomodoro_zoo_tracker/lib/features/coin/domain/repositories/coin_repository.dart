import '../entities/coin_transaction.dart';

abstract class CoinRepository {
  Future<int> getBalance(String userId);
  Future<void> addCoins(String userId, int amount, String transactionTypeId, {String? referenceId});
  Future<void> spendCoins(String userId, int amount, String transactionTypeId, {String? referenceId});
  Future<List<CoinTransaction>> getTransactionHistory(String userId);
}
