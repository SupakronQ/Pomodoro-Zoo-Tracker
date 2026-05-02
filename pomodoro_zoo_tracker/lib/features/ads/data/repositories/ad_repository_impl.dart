import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../domain/repositories/ad_repository.dart';

class AdRepositoryImpl implements AdRepository {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Test Android Ad Unit ID
      : 'ca-app-pub-3940256099942544/1712485313'; // Test iOS Ad Unit ID

  @override
  Future<void> loadRewardedAd() async {
    if (_isAdLoading) return;
    _isAdLoading = true;

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Load the next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Load the next ad
            },
          );
          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isAdLoading = false;
        },
      ),
    );
  }

  @override
  Future<void> showRewardedAd({required Function(int) onEarnedReward}) async {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded ad before it was loaded.');
      return;
    }

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      // Award the reward
      onEarnedReward(50); // Hardcoded to 50 coins as per requirement
    });
    
    _rewardedAd = null;
  }
}
