import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/leaderboard_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class LeaderboardProvider extends ChangeNotifier {
  static const _tag = 'LeaderboardProvider';

  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  String? _errorMessage;
  List<LeaderboardEntry> _entries = [];
  LeaderboardEntry? _currentUserEntry;
  LeaderboardPeriod _currentPeriod = LeaderboardPeriod.allTime;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LeaderboardEntry> get entries => _entries;
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  LeaderboardPeriod get currentPeriod => _currentPeriod;

  Future<void> fetchLeaderboard(LeaderboardPeriod period) async {
    AppLogger.info(_tag, 'fetchLeaderboard called');
    _isLoading = true;
    _errorMessage = null;
    _currentPeriod = period;
    notifyListeners();

    try {
      final endpoint = '/api/user/leaderboard';
      final resp = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'period': _periodToString(period)},
      );

      final responseData = resp.data ?? <String, dynamic>{};
      final leaderboardData = LeaderboardResponse.fromJson(responseData);
      _entries = leaderboardData.entries;
      _currentUserEntry = leaderboardData.currentUserEntry;
      AppLogger.success(_tag, 'fetchLeaderboard succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _entries = [];
      _currentUserEntry = null;
      AppLogger.error(_tag, 'fetchLeaderboard DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      _entries = [];
      _currentUserEntry = null;
      AppLogger.error(_tag, 'fetchLeaderboard error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  String _periodToString(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.allTime:
        return 'all-time';
      case LeaderboardPeriod.monthly:
        return 'monthly';
      case LeaderboardPeriod.weekly:
        return 'weekly';
      case LeaderboardPeriod.today:
        return 'today';
      case LeaderboardPeriod.teams:
        return 'teams';
    }
  }

  void clearError() {
    AppLogger.info(_tag, 'clearError called');
    _errorMessage = null;
    notifyListeners();
  }
}
