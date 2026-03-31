import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/leaderboard_model.dart';
import '../services/api_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  String? _errorMessage;
  LeaderboardResponse? _leaderboardData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LeaderboardResponse? get leaderboardData => _leaderboardData;

  Future<void> fetchLeaderboard(LeaderboardPeriod period) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final endpoint = _getEndpointForPeriod(period);
      final resp = await _dio.get<Map<String, dynamic>>(endpoint);

      _leaderboardData = LeaderboardResponse.fromJson(resp.data!);
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  String _getEndpointForPeriod(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.allTime:
        return '/api/leaderboard/all-time';
      case LeaderboardPeriod.thisMonth:
        return '/api/leaderboard/this-month';
      case LeaderboardPeriod.thisWeek:
        return '/api/leaderboard/this-week';
      case LeaderboardPeriod.teams:
        return '/api/leaderboard/teams';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
