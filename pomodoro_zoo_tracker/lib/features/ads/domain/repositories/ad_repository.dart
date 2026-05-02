abstract class AdRepository {
  Future<void> loadRewardedAd();
  Future<void> showRewardedAd({required Function(int) onEarnedReward});
}
