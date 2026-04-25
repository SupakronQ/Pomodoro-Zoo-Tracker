class PetFoodInventory {
  final String userFoodId;
  final String foodId;
  final String name;
  final String description;
  final int benefitValue;
  final int quantity;
  final String spriteUrl;

  const PetFoodInventory({
    required this.userFoodId,
    required this.foodId,
    required this.name,
    required this.description,
    required this.benefitValue,
    required this.quantity,
    required this.spriteUrl,
  });

  bool get isAvailable => quantity > 0;
}
