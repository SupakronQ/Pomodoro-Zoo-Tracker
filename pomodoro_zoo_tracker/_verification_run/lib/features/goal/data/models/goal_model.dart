import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.targetIntervals,
    required super.deadline,
    super.coinEarned = 0,
    super.status = GoalStatus.active,
    required super.createdAt,
    super.finishedAt,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      name: map['name'] as String,
      categoryId: map['category_id'] as String,
      targetIntervals: map['target_intervals'] as int,
      deadline: DateTime.parse(map['deadline'] as String),
      coinEarned: (map['coin_earned'] as int?) ?? 0,
      status: GoalStatus.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      finishedAt: map['finished_at'] != null
          ? DateTime.parse(map['finished_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'target_intervals': targetIntervals,
      'deadline': deadline.toIso8601String(),
      'coin_earned': coinEarned,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
    };
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      targetIntervals: entity.targetIntervals,
      deadline: entity.deadline,
      coinEarned: entity.coinEarned,
      status: entity.status,
      createdAt: entity.createdAt,
      finishedAt: entity.finishedAt,
    );
  }
}
