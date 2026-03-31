import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/challenge_model.dart';
import '../services/api_service.dart';

class ChallengesProvider extends ChangeNotifier {
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
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCompletedChallenges() async {
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
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTeamChallenges() async {
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
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> joinChallenge(String challengeId) async {
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.post<dynamic>('/api/challenges/$challengeId/join');
      // Refresh challenges after joining
      await fetchActiveChallenges();
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
