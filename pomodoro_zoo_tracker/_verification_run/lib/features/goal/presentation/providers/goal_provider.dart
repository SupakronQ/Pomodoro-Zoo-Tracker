import 'package:flutter/material.dart';

import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository repository;

  GoalProvider({required this.repository});

  List<GoalEntity> _goals = [];
  bool _isLoading = false;

  List<GoalEntity> get goals => _goals;
  bool get isLoading => _isLoading;

  List<GoalEntity> getGoalsForCategory(String categoryId) =>
      _goals.where((g) => g.categoryId == categoryId).toList();

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    _goals = await repository.getAllGoals();
    _isLoading = false;
    notifyListeners();
  }

  /// Replaces all goals for [categoryId] with [newGoals].
  Future<void> replaceGoalsForCategory(
    String categoryId,
    List<GoalEntity> newGoals,
  ) async {
    await repository.deleteGoalsForCategory(categoryId);
    for (final goal in newGoals) {
      await repository.createGoal(goal);
    }
    await loadGoals();
  }

  Future<void> deleteGoalsForCategory(String categoryId) async {
    await repository.deleteGoalsForCategory(categoryId);
    await loadGoals();
  }
}
