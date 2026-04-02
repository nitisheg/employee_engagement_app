import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';
import 'base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  static const _tag = 'HomeViewModel';

  DashboardModel? _dashboard;
  List<dynamic> _activeQuizzes = [];
  List<dynamic> _recentActivities = [];

  DashboardModel? get dashboard => _dashboard;
  List<dynamic> get activeQuizzes => _activeQuizzes;
  List<dynamic> get recentActivities => _recentActivities;

  Future<void> loadDashboard() async {
    AppLogger.info(_tag, 'loadDashboard called');
    try {
      setLoading();
      final data = await ProfileApiService().getDashboard();
      _dashboard = DashboardModel.fromJson(data);
      _activeQuizzes = data['activeQuizzes'] ?? [];
      _recentActivities = data['recentActivities'] ?? [];
      AppLogger.success(_tag, 'loadDashboard succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadDashboard error', e);
      setError(e.toString());
    }
  }

  Future<void> refreshDashboard() async {
    AppLogger.info(_tag, 'refreshDashboard called');
    await loadDashboard();
  }
}
