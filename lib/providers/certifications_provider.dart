import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/certification_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class CertificationsProvider extends ChangeNotifier {
  static const _tag = 'CertificationsProvider';

  late final CertificationsApiService _apiService = CertificationsApiService(
    ApiClient.instance.dio,
  );

  bool _isLoading = false;
  bool _isUploading = false;

  String? _errorMessage;

  List<CertificateRequestModel> _certifications = [];

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  List<CertificateRequestModel> get certifications => _certifications;

  Future<void> fetchCertifications({String? status}) async {
    AppLogger.info(_tag, 'fetchCertifications called');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getCertificates(status: status);
      _certifications = data;
      AppLogger.success(_tag, 'Certificates loaded: ${data.length}');
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetch error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadCertificate({
    required String certificateId,
    required String title,
    required String issuer,
    required String issueDate,
    String? completionDate,
    String? description,
    required File file,
  }) async {
    AppLogger.info(_tag, 'uploadCertificate called');

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fileSizeMB = await file.length() / (1024 * 1024);

      if (fileSizeMB > 5) {
        _errorMessage = "File must be less than 5MB";
        AppLogger.warning(_tag, 'File too large');
        return false;
      }

      final success = await _apiService.submitCertificate(
        certificateId: certificateId,
        title: title,
        issuer: issuer,
        issueDate: issueDate,
        completionDate: completionDate,
        description: description,
        file: file,
      );

      if (success) {
        await fetchCertifications();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'upload error', e);
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void addLocalCertification(CertificateRequestModel cert) {
    _certifications.insert(0, cert);
    notifyListeners();
  }

  List<CertificateRequestModel> get pending =>
      _certifications.where((c) => c.status == 'pending').toList();

  List<CertificateRequestModel> get approved =>
      _certifications.where((c) => c.status == 'approved').toList();

  List<CertificateRequestModel> get rejected =>
      _certifications.where((c) => c.status == 'rejected').toList();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
