import '../../domain/entities/pet_food_inventory.dart';

class PetFoodInventoryModel extends PetFoodInventory {
  const PetFoodInventoryModel({
    required super.userFoodId,
    required super.foodId,
    required super.name,
    required super.description,
    required super.benefitValue,
    required super.quantity,
    required super.spriteUrl,
  });

  factory PetFoodInventoryModel.fromMap(Map<String, dynamic> map) {
    return PetFoodInventoryModel(
      userFoodId: map['user_food_id'] as String,
      foodId: map['food_id'] as String,
      name: map['name'] as String? ?? 'Food',
      description: map['description'] as String? ?? '',
      benefitValue: (map['benefit_value'] as int?) ?? 0,
      quantity: (map['quantity'] as int?) ?? 0,
      spriteUrl: map['sprite_url'] as String? ?? '',
    );
  }
}
