import 'package:flutter/material.dart';
import '../../domain/repositories/coin_repository.dart';

class CoinProvider extends ChangeNotifier {
  final CoinRepository repository;
  String? currentUserId;

  CoinProvider({required this.repository});

  int _balance = 0;
  int get balance => _balance;

  Future<void> loadBalance(String userId) async {
    currentUserId = userId;
    _balance = await repository.getBalance(userId);
    notifyListeners();
  }

  Future<void> addCoins(
    int amount,
    String transactionTypeId, {
    String? referenceId,
  }) async {
    if (currentUserId == null) return;
    await repository.addCoins(
      currentUserId!,
      amount,
      transactionTypeId,
      referenceId: referenceId,
    );
    await loadBalance(currentUserId!);
  }

  Future<void> spendCoins(
    int amount,
    String transactionTypeId, {
    String? referenceId,
  }) async {
    if (currentUserId == null) return;
    await repository.spendCoins(
      currentUserId!,
      amount,
      transactionTypeId,
      referenceId: referenceId,
    );
    await loadBalance(currentUserId!);
  }
}
