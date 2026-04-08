import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pomodoro_zoo_tracker/core/database/database_helper.dart';
import 'package:pomodoro_zoo_tracker/features/category/data/datasources/category_local_datasource.dart';
import 'package:pomodoro_zoo_tracker/features/category/data/models/category_model.dart';

void main() {
  late DatabaseHelper dbHelper;
  late CategoryLocalDataSource dataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    dataSource = CategoryLocalDataSource(dbHelper);
    
    // เคลียร์ตารางทุกครั้งก่อนเริ่มแต่ละตัวทดสอบ
    final db = await dbHelper.database;
    await db.execute('DELETE FROM categories');
  });

  test('1. Should insert and fetch a category correctly (Create & Read)', () async {
    const newCat = CategoryModel(id: '', name: 'Test Category', colorHex: '#00FF00');

    final createdCat = await dataSource.createCategory(newCat);
    final categories = await dataSource.getCategories();

    print('✅ Created Category ID: \${createdCat.id}');
    expect(categories.length, 1);
    expect(categories.first.name, 'Test Category');
    expect(categories.first.id, createdCat.id); // ระบบต้องปั้ม UUID มาให้เอง
  });

  test('2. Should update a category correctly (Update)', () async {
    final newCat = await dataSource.createCategory(const CategoryModel(id: '', name: 'Old', colorHex: '#000000'));
    
    final toUpdate = CategoryModel(id: newCat.id, name: 'New Name', colorHex: '#FFFFFF');
    await dataSource.updateCategory(toUpdate);
    
    final categories = await dataSource.getCategories();

    print('✅ Updated Name: \${categories.first.name}');
    expect(categories.length, 1);
    expect(categories.first.name, 'New Name');
    expect(categories.first.colorHex, '#FFFFFF');
  });

  test('3. Should delete a category correctly (Delete)', () async {
    final newCat = await dataSource.createCategory(const CategoryModel(id: '', name: 'Delete Me', colorHex: '#FFF'));
    
    await dataSource.deleteCategory(newCat.id);
    final categories = await dataSource.getCategories();

    print('✅ Categories Remained: \${categories.length}');
    expect(categories.isEmpty, true);
  });
}
