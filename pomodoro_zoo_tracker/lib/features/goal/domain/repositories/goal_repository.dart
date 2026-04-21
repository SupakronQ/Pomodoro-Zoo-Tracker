import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<List<GoalEntity>> getAllGoals();
  Future<List<GoalEntity>> getGoalsForCategory(String categoryId);
  Future<GoalEntity> createGoal(GoalEntity goal);
  Future<void> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(String id);
  Future<void> deleteGoalsForCategory(String categoryId);
}
