import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository repository;

  CategoryProvider({required this.repository});

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    _categories = await repository.getCategories(userId: userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCategory(CategoryEntity category) async {
    await repository.createCategory(category);
    await loadCategories(userId: category.userId);
  }

  Future<void> updateCategory(CategoryEntity category) async {
    await repository.updateCategory(category);
    await loadCategories(userId: category.userId);
  }

  Future<void> deleteCategory(String id, {String? currentUserId}) async {
    await repository.deleteCategory(id);
    await loadCategories(userId: currentUserId);
  }
}
