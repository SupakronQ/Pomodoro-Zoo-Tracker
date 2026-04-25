class CategoryEntity {
  final String id;
  final String? userId;
  final String name;
  final String colorHex;
  final int iconCodePoint;

  const CategoryEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.colorHex,
    this.iconCodePoint = 0xe4c2, // Icons.label_outlined
  });
}
