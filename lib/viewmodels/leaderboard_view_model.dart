import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';
import 'base_view_model.dart';

class LeaderboardApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<dynamic>> getOverallLeaderboard({
    String period = 'monthly',
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/user/leaderboard',
      queryParameters: {'period': period},
    );
    return (resp.data?['leaderboard'] as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> getQuizLeaderboard({String period = 'monthly'}) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<dynamic>> getGamesLeaderboard({String period = 'monthly'}) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<dynamic>> getDepartmentLeaderboard(
    String departmentId, {
    String period = 'monthly',
  }) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<Map<String, dynamic>> getUserRank() async {
    // TODO: Implement actual API call
    return {};
  }
}

class LeaderboardViewModel extends BaseViewModel {
  static const _tag = 'LeaderboardViewModel';

  List<Map<String, dynamic>> _overallLeaderboard = [];
  List<Map<String, dynamic>> _quizLeaderboard = [];
  List<Map<String, dynamic>> _gamesLeaderboard = [];
  List<Map<String, dynamic>> _departmentLeaderboard = [];
  Map<String, dynamic>? _userRank;

  List<Map<String, dynamic>> get overallLeaderboard => _overallLeaderboard;
  List<Map<String, dynamic>> get quizLeaderboard => _quizLeaderboard;
  List<Map<String, dynamic>> get gamesLeaderboard => _gamesLeaderboard;
  List<Map<String, dynamic>> get departmentLeaderboard =>
      _departmentLeaderboard;
  Map<String, dynamic>? get userRank => _userRank;

  Future<void> loadOverallLeaderboard({String period = 'monthly'}) async {
    AppLogger.info(_tag, 'loadOverallLeaderboard called');
    try {
      setLoading();
      final data = await LeaderboardApiService().getOverallLeaderboard(
        period: period,
      );
      _overallLeaderboard = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadOverallLeaderboard succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadOverallLeaderboard error', e);
      setError(e.toString());
    }
  }

  Future<void> loadQuizLeaderboard({String period = 'monthly'}) async {
    AppLogger.info(_tag, 'loadQuizLeaderboard called');
    try {
      setLoading();
      final data = await LeaderboardApiService().getQuizLeaderboard(
        period: period,
      );
      _quizLeaderboard = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadQuizLeaderboard succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadQuizLeaderboard error', e);
      setError(e.toString());
    }
  }

  Future<void> loadGamesLeaderboard({String period = 'monthly'}) async {
    AppLogger.info(_tag, 'loadGamesLeaderboard called');
    try {
      setLoading();
      final data = await LeaderboardApiService().getGamesLeaderboard(
        period: period,
      );
      _gamesLeaderboard = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadGamesLeaderboard succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadGamesLeaderboard error', e);
      setError(e.toString());
    }
  }

  Future<void> loadDepartmentLeaderboard(
    String departmentId, {
    String period = 'monthly',
  }) async {
    AppLogger.info(_tag, 'loadDepartmentLeaderboard called');
    try {
      setLoading();
      final data = await LeaderboardApiService().getDepartmentLeaderboard(
        departmentId,
        period: period,
      );
      _departmentLeaderboard = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadDepartmentLeaderboard succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadDepartmentLeaderboard error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserRank() async {
    AppLogger.info(_tag, 'loadUserRank called');
    try {
      setLoading();
      _userRank = await LeaderboardApiService().getUserRank();
      AppLogger.success(_tag, 'loadUserRank succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserRank error', e);
      setError(e.toString());
    }
  }

  Future<void> refreshAllLeaderboards({String period = 'monthly'}) async {
    AppLogger.info(_tag, 'refreshAllLeaderboards called');
    await Future.wait([
      loadOverallLeaderboard(period: period),
      loadQuizLeaderboard(period: period),
      loadGamesLeaderboard(period: period),
      loadUserRank(),
    ]);
  }
}
