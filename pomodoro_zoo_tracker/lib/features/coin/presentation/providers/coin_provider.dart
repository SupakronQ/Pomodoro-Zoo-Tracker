import 'package:flutter/material.dart';
import '../../domain/usecases/calculate_coins.dart';

// Provider — UI State สำหรับ Coin
class CoinProvider extends ChangeNotifier {
  final CalculateCoins calculateCoinsUseCase;

  CoinProvider({required this.calculateCoinsUseCase});

  int _coinBalance = 0;
  int _totalFocusSeconds = 0;
  int _awardedHours = 0;

  int get coinBalance => _coinBalance;
  int get totalFocusSeconds => _totalFocusSeconds;
  int get awardedHours => _awardedHours;

  /// วินาทีที่เหลือจนกว่าจะได้เหรียญรอบถัดไป
  int get secondsUntilNextCoin {
    final nextThreshold = (_awardedHours + 1) * CalculateCoins.secondsPerHour;
    return nextThreshold - _totalFocusSeconds;
  }

  /// เรียกทุก 1 วินาทีที่ timer tick ใน focus phase
  void addFocusSecond() {
    _totalFocusSeconds += 1;
    _checkAndAwardCoins();
    notifyListeners();
  }

  /// สำหรับทดสอบ — กระโดดไป 5 วินาทีก่อนครบ 1 ชม. ถัดไป
  void skipToBeforeOneHour() {
    final nextThreshold = (_awardedHours + 1) * CalculateCoins.secondsPerHour;
    _totalFocusSeconds = nextThreshold - 5;
    notifyListeners();
  }

  void _checkAndAwardCoins() {
    final newCoins = calculateCoinsUseCase(
      totalFocusSeconds: _totalFocusSeconds,
      awardedHours: _awardedHours,
    );
    if (newCoins > 0) {
      _coinBalance += newCoins;
      _awardedHours = _totalFocusSeconds ~/ CalculateCoins.secondsPerHour;
    }
  }

  /// Format วินาทีเป็น MM:SS
  String formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
