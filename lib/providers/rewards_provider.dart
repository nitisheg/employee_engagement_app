import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/reward_model.dart';
import '../services/api_service.dart';

class RewardsProvider extends ChangeNotifier {
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
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserPoints() async {
    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>('/api/user/points');
      _userPoints = resp.data!['points'] as int? ?? 0;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> redeemReward(String rewardId) async {
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.post<dynamic>('/api/rewards/$rewardId/redeem');
      // Refresh data after redemption
      await fetchRewards();
      await fetchUserPoints();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
