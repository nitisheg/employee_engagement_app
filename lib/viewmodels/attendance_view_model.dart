import '../models/attendance_model.dart';
import '../core/utils/app_logger.dart';
import '../services/api/attendance_api_service.dart';
import 'base_view_model.dart';

class AttendanceViewModel extends BaseViewModel {
  static const _tag = 'AttendanceViewModel';

  List<AttendanceRecord> _attendanceHistory = [];
  Map<String, dynamic>? _todayAttendance;
  Map<String, dynamic>? _attendanceStats;
  bool _isCheckedIn = false;

  List<AttendanceRecord> get attendanceHistory => _attendanceHistory;
  Map<String, dynamic>? get todayAttendance => _todayAttendance;
  Map<String, dynamic>? get attendanceStats => _attendanceStats;
  bool get isCheckedIn => _isCheckedIn;

  Future<void> loadAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    AppLogger.info(_tag, 'loadAttendanceHistory called');
    try {
      setLoading();
      final data = await AttendanceApiService().getAttendanceHistory(
        startDate: startDate,
        endDate: endDate,
      );
      _attendanceHistory = (data as List)
          .map((json) => AttendanceRecord.fromJson(json))
          .toList();
      AppLogger.success(_tag, 'loadAttendanceHistory succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadAttendanceHistory error', e);
      setError(e.toString());
    }
  }

  Future<void> loadTodayAttendance() async {
    AppLogger.info(_tag, 'loadTodayAttendance called');
    try {
      setLoading();
      final data = await AttendanceApiService().getTodayAttendance();
      _todayAttendance = data;
      _isCheckedIn = data != null && data['checkInTime'] != null;
      AppLogger.success(_tag, 'loadTodayAttendance succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadTodayAttendance error', e);
      setError(e.toString());
    }
  }

  Future<void> loadAttendanceStats() async {
    AppLogger.info(_tag, 'loadAttendanceStats called');
    try {
      setLoading();
      _attendanceStats = await AttendanceApiService().getAttendanceStats();
      AppLogger.success(_tag, 'loadAttendanceStats succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadAttendanceStats error', e);
      setError(e.toString());
    }
  }

  Future<void> checkIn({
    String? location,
    Map<String, dynamic>? metadata,
  }) async {
    AppLogger.info(_tag, 'checkIn called');
    try {
      setLoading();
      final data = await AttendanceApiService().checkIn(
        location: location,
        metadata: metadata,
      );
      _todayAttendance = data;
      _isCheckedIn = true;
      AppLogger.success(_tag, 'checkIn succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'checkIn error', e);
      setError(e.toString());
    }
  }

  Future<void> checkOut({
    String? location,
    Map<String, dynamic>? metadata,
  }) async {
    AppLogger.info(_tag, 'checkOut called');
    try {
      setLoading();
      final data = await AttendanceApiService().checkOut(
        location: location,
        metadata: metadata,
      );
      _todayAttendance = data;
      _isCheckedIn = false;
      AppLogger.success(_tag, 'checkOut succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'checkOut error', e);
      setError(e.toString());
    }
  }

  Future<void> requestLeave(
    DateTime startDate,
    DateTime endDate,
    String reason, {
    String? leaveType,
  }) async {
    AppLogger.info(_tag, 'requestLeave called');
    try {
      setLoading();
      await AttendanceApiService().requestLeave(
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        leaveType: leaveType,
      );
      AppLogger.success(_tag, 'requestLeave succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'requestLeave error', e);
      setError(e.toString());
    }
  }

  Future<void> refreshAttendanceData() async {
    AppLogger.info(_tag, 'refreshAttendanceData called');
    await Future.wait([loadTodayAttendance(), loadAttendanceStats()]);
  }
}
