import 'package:dio/dio.dart';
import '../core/api_client.dart';

class QuizApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getActiveQuizzes({
    String filter = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/quizzes/active',
      queryParameters: {'filter': filter, 'page': page, 'limit': limit},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getQuizAttempt(
    String quizId, {
    int page = 1,
    int limit = 10,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/quizzes/$quizId/take',
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data == null) {
      throw Exception('Quiz attempt response body is null');
    }

    final Map<String, dynamic> raw = response.data!;

    if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      final Map<String, dynamic> dataPayload =
          Map<String, dynamic>.from(raw['data'] as Map<String, dynamic>);

      final Map<String, dynamic>? rootPagination =
          raw['pagination'] as Map<String, dynamic>?;
      if (rootPagination != null && !dataPayload.containsKey('pagination')) {
        dataPayload['pagination'] = rootPagination;
      }

      return dataPayload;
    }

    if (raw.containsKey('quiz') && raw['quiz'] is Map<String, dynamic>) {
      final Map<String, dynamic> quizPayload =
          raw['quiz'] as Map<String, dynamic>;
      final Map<String, dynamic> pagination =
          raw['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};

      return <String, dynamic>{
        'quizId': quizPayload['_id'] ?? quizPayload['id'] ?? quizId,
        'title': quizPayload['title'] ?? '',
        'questions': quizPayload['questions'] ?? <dynamic>[],
        'page': pagination['page'] ?? page,
        'totalPages': pagination['totalPages'] ?? 1,
      };
    }

    return raw;
  }

  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<Map<String, dynamic>> answers,
  ) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/api/quizzes/$quizId/submit',
      data: {'answers': answers},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getMyResults({
    int page = 1,
    int limit = 20,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/quizzes/my-results',
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data!;
  }
}
