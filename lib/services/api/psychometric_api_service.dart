import 'package:dio/dio.dart';
import '../../core/utils/app_logger.dart';
import '../core/api_client.dart';

class PsychometricApiService {
  static const _tag = 'PsychometricApiService';
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getActiveTests() async {
    AppLogger.info(_tag, 'Fetching active psychometric tests');
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>('/api/psychometric/tests/active');
      AppLogger.success(_tag, 'Active tests fetched');
      return response.data!;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch active tests', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTestAttempt(String testId) async {
    AppLogger.info(_tag, 'Fetching test attempt for $testId');
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>('/api/psychometric/tests/$testId/attempt');
      AppLogger.success(_tag, 'Test attempt fetched');
      return response.data!;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch test attempt', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitTest({
    required String testId,
    required List<Map<String, dynamic>> responses,
  }) async {
    AppLogger.info(
      _tag,
      'Submitting test $testId with ${responses.length} responses',
    );
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(
            '/api/psychometric/tests/$testId/submit',
            data: {'responses': responses},
          );
      AppLogger.success(_tag, 'Test submitted successfully');
      return response.data!;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to submit test', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyResults() async {
    AppLogger.info(_tag, 'Fetching user psychometric results');
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>('/api/psychometric/my-results');
      AppLogger.success(_tag, 'Results fetched');
      return response.data!;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch results', e);
      rethrow;
    }
  }
}
