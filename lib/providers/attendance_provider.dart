import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  bool _isCheckingIn = false;
  String? _errorMessage;
  String? _successMessage;
  List<AttendanceRecord> _attendanceHistory = [];
  AttendanceSummary _stats = const AttendanceSummary(
    presentDays: 0,
    absentDays: 0,
    lateDays: 0,
    currentStreak: 0,
    bestStreak: 0,
    totalPointsEarned: 0,
    recentRecords: [],
  );
  bool _isCheckedInToday = false;
  String? _lastCheckInTime;

  bool get isLoading => _isLoading;
  bool get isCheckingIn => _isCheckingIn;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<AttendanceRecord> get attendanceHistory => _attendanceHistory;
  AttendanceSummary get stats => _stats;
  bool get isCheckedInToday => _isCheckedInToday;
  String? get lastCheckInTime => _lastCheckInTime;

  Future<void> fetchAttendanceHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/attendance/history',
      );
      final history =
          (resp.data!['history'] as List?)
              ?.map(
                (json) =>
                    AttendanceRecord.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      _attendanceHistory = history;

      // Update today's check-in status
      final today = DateTime.now();
      final todayRecord = history.firstWhere(
        (record) =>
            record.date.year == today.year &&
            record.date.month == today.month &&
            record.date.day == today.day,
        orElse: () => AttendanceRecord(
          id: 0,
          date: today,
          checkInTime: null,
          status: AttendanceCheckStatus.absent,
          pointsEarned: 0,
        ),
      );
      _isCheckedInToday = todayRecord.checkInTime != null;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAttendanceStats() async {
    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/attendance/stats',
      );
      _stats = AttendanceSummary.fromJson(
        resp.data!['stats'] as Map<String, dynamic>,
      );
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> checkIn() async {
    _isCheckingIn = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.post<Map<String, dynamic>>(
        '/api/attendance/checkin',
      );
      _successMessage =
          resp.data!['message'] as String? ?? 'Checked in successfully!';
      _isCheckedInToday = true;
      _lastCheckInTime = DateTime.now().toString();

      // Refresh data
      await fetchAttendanceHistory();
      await fetchAttendanceStats();

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

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
