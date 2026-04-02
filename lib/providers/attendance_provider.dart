import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/attendance/today',
      );
      _todayStatus = AttendanceTodayStatus.fromJson(resp.data!);
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _todayStatus = null;
    } catch (e) {
      _errorMessage = e.toString();
      _todayStatus = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAttendanceHistory({String? month}) async {
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
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _attendanceHistory = null;
    } catch (e) {
      _errorMessage = e.toString();
      _attendanceHistory = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkIn() async {
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

      _isCheckingIn = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _isCheckingIn = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isCheckingIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut() async {
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

      _isCheckingOut = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _isCheckingOut = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
