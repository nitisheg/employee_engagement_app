import '../models/challenge_model.dart';
import 'base_view_model.dart';

// Placeholder for ChallengesApiService - to be implemented
class ChallengesApiService {
  Future<List<dynamic>> getActiveChallenges({String? category}) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<dynamic>> getUserChallenges() async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<dynamic>> getChallengeLeaderboard(String challengeId) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<Map<String, dynamic>> getUserChallengeStats() async {
    // TODO: Implement actual API call
    return {};
  }

  Future<void> joinChallenge(String challengeId) async {
    // TODO: Implement actual API call
  }

  Future<void> submitChallengeProgress(
    String challengeId,
    Map<String, dynamic> progress,
  ) async {
    // TODO: Implement actual API call
  }
}

class ChallengesViewModel extends BaseViewModel {
  List<ChallengeModel> _activeChallenges = [];
  List<Map<String, dynamic>> _userChallenges = [];
  List<Map<String, dynamic>> _challengeLeaderboard = [];
  Map<String, dynamic>? _userChallengeStats;

  List<ChallengeModel> get activeChallenges => _activeChallenges;
  List<Map<String, dynamic>> get userChallenges => _userChallenges;
  List<Map<String, dynamic>> get challengeLeaderboard => _challengeLeaderboard;
  Map<String, dynamic>? get userChallengeStats => _userChallengeStats;

  Future<void> loadActiveChallenges({String? category}) async {
    try {
      setLoading();
      final data = await ChallengesApiService().getActiveChallenges(
        category: category,
      );
      _activeChallenges = (data as List)
          .map((json) => ChallengeModel.fromJson(json))
          .toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadUserChallenges() async {
    try {
      setLoading();
      final data = await ChallengesApiService().getUserChallenges();
      _userChallenges = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadChallengeLeaderboard(String challengeId) async {
    try {
      setLoading();
      final data = await ChallengesApiService().getChallengeLeaderboard(
        challengeId,
      );
      _challengeLeaderboard = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadUserChallengeStats() async {
    try {
      setLoading();
      _userChallengeStats = await ChallengesApiService()
          .getUserChallengeStats();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      setLoading();
      await ChallengesApiService().joinChallenge(challengeId);
      // Refresh user challenges after joining
      await loadUserChallenges();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> submitChallengeProgress(
    String challengeId,
    Map<String, dynamic> progress,
  ) async {
    try {
      setLoading();
      await ChallengesApiService().submitChallengeProgress(
        challengeId,
        progress,
      );
      // Refresh user challenges and stats after progress submission
      await loadUserChallenges();
      await loadUserChallengeStats();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> refreshChallengesData() async {
    await Future.wait([
      loadActiveChallenges(),
      loadUserChallenges(),
      loadUserChallengeStats(),
    ]);
  }
}
