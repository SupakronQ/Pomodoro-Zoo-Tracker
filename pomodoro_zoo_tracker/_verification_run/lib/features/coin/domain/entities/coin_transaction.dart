class CoinTransaction {
  final String id;
  final String userId;
  final String transactionTypeId;
  final int amount;
  final int balanceAfter;
  final String? referenceId;
  final DateTime createdAt;

  const CoinTransaction({
    required this.id,
    required this.userId,
    required this.transactionTypeId,
    required this.amount,
    required this.balanceAfter,
    this.referenceId,
    required this.createdAt,
  });
}
