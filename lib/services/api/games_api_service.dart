class GamesApiService {
  Future<List<dynamic>> getGames({String? category}) async {
    // TODO: Implement actual API call
    return <dynamic>[];
  }

  Future<Map<String, dynamic>> getGameById(String gameId) async {
    // TODO: Implement actual API call
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> startGameSession(String gameId) async {
    // TODO: Implement actual API call
    return <String, dynamic>{};
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
    return <dynamic>[];
  }

  Future<Map<String, dynamic>> getUserGameStats() async {
    // TODO: Implement actual API call
    return <String, dynamic>{};
  }
}
