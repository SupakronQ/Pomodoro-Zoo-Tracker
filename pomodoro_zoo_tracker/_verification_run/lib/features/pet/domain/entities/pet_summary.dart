class PetSummary {
  final String userAnimalId;
  final String animalId;
  final String name;
  final int level;
  final int hungerLevel;
  final bool isShowcased;
  final String rarityName;
  final String spriteUrl;

  const PetSummary({
    required this.userAnimalId,
    required this.animalId,
    required this.name,
    required this.level,
    required this.hungerLevel,
    required this.isShowcased,
    required this.rarityName,
    required this.spriteUrl,
  });
}
