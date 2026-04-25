import '../../domain/entities/pet_summary.dart';

class PetSummaryModel extends PetSummary {
  const PetSummaryModel({
    required super.userAnimalId,
    required super.animalId,
    required super.name,
    required super.level,
    required super.hungerLevel,
    required super.isShowcased,
    required super.rarityName,
    required super.spriteUrl,
  });

  factory PetSummaryModel.fromMap(Map<String, dynamic> map) {
    return PetSummaryModel(
      userAnimalId: map['user_animal_id'] as String,
      animalId: map['animal_id'] as String,
      name: map['name'] as String? ?? 'Unknown Pet',
      level: (map['level'] as int?) ?? 1,
      hungerLevel: (map['hunger_level'] as int?) ?? 100,
      isShowcased: ((map['is_showcased'] as int?) ?? 0) == 1,
      rarityName: map['rarity_name'] as String? ?? 'Rare',
      spriteUrl: map['sprite_url'] as String? ?? '',
    );
  }
}
