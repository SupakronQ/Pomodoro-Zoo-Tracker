import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    super.userId,
    required super.name,
    required super.colorHex,
    super.iconCodePoint,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      iconCodePoint: (map['icon_code_point'] as int?) ?? 0xe4c2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color_hex': colorHex,
      'icon_code_point': iconCodePoint,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      colorHex: entity.colorHex,
      iconCodePoint: entity.iconCodePoint,
    );
  }
}
