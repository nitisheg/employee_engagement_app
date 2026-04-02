import '../models/project_model.dart';
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
  List<ProjectModel> _projects = [];
  ProjectModel? _currentProject;
  List<Map<String, dynamic>> _userProjects = [];
  List<Map<String, dynamic>> _projectTasks = [];

  List<ProjectModel> get projects => _projects;
  ProjectModel? get currentProject => _currentProject;
  List<Map<String, dynamic>> get userProjects => _userProjects;
  List<Map<String, dynamic>> get projectTasks => _projectTasks;

  Future<void> loadProjects({String? status, String? category}) async {
    try {
      setLoading();
      final data = await ProjectsApiService().getProjects(
        status: status,
        category: category,
      );
      _projects = (data as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadProjectById(String projectId) async {
    try {
      setLoading();
      final data = await ProjectsApiService().getProjectById(projectId);
      _currentProject = ProjectModel.fromJson(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadUserProjects() async {
    try {
      setLoading();
      final data = await ProjectsApiService().getUserProjects();
      _userProjects = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadProjectTasks(String projectId) async {
    try {
      setLoading();
      final data = await ProjectsApiService().getProjectTasks(projectId);
      _projectTasks = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      setLoading();
      await ProjectsApiService().updateTaskStatus(taskId, status);
      // Refresh project tasks after update
      if (_currentProject != null) {
        await loadProjectTasks(_currentProject!.id.toString());
      }
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> joinProject(String projectId) async {
    try {
      setLoading();
      await ProjectsApiService().joinProject(projectId);
      // Refresh user projects after joining
      await loadUserProjects();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  void resetCurrentProject() {
    _currentProject = null;
    _projectTasks.clear();
    setIdle();
  }
}
