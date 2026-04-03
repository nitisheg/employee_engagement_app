import '../models/reward_model.dart';
import '../core/utils/app_logger.dart';
import '../services/api/rewards_api_service.dart';
import 'base_view_model.dart';

class RewardsViewModel extends BaseViewModel {
  static const _tag = 'RewardsViewModel';

  List<RewardModel> _availableRewards = [];
  List<Map<String, dynamic>> _userRewards = [];
  List<Map<String, dynamic>> _rewardHistory = [];
  int _userPoints = 0;

  List<RewardModel> get availableRewards => _availableRewards;
  List<Map<String, dynamic>> get userRewards => _userRewards;
  List<Map<String, dynamic>> get rewardHistory => _rewardHistory;
  int get userPoints => _userPoints;

  Future<void> loadAvailableRewards() async {
    AppLogger.info(_tag, 'loadAvailableRewards called');
    try {
      setLoading();
      final data = await RewardsApiService().getAvailableRewards();
      _availableRewards = (data as List)
          .map((json) => RewardModel.fromJson(json))
          .toList();
      AppLogger.success(_tag, 'loadAvailableRewards succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadAvailableRewards error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserRewards() async {
    AppLogger.info(_tag, 'loadUserRewards called');
    try {
      setLoading();
      final data = await RewardsApiService().getUserRewards();
      _userRewards = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadUserRewards succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserRewards error', e);
      setError(e.toString());
    }
  }

  Future<void> loadRewardHistory() async {
    AppLogger.info(_tag, 'loadRewardHistory called');
    try {
      setLoading();
      final data = await RewardsApiService().getRewardHistory();
      _rewardHistory = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadRewardHistory succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadRewardHistory error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserPoints() async {
    AppLogger.info(_tag, 'loadUserPoints called');
    try {
      setLoading();
      final data = await RewardsApiService().getUserPoints();
      _userPoints = data['points'] ?? 0;
      AppLogger.success(_tag, 'loadUserPoints succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserPoints error', e);
      setError(e.toString());
    }
  }

  Future<void> redeemReward(String rewardId) async {
    AppLogger.info(_tag, 'redeemReward called');
    try {
      setLoading();
      await RewardsApiService().redeemReward(rewardId);
      // Refresh user points and rewards after redemption
      await loadUserPoints();
      await loadUserRewards();
      AppLogger.success(_tag, 'redeemReward succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'redeemReward error', e);
      setError(e.toString());
    }
  }

  Future<void> refreshRewardsData() async {
    AppLogger.info(_tag, 'refreshRewardsData called');
    await Future.wait([
      loadAvailableRewards(),
      loadUserRewards(),
      loadUserPoints(),
    ]);
  }
}
