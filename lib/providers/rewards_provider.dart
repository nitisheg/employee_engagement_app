import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/reward_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class RewardsProvider extends ChangeNotifier {
  static const _tag = 'RewardsProvider';

  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  String? _errorMessage;
  List<RewardModel> _availableRewards = [];
  int _userPoints = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RewardModel> get availableRewards => _availableRewards;
  int get userPoints => _userPoints;

  Future<void> fetchRewards() async {
    AppLogger.info(_tag, 'fetchRewards called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/rewards/available',
      );
      final rewards =
          (resp.data!['rewards'] as List?)
              ?.map(
                (json) => RewardModel.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      _availableRewards = rewards;
      AppLogger.success(_tag, 'fetchRewards succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchRewards DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchRewards error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserPoints() async {
    AppLogger.info(_tag, 'fetchUserPoints called');
    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>('/api/user/points');
      _userPoints = resp.data!['points'] as int? ?? 0;
      AppLogger.success(_tag, 'fetchUserPoints succeeded');
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchUserPoints DioException', e);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchUserPoints error', e);
      notifyListeners();
    }
  }

  Future<bool> redeemReward(String rewardId) async {
    AppLogger.info(_tag, 'redeemReward called');
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.post<dynamic>('/api/rewards/$rewardId/redeem');
      // Refresh data after redemption
      await fetchRewards();
      await fetchUserPoints();
      AppLogger.success(_tag, 'redeemReward succeeded');
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'redeemReward DioException', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'redeemReward error', e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    AppLogger.info(_tag, 'clearError called');
    _errorMessage = null;
    notifyListeners();
  }
}
