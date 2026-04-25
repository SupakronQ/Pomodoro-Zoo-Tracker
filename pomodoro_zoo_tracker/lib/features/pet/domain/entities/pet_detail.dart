import 'pet_food_inventory.dart';

class PetDetail {
  final String userAnimalId;
  final String animalId;
  final String name;
  final String rarityName;
  final String spriteUrl;
  final int level;
  final int hungerLevel;
  final int experiencePoints;
  final int experienceToNextLevel;
  final bool isShowcased;
  final int stage;
  final int? nextStageLevel;
  final List<PetFoodInventory> foods;

  const PetDetail({
    required this.userAnimalId,
    required this.animalId,
    required this.name,
    required this.rarityName,
    required this.spriteUrl,
    required this.level,
    required this.hungerLevel,
    required this.experiencePoints,
    required this.experienceToNextLevel,
    required this.isShowcased,
    required this.stage,
    required this.nextStageLevel,
    required this.foods,
  });

  double get hungerProgress => hungerLevel / 100.0;

  double get growthProgress {
    final target = experienceToNextLevel <= 0 ? 1 : experienceToNextLevel;
    final progress = experiencePoints / target;
    if (progress < 0) {
      return 0;
    }
    if (progress > 1) {
      return 1;
    }
    return progress;
  }

  int get totalInventoryCount =>
      foods.fold(0, (sum, food) => sum + food.quantity);

  bool get isFull => hungerLevel >= 100;

  String get moodTitle {
    if (hungerLevel >= 80) {
      return 'Happy';
    }
    if (hungerLevel >= 50) {
      return 'Okay';
    }
    return 'Hungry';
  }

  String get moodSubtitle {
    if (hungerLevel >= 80) {
      return 'Feeling Great!';
    }
    if (hungerLevel >= 50) {
      return 'Could Use a Snack';
    }
    return 'Needs Attention';
  }

  PetFoodInventory? foodById(String userFoodId) {
    for (final food in foods) {
      if (food.userFoodId == userFoodId) {
        return food;
      }
    }
    return null;
  }
}
