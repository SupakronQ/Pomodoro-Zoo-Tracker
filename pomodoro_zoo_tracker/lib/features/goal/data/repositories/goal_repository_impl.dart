import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource dataSource;

  GoalRepositoryImpl(this.dataSource);

  @override
  Future<List<GoalEntity>> getAllGoals() => dataSource.getAllGoals();

  @override
  Future<List<GoalEntity>> getGoalsForCategory(String categoryId) =>
      dataSource.getGoalsForCategory(categoryId);

  @override
  Future<GoalEntity> createGoal(GoalEntity goal) =>
      dataSource.createGoal(GoalModel.fromEntity(goal));

  @override
  Future<void> updateGoal(GoalEntity goal) =>
      dataSource.updateGoal(GoalModel.fromEntity(goal));

  @override
  Future<void> deleteGoal(String id) => dataSource.deleteGoal(id);

  @override
  Future<void> deleteGoalsForCategory(String categoryId) =>
      dataSource.deleteGoalsForCategory(categoryId);
}
