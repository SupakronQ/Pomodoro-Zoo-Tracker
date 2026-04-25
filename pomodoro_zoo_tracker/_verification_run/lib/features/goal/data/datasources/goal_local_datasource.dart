import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../models/goal_model.dart';

class GoalLocalDataSource {
  final DatabaseHelper dbHelper;
  final Uuid _uuid = const Uuid();

  GoalLocalDataSource(this.dbHelper);

  Future<Database> get _db async => await dbHelper.database;

  Future<List<GoalModel>> getAllGoals() async {
    final db = await _db;
    final rows = await db.query('goals', orderBy: 'created_at DESC');
    return rows.map(GoalModel.fromMap).toList();
  }

  Future<List<GoalModel>> getGoalsForCategory(String categoryId) async {
    final db = await _db;
    final rows = await db.query(
      'goals',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at ASC',
    );
    return rows.map(GoalModel.fromMap).toList();
  }

  Future<GoalModel> createGoal(GoalModel goal) async {
    final db = await _db;
    final model = GoalModel(
      id: goal.id.isEmpty ? _uuid.v4() : goal.id,
      name: goal.name,
      categoryId: goal.categoryId,
      targetIntervals: goal.targetIntervals,
      deadline: goal.deadline,
      coinEarned: goal.coinEarned,
      status: goal.status,
      createdAt: goal.createdAt,
      finishedAt: goal.finishedAt,
    );
    await db.insert('goals', model.toMap());
    return model;
  }

  Future<void> updateGoal(GoalModel goal) async {
    final db = await _db;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await _db;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGoalsForCategory(String categoryId) async {
    final db = await _db;
    await db.delete('goals', where: 'category_id = ?', whereArgs: [categoryId]);
  }
}
