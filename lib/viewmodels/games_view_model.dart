import '../models/game_model.dart';
import '../models/game_session_model.dart';
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
    try {
      setLoading();
      final data = await GamesApiService().getGames(category: category);
      _games = (data as List).map((json) => GameModel.fromJson(json)).toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadGameById(String gameId) async {
    try {
      setLoading();
      final data = await GamesApiService().getGameById(gameId);
      _currentGame = GameModel.fromJson(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> startGameSession(String gameId) async {
    try {
      setLoading();
      final data = await GamesApiService().startGameSession(gameId);
      _currentSession = GameSessionModel.fromJson(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> submitGameScore(
    String sessionId,
    int score,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      setLoading();
      await GamesApiService().submitGameScore(sessionId, score, metadata);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadLeaderboard(String gameId, {String period = 'all'}) async {
    try {
      setLoading();
      final data = await GamesApiService().getLeaderboard(
        gameId,
        period: period,
      );
      _leaderboard = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadUserGameStats() async {
    try {
      setLoading();
      _userGameStats = await GamesApiService().getUserGameStats();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  void resetGame() {
    _currentGame = null;
    _currentSession = null;
    setIdle();
  }
}
