import '../models/project_model.dart';
import '../core/utils/app_logger.dart';
import 'base_view_model.dart';

// Placeholder for ProjectsApiService - to be implemented
class ProjectsApiService {
  Future<List<dynamic>> getProjects({String? status, String? category}) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<Map<String, dynamic>> getProjectById(String projectId) async {
    // TODO: Implement actual API call
    return {};
  }

  Future<List<dynamic>> getUserProjects() async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<dynamic>> getProjectTasks(String projectId) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    // TODO: Implement actual API call
  }

  Future<void> joinProject(String projectId) async {
    // TODO: Implement actual API call
  }
}

class ProjectsViewModel extends BaseViewModel {
  static const _tag = 'ProjectsViewModel';

  List<ProjectModel> _projects = [];
  ProjectModel? _currentProject;
  List<Map<String, dynamic>> _userProjects = [];
  List<Map<String, dynamic>> _projectTasks = [];

  List<ProjectModel> get projects => _projects;
  ProjectModel? get currentProject => _currentProject;
  List<Map<String, dynamic>> get userProjects => _userProjects;
  List<Map<String, dynamic>> get projectTasks => _projectTasks;

  Future<void> loadProjects({String? status, String? category}) async {
    AppLogger.info(_tag, 'loadProjects called');
    try {
      setLoading();
      final data = await ProjectsApiService().getProjects(
        status: status,
        category: category,
      );
      _projects = (data as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
      AppLogger.success(_tag, 'loadProjects succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadProjects error', e);
      setError(e.toString());
    }
  }

  Future<void> loadProjectById(String projectId) async {
    AppLogger.info(_tag, 'loadProjectById called');
    try {
      setLoading();
      final data = await ProjectsApiService().getProjectById(projectId);
      _currentProject = ProjectModel.fromJson(data);
      AppLogger.success(_tag, 'loadProjectById succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadProjectById error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserProjects() async {
    AppLogger.info(_tag, 'loadUserProjects called');
    try {
      setLoading();
      final data = await ProjectsApiService().getUserProjects();
      _userProjects = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadUserProjects succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserProjects error', e);
      setError(e.toString());
    }
  }

  Future<void> loadProjectTasks(String projectId) async {
    AppLogger.info(_tag, 'loadProjectTasks called');
    try {
      setLoading();
      final data = await ProjectsApiService().getProjectTasks(projectId);
      _projectTasks = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadProjectTasks succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadProjectTasks error', e);
      setError(e.toString());
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    AppLogger.info(_tag, 'updateTaskStatus called');
    try {
      setLoading();
      await ProjectsApiService().updateTaskStatus(taskId, status);
      // Refresh project tasks after update
      if (_currentProject != null) {
        await loadProjectTasks(_currentProject!.id.toString());
      } else {
        AppLogger.warning(_tag, 'updateTaskStatus: no current project to refresh tasks for');
      }
      AppLogger.success(_tag, 'updateTaskStatus succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'updateTaskStatus error', e);
      setError(e.toString());
    }
  }

  Future<void> joinProject(String projectId) async {
    AppLogger.info(_tag, 'joinProject called');
    try {
      setLoading();
      await ProjectsApiService().joinProject(projectId);
      // Refresh user projects after joining
      await loadUserProjects();
      AppLogger.success(_tag, 'joinProject succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'joinProject error', e);
      setError(e.toString());
    }
  }

  void resetCurrentProject() {
    AppLogger.info(_tag, 'resetCurrentProject called');
    _currentProject = null;
    _projectTasks.clear();
    setIdle();
  }
}
