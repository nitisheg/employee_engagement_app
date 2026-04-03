import '../models/challenge_model.dart';
import '../core/utils/app_logger.dart';
import '../services/api/challenges_api_service.dart';
import 'base_view_model.dart';

class ChallengesViewModel extends BaseViewModel {
  static const _tag = 'ChallengesViewModel';

  List<ChallengeModel> _activeChallenges = [];
  List<Map<String, dynamic>> _userChallenges = [];
  List<Map<String, dynamic>> _challengeLeaderboard = [];
  Map<String, dynamic>? _userChallengeStats;

  List<ChallengeModel> get activeChallenges => _activeChallenges;
  List<Map<String, dynamic>> get userChallenges => _userChallenges;
  List<Map<String, dynamic>> get challengeLeaderboard => _challengeLeaderboard;
  Map<String, dynamic>? get userChallengeStats => _userChallengeStats;

  Future<void> loadActiveChallenges({String? category}) async {
    AppLogger.info(_tag, 'loadActiveChallenges called');
    try {
      setLoading();
      final data = await ChallengesApiService().getActiveChallenges(
        category: category,
      );
      _activeChallenges = (data as List)
          .map((json) => ChallengeModel.fromJson(json))
          .toList();
      AppLogger.success(_tag, 'loadActiveChallenges succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadActiveChallenges error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserChallenges() async {
    AppLogger.info(_tag, 'loadUserChallenges called');
    try {
      setLoading();
      final data = await ChallengesApiService().getUserChallenges();
      _userChallenges = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadUserChallenges succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserChallenges error', e);
      setError(e.toString());
    }
  }

  Future<void> loadChallengeLeaderboard(String challengeId) async {
    AppLogger.info(_tag, 'loadChallengeLeaderboard called');
    try {
      setLoading();
      final data = await ChallengesApiService().getChallengeLeaderboard(
        challengeId,
      );
      _challengeLeaderboard = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadChallengeLeaderboard succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadChallengeLeaderboard error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserChallengeStats() async {
    AppLogger.info(_tag, 'loadUserChallengeStats called');
    try {
      setLoading();
      _userChallengeStats = await ChallengesApiService()
          .getUserChallengeStats();
      AppLogger.success(_tag, 'loadUserChallengeStats succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserChallengeStats error', e);
      setError(e.toString());
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    AppLogger.info(_tag, 'joinChallenge called');
    try {
      setLoading();
      await ChallengesApiService().joinChallenge(challengeId);
      // Refresh user challenges after joining
      await loadUserChallenges();
      AppLogger.success(_tag, 'joinChallenge succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'joinChallenge error', e);
      setError(e.toString());
    }
  }

  Future<void> submitChallengeProgress(
    String challengeId,
    Map<String, dynamic> progress,
  ) async {
    AppLogger.info(_tag, 'submitChallengeProgress called');
    try {
      setLoading();
      await ChallengesApiService().submitChallengeProgress(
        challengeId,
        progress,
      );
      // Refresh user challenges and stats after progress submission
      await loadUserChallenges();
      await loadUserChallengeStats();
      AppLogger.success(_tag, 'submitChallengeProgress succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'submitChallengeProgress error', e);
      setError(e.toString());
    }
  }

  Future<void> refreshChallengesData() async {
    AppLogger.info(_tag, 'refreshChallengesData called');
    await Future.wait([
      loadActiveChallenges(),
      loadUserChallenges(),
      loadUserChallengeStats(),
    ]);
  }
}
