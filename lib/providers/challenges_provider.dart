import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/challenge_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class ChallengesProvider extends ChangeNotifier {
  static const _tag = 'ChallengesProvider';

  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  String? _errorMessage;
  List<ChallengeModel> _activeChallenges = [];
  List<ChallengeModel> _completedChallenges = [];
  List<ChallengeModel> _teamChallenges = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChallengeModel> get activeChallenges => _activeChallenges;
  List<ChallengeModel> get completedChallenges => _completedChallenges;
  List<ChallengeModel> get teamChallenges => _teamChallenges;

  Future<void> fetchActiveChallenges() async {
    AppLogger.info(_tag, 'fetchActiveChallenges called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/challenges/active',
      );
      final challenges =
          (resp.data!['challenges'] as List?)
              ?.map(
                (json) => ChallengeModel.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      _activeChallenges = challenges;
      AppLogger.success(_tag, 'fetchActiveChallenges succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchActiveChallenges DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchActiveChallenges error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCompletedChallenges() async {
    AppLogger.info(_tag, 'fetchCompletedChallenges called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/challenges/completed',
      );
      final challenges =
          (resp.data!['challenges'] as List?)
              ?.map(
                (json) => ChallengeModel.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      _completedChallenges = challenges;
      AppLogger.success(_tag, 'fetchCompletedChallenges succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchCompletedChallenges DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchCompletedChallenges error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTeamChallenges() async {
    AppLogger.info(_tag, 'fetchTeamChallenges called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>('/api/challenges/team');
      final challenges =
          (resp.data!['challenges'] as List?)
              ?.map(
                (json) => ChallengeModel.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      _teamChallenges = challenges;
      AppLogger.success(_tag, 'fetchTeamChallenges succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchTeamChallenges DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchTeamChallenges error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> joinChallenge(String challengeId) async {
    AppLogger.info(_tag, 'joinChallenge called');
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.post<dynamic>('/api/challenges/$challengeId/join');
      // Refresh challenges after joining
      await fetchActiveChallenges();
      AppLogger.success(_tag, 'joinChallenge succeeded');
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'joinChallenge DioException', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'joinChallenge error', e);
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
