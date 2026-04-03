import 'package:dio/dio.dart';
import '../core/api_client.dart';

class LeaderboardApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<dynamic>> getOverallLeaderboard({
    String period = 'monthly',
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/user/leaderboard',
      queryParameters: {'period': period},
    );
    return (response.data?['leaderboard'] as List<dynamic>?) ?? <dynamic>[];
  }

  Future<List<dynamic>> getQuizLeaderboard({String period = 'monthly'}) async {
    // TODO: Implement actual API call
    return <dynamic>[];
  }

  Future<List<dynamic>> getGamesLeaderboard({String period = 'monthly'}) async {
    // TODO: Implement actual API call
    return <dynamic>[];
  }

  Future<List<dynamic>> getDepartmentLeaderboard(
    String departmentId, {
    String period = 'monthly',
  }) async {
    // TODO: Implement actual API call
    return <dynamic>[];
  }

  Future<Map<String, dynamic>> getUserRank() async {
    // TODO: Implement actual API call
    return <String, dynamic>{};
  }
}
