import '../models/reward_model.dart';
import 'base_view_model.dart';

// Placeholder for RewardsApiService - to be implemented
class RewardsApiService {
  Future<List<dynamic>> getAvailableRewards() async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<dynamic>> getUserRewards() async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<dynamic>> getRewardHistory() async {
    // TODO: Implement actual API call
    return [];
  }

  Future<Map<String, dynamic>> getUserPoints() async {
    // TODO: Implement actual API call
    return {'points': 0};
  }

  Future<void> redeemReward(String rewardId) async {
    // TODO: Implement actual API call
  }
}

class RewardsViewModel extends BaseViewModel {
  List<RewardModel> _availableRewards = [];
  List<Map<String, dynamic>> _userRewards = [];
  List<Map<String, dynamic>> _rewardHistory = [];
  int _userPoints = 0;

  List<RewardModel> get availableRewards => _availableRewards;
  List<Map<String, dynamic>> get userRewards => _userRewards;
  List<Map<String, dynamic>> get rewardHistory => _rewardHistory;
  int get userPoints => _userPoints;

  Future<void> loadAvailableRewards() async {
    try {
      setLoading();
      final data = await RewardsApiService().getAvailableRewards();
      _availableRewards = (data as List)
          .map((json) => RewardModel.fromJson(json))
          .toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadUserRewards() async {
    try {
      setLoading();
      final data = await RewardsApiService().getUserRewards();
      _userRewards = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadRewardHistory() async {
    try {
      setLoading();
      final data = await RewardsApiService().getRewardHistory();
      _rewardHistory = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadUserPoints() async {
    try {
      setLoading();
      final data = await RewardsApiService().getUserPoints();
      _userPoints = data['points'] ?? 0;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> redeemReward(String rewardId) async {
    try {
      setLoading();
      await RewardsApiService().redeemReward(rewardId);
      // Refresh user points and rewards after redemption
      await loadUserPoints();
      await loadUserRewards();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> refreshRewardsData() async {
    await Future.wait([
      loadAvailableRewards(),
      loadUserRewards(),
      loadUserPoints(),
    ]);
  }
}
