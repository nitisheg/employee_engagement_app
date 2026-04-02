import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import 'base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  DashboardModel? _dashboard;
  List<dynamic> _activeQuizzes = [];
  List<dynamic> _recentActivities = [];

  DashboardModel? get dashboard => _dashboard;
  List<dynamic> get activeQuizzes => _activeQuizzes;
  List<dynamic> get recentActivities => _recentActivities;

  Future<void> loadDashboard() async {
    try {
      setLoading();
      final data = await ProfileApiService().getDashboard();
      _dashboard = DashboardModel.fromJson(data);
      _activeQuizzes = data['activeQuizzes'] ?? [];
      _recentActivities = data['recentActivities'] ?? [];
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}
