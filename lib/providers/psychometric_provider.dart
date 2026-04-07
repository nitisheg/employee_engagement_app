import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/psychometric_model.dart';
import '../models/psychometric_model/psychometric_result.dart';
import '../models/psychometric_model/psychometric_test.dart';
import '../services/api/psychometric_api_service.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class PsychometricProvider extends ChangeNotifier {
  static const _tag = 'PsychometricProvider';

  final PsychometricApiService _api = PsychometricApiService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<PsychometricTest> _activeTests = [];
  TestAttempt? _currentAttempt;
  Map<String, int> _responses = {}; // statement id -> value
  PsychometricResult? _lastResult;
  List<PsychometricResult> _allResults = [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<PsychometricTest> get activeTests => _activeTests;
  TestAttempt? get currentAttempt => _currentAttempt;
  Map<String, int> get responses => _responses;
  PsychometricResult? get lastResult => _lastResult;
  List<PsychometricResult> get allResults => _allResults;

  int get answeredCount => _responses.length;
  int get totalCount => _currentAttempt?.total ?? 0;
  double get completionPercentage =>
      totalCount > 0 ? (answeredCount / totalCount * 100) : 0;

  Future<void> fetchActiveTests() async {
    AppLogger.info(_tag, 'fetchActiveTests called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.getActiveTests();
      final testsList = (data['tests'] as List<dynamic>? ?? [])
          .map((t) => PsychometricTest.fromJson(t as Map<String, dynamic>))
          .toList();
      _activeTests = testsList;
      AppLogger.success(_tag, 'fetchActiveTests succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchActiveTests DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchActiveTests error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startTest(String testId) async {
    AppLogger.info(_tag, 'startTest called for $testId');
    _isLoading = true;
    _errorMessage = null;
    _responses.clear();
    notifyListeners();

    try {
      final data = await _api.getTestAttempt(testId);
      _currentAttempt = TestAttempt.fromJson(data as Map<String, dynamic>);
      AppLogger.success(_tag, 'startTest succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'startTest DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'startTest error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setResponse(String statementId, int value) {
    AppLogger.debug(_tag, 'setResponse: $statementId = $value');
    _responses[statementId] = value;
    notifyListeners();
  }

  Future<bool> submitTest() async {
    AppLogger.info(
      _tag,
      'submitTest called with ${_responses.length} responses',
    );
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_currentAttempt == null) {
        throw Exception('No active test attempt');
      }

      // Backend validates responses by statement id, not statement text.
      final responsesList = _responses.entries
          .map((e) => {'statement_id': e.key, 'value': e.value})
          .toList();

      final data = await _api.submitTest(
        testId: _currentAttempt!.test.id,
        responses: responsesList,
      );

      final rawResultJson =
          data['result'] as Map<String, dynamic>? ??
          data['data'] as Map<String, dynamic>? ??
          data;
      final resultJson = <String, dynamic>{
        ...rawResultJson,
        '_id':
            rawResultJson['_id'] ??
            rawResultJson['id'] ??
            'submit-${DateTime.now().millisecondsSinceEpoch}',
        'test': rawResultJson['test'] ?? _currentAttempt!.test.toJson(),
        'submitted_at':
            rawResultJson['submitted_at'] ?? DateTime.now().toIso8601String(),
      };
      _lastResult = PsychometricResult.fromJson(resultJson);
      _successMessage = 'Test submitted successfully!';
      _currentAttempt = null;
      _responses.clear();
      AppLogger.success(_tag, 'submitTest succeeded');
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'submitTest DioException', e);
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'submitTest error', e);
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyResults() async {
    AppLogger.info(_tag, 'fetchMyResults called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.getMyResults();
      final resultsList = (data['results'] as List<dynamic>? ?? [])
          .map((r) => PsychometricResult.fromJson(r as Map<String, dynamic>))
          .toList();
      _allResults = resultsList;
      AppLogger.success(_tag, 'fetchMyResults succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchMyResults DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchMyResults error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    AppLogger.info(_tag, 'reset called');
    _currentAttempt = null;
    _responses.clear();
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
