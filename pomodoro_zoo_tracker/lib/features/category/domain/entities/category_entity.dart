class CategoryEntity {
  final String id;
  final String? userId;
  final String name;
  final String colorHex;

  const CategoryEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.colorHex,
  });
}
