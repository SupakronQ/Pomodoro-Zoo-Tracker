class StatsEntry {
  final String? categoryId;
  final String categoryName;
  final String colorHex;
  final int totalMinutes;
  final double percentage; // 0.0 to 1.0

  const StatsEntry({
    this.categoryId,
    required this.categoryName,
    required this.colorHex,
    required this.totalMinutes,
    required this.percentage,
  });
}
