class DailyActivity {
  final String dayName;   // e.g., 'M', 'T', 'W'
  final int weekday;      // 1=Mon, 7=Sun
  final int totalMinutes; // minutes spent

  const DailyActivity({
    required this.dayName,
    required this.weekday,
    required this.totalMinutes,
  });
}
