import '../../domain/entities/coin_transaction.dart';

class CoinTransactionModel extends CoinTransaction {
  const CoinTransactionModel({
    required super.id,
    required super.userId,
    required super.transactionTypeId,
    required super.amount,
    required super.balanceAfter,
    super.referenceId,
    required super.createdAt,
  });

  factory CoinTransactionModel.fromMap(Map<String, dynamic> map) {
    return CoinTransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      transactionTypeId: map['transaction_type_id'] as String? ?? map['type_name'] as String? ?? '',
      amount: map['amount'] as int,
      balanceAfter: map['balance_after'] as int,
      referenceId: map['reference_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
