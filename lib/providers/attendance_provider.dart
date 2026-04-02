import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class AttendanceProvider extends ChangeNotifier {
  static const _tag = 'AttendanceProvider';

  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  String? _errorMessage;
  String? _successMessage;

  AttendanceTodayStatus? _todayStatus;
  AttendanceHistory? _attendanceHistory;

  bool get isLoading => _isLoading;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  AttendanceTodayStatus? get todayStatus => _todayStatus;
  AttendanceHistory? get attendanceHistory => _attendanceHistory;

  bool get isCheckedInToday => _todayStatus?.isCheckedIn ?? false;
  int get currentStreak => _todayStatus?.streak.current ?? 0;
  int get longestStreak => _todayStatus?.streak.longest ?? 0;
  String? get streakWarning => _todayStatus?.streak.warning;

  Future<void> fetchTodayStatus() async {
    AppLogger.info(_tag, 'fetchTodayStatus called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/attendance/today',
      );
      _todayStatus = AttendanceTodayStatus.fromJson(resp.data!);
      AppLogger.success(_tag, 'fetchTodayStatus succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _todayStatus = null;
      AppLogger.error(_tag, 'fetchTodayStatus DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      _todayStatus = null;
      AppLogger.error(_tag, 'fetchTodayStatus error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAttendanceHistory({String? month}) async {
    AppLogger.info(_tag, 'fetchAttendanceHistory called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = month != null ? {'month': month} : null;
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/attendance/my',
        queryParameters: queryParams,
      );
      _attendanceHistory = AttendanceHistory.fromJson(resp.data!);
      AppLogger.success(_tag, 'fetchAttendanceHistory succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _attendanceHistory = null;
      AppLogger.error(_tag, 'fetchAttendanceHistory DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      _attendanceHistory = null;
      AppLogger.error(_tag, 'fetchAttendanceHistory error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkIn() async {
    AppLogger.info(_tag, 'checkIn called');
    _isCheckingIn = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        '/api/attendance/check-in',
      );
      _successMessage =
          resp.data!['message'] as String? ?? 'Checked in successfully!';

      // Refresh today's status
      await fetchTodayStatus();

      AppLogger.success(_tag, 'checkIn succeeded');
      _isCheckingIn = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'checkIn DioException', e);
      _isCheckingIn = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'checkIn error', e);
      _isCheckingIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut() async {
    AppLogger.info(_tag, 'checkOut called');
    _isCheckingOut = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        '/api/attendance/check-out',
      );
      _successMessage =
          resp.data!['message'] as String? ?? 'Checked out successfully!';

      // Refresh today's status
      await fetchTodayStatus();

      AppLogger.success(_tag, 'checkOut succeeded');
      _isCheckingOut = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'checkOut DioException', e);
      _isCheckingOut = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'checkOut error', e);
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    AppLogger.info(_tag, 'clearMessages called');
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
