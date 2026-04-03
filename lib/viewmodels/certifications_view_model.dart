import '../models/certification_model.dart';
import '../core/utils/app_logger.dart';
import '../services/api/certifications_api_service.dart';
import 'base/base_view_model.dart';

class CertificationsViewModel extends BaseViewModel {
  static const _tag = 'CertificationsViewModel';

  List<CertificationModel> _availableCertifications = [];
  List<Map<String, dynamic>> _userCertifications = [];
  List<Map<String, dynamic>> _certificationProgress = [];

  List<CertificationModel> get availableCertifications =>
      _availableCertifications;
  List<Map<String, dynamic>> get userCertifications => _userCertifications;
  List<Map<String, dynamic>> get certificationProgress =>
      _certificationProgress;

  Future<void> loadAvailableCertifications({String? category}) async {
    AppLogger.info(_tag, 'loadAvailableCertifications called');
    try {
      setLoading();
      final data = await CertificationsApiService().getAvailableCertifications(
        category: category,
      );
      _availableCertifications = (data)
          .map((json) => CertificationModel.fromJson(json))
          .toList();
      AppLogger.success(_tag, 'loadAvailableCertifications succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadAvailableCertifications error', e);
      setError(e.toString());
    }
  }

  Future<void> loadUserCertifications() async {
    AppLogger.info(_tag, 'loadUserCertifications called');
    try {
      setLoading();
      final data = await CertificationsApiService().getUserCertifications();
      _userCertifications = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadUserCertifications succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadUserCertifications error', e);
      setError(e.toString());
    }
  }

  Future<void> loadCertificationProgress() async {
    AppLogger.info(_tag, 'loadCertificationProgress called');
    try {
      setLoading();
      final data = await CertificationsApiService().getCertificationProgress();
      _certificationProgress = List<Map<String, dynamic>>.from(data);
      AppLogger.success(_tag, 'loadCertificationProgress succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadCertificationProgress error', e);
      setError(e.toString());
    }
  }

  Future<void> enrollInCertification(String certificationId) async {
    AppLogger.info(_tag, 'enrollInCertification called');
    try {
      setLoading();
      await CertificationsApiService().enrollInCertification(certificationId);
      // Refresh user certifications after enrollment
      await loadUserCertifications();
      await loadCertificationProgress();
      AppLogger.success(_tag, 'enrollInCertification succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'enrollInCertification error', e);
      setError(e.toString());
    }
  }

  Future<void> startCertificationAttempt(String certificationId) async {
    AppLogger.info(_tag, 'startCertificationAttempt called');
    try {
      setLoading();
      await CertificationsApiService().startCertificationAttempt(
        certificationId,
      );
      // Refresh progress after starting attempt
      await loadCertificationProgress();
      AppLogger.success(_tag, 'startCertificationAttempt succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'startCertificationAttempt error', e);
      setError(e.toString());
    }
  }

  Future<void> submitCertificationAttempt(
    String attemptId,
    Map<String, dynamic> answers,
  ) async {
    AppLogger.info(_tag, 'submitCertificationAttempt called');
    try {
      setLoading();
      await CertificationsApiService().submitCertificationAttempt(
        attemptId,
        answers,
      );
      // Refresh certifications and progress after submission
      await loadUserCertifications();
      await loadCertificationProgress();
      AppLogger.success(_tag, 'submitCertificationAttempt succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'submitCertificationAttempt error', e);
      setError(e.toString());
    }
  }

  Future<void> refreshCertificationsData() async {
    AppLogger.info(_tag, 'refreshCertificationsData called');
    await Future.wait([
      loadAvailableCertifications(),
      loadUserCertifications(),
      loadCertificationProgress(),
    ]);
  }
}
