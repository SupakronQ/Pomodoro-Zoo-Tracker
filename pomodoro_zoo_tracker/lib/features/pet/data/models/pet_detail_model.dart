import '../../domain/entities/pet_detail.dart';
import '../../domain/entities/pet_food_inventory.dart';

class PetDetailModel extends PetDetail {
  const PetDetailModel({
    required super.userAnimalId,
    required super.animalId,
    required super.name,
    required super.rarityName,
    required super.spriteUrl,
    required super.level,
    required super.hungerLevel,
    required super.experiencePoints,
    required super.experienceToNextLevel,
    required super.isShowcased,
    required super.stage,
    required super.nextStageLevel,
    required super.foods,
  });

  factory PetDetailModel.fromMap(
    Map<String, dynamic> map,
    List<PetFoodInventory> foods,
  ) {
    return PetDetailModel(
      userAnimalId: map['user_animal_id'] as String,
      animalId: map['animal_id'] as String,
      name: map['name'] as String? ?? 'Unknown Pet',
      rarityName: map['rarity_name'] as String? ?? 'Rare',
      spriteUrl: map['sprite_url'] as String? ?? '',
      level: (map['level'] as int?) ?? 1,
      hungerLevel: (map['hunger_level'] as int?) ?? 100,
      experiencePoints: (map['experience_points'] as int?) ?? 0,
      experienceToNextLevel: (map['experience_to_next_level'] as int?) ?? 100,
      isShowcased: ((map['is_showcased'] as int?) ?? 0) == 1,
      stage: (map['stage'] as int?) ?? 1,
      nextStageLevel: map['next_stage_level'] as int?,
      foods: foods,
    );
  }
}
