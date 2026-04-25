enum GoalStatus {
  active('active'),
  completed('completed'),
  failed('failed'),
  claimed('claimed');

  const GoalStatus(this.value);

  final String value;

  static GoalStatus fromString(String s) {
    return GoalStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => GoalStatus.active,
    );
  }
}

class GoalEntity {
  final String id;
  final String name;
  final String categoryId;
  final int targetIntervals;
  final DateTime deadline;
  final int coinEarned;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? finishedAt;

  const GoalEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.targetIntervals,
    required this.deadline,
    this.coinEarned = 0,
    this.status = GoalStatus.active,
    required this.createdAt,
    this.finishedAt,
  });

  /// 1 interval = 1 Pomodoro session = 25 minutes
  double get targetHours => targetIntervals * 25.0 / 60.0;
}
