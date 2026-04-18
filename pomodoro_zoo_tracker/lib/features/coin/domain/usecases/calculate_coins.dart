// UseCase: คำนวณเหรียญจากเวลา focus สะสม
class CalculateCoins {
  static const int coinsPerHour = 10;
  static const int secondsPerHour = 3600;

  /// คืนจำนวนเหรียญใหม่ที่ควรได้รับ
  /// จาก totalFocusSeconds ที่สะสมมา เทียบกับ awardedHours ที่ให้ไปแล้ว
  int call({required int totalFocusSeconds, required int awardedHours}) {
    final completedHours = totalFocusSeconds ~/ secondsPerHour;
    final newHours = completedHours - awardedHours;
    if (newHours <= 0) return 0;
    return newHours * coinsPerHour;
  }
}
