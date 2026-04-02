import '../models/game_model.dart';
import '../models/game_session_model.dart';
import '../core/utils/app_logger.dart';
import 'base_view_model.dart';

// Placeholder for GamesApiService - to be implemented
class GamesApiService {
  Future<List<dynamic>> getGames({String? category}) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<Map<String, dynamic>> getGameById(String gameId) async {
    // TODO: Implement actual API call
    return {};
  }

  Future<Map<String, dynamic>> startGameSession(String gameId) async {
    // TODO: Implement actual API call
    return {};
  }

  Future<void> submitGameScore(
    String sessionId,
    int score,
    Map<String, dynamic>? metadata,
  ) async {
    // TODO: Implement actual API call
  }

  Future<List<dynamic>> getLeaderboard(
    String gameId, {
    String period = 'all',
  }) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<Map<String, dynamic>> getUserGameStats() async {
    // TODO: Implement actual API call
    return {};
  }
}

class GamesViewModel extends BaseViewModel {
  static const _tag = 'GamesViewModel';

  List<GameModel> _games = [];
  GameModel? _currentGame;
  GameSessionModel? _currentSession;
  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, dynamic>? _userGameStats;

  List<GameModel> get games => _games;
  GameModel? get currentGame => _currentGame;
  GameSessionModel? get currentSession => _currentSession;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  Map<String, dynamic>? get userGameStats => _userGameStats;

  Future<void> loadGames({String? category}) async {
    AppLogger.info(_tag, 'loadGames called');
    try {
      setLoading();
      final data = await GamesApiService().getGames(category: category);
      _games = (data as List).map((json) => GameModel.fromJson(json)).toList();
      AppLogger.success(_tag, 'loadGames succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadGames error', e);
      setError(e.toString());
    }
  }

  Future<void> loadGameById(String gameId) async {
    AppLogger.info(_tag, 'loadGameById called');
    try {
      setLoading();
      final data = await GamesApiService().getGameById(gameId);
      _currentGame = GameModel.fromJson(data);
      AppLogger.success(_tag, 'loadGameById succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadGameById error', e);
      setError(e.toString());
    }
  }

  Future<void> startGameSession(String gameId) async {
    AppLogger.info(_tag, 'startGameSession called');
    try {
      setLoading();
      final data = await GamesApiService().startGameSession(gameId);
      _currentSession = GameSessionModel.fromJson(data);
      AppLogger.success(_tag, 'startGameSession succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'startGameSession error', e);
      setError(e.toString());
    }
  }

  Future<void> submitGameScore(
    String sessionId,
    int score,
    Map<String, dynamic>? metadata,
  ) async {
    AppLogger.info(_tag, 'submitGameScore called');
    try {
      setLoading();
      await GamesApiService().submitGameScore(sessionId, score, metadata);
      AppLogger.success(_tag, 'submitGameScore succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'submitGameScore error', e);
      setError(e.toString());
    }
  }

  Future<void> loadLeaderboard(String gameId, {String period = 'all'}) async {
    AppLogger.info(_tag, 'loadLeaderboard called');
    try {
      setLoading();
      final data = await GamesApiService().getLeaderboard(
        gameId,
        period: period,
      );
      _leaderboard = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadLeaderboard succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadLeaderboard error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserGameStats() async {
    AppLogger.info(_tag, 'loadUserGameStats called');
    try {
      setLoading();
      _userGameStats = await GamesApiService().getUserGameStats();
      AppLogger.success(_tag, 'loadUserGameStats succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserGameStats error', e);
      setError(e.toString());
    }
  }

  void resetGame() {
    AppLogger.info(_tag, 'resetGame called');
    _currentGame = null;
    _currentSession = null;
    setIdle();
  }
}
