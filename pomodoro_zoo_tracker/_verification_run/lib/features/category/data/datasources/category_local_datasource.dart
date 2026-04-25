import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  final DatabaseHelper dbHelper;
  final Uuid _uuid = const Uuid();

  CategoryLocalDataSource(this.dbHelper);

  Future<Database> get db async => await dbHelper.database;

  Future<List<CategoryModel>> getCategories({String? userId}) async {
    final categoryDb = await db;
    // Assuming if userId is null, we fetch 'global' or 'default' categories where user_id is null
    String whereStr = userId == null ? 'user_id IS NULL' : 'user_id = ? OR user_id IS NULL';
    List<dynamic> whereArgs = userId == null ? [] : [userId];

    final result = await categoryDb.query(
      'categories',
      where: whereStr,
      whereArgs: whereArgs,
    );
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final categoryDb = await db;
    final modelToInsert = CategoryModel(
      id: category.id.isEmpty ? _uuid.v4() : category.id,
      userId: category.userId,
      name: category.name,
      colorHex: category.colorHex,
    );
    await categoryDb.insert('categories', modelToInsert.toMap());
    return modelToInsert;
  }

  Future<void> updateCategory(CategoryModel category) async {
    final categoryDb = await db;
    await categoryDb.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final categoryDb = await db;
    await categoryDb.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
