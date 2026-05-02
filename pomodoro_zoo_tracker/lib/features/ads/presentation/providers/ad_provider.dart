import 'package:flutter/material.dart';
import '../../domain/repositories/ad_repository.dart';

class AdProvider extends ChangeNotifier {
  final AdRepository adRepository;
  bool _isLoading = false;

  AdProvider({required this.adRepository});

  bool get isLoading => _isLoading;

  Future<void> loadAd() async {
    _isLoading = true;
    notifyListeners();

    await adRepository.loadRewardedAd();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> showAd({required Function(int) onEarnedReward}) async {
    await adRepository.showRewardedAd(onEarnedReward: onEarnedReward);
  }
}
