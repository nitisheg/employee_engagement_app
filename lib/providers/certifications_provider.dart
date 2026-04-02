import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/certification_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class CertificationsProvider extends ChangeNotifier {
  static const _tag = 'CertificationsProvider';

  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  String? _errorMessage;
  List<CertificationModel> _certifications = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CertificationModel> get certifications => _certifications;

  Future<void> fetchCertifications() async {
    AppLogger.info(_tag, 'fetchCertifications called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Update endpoint based on API documentation
      final resp = await _dio.get<Map<String, dynamic>>('/api/certifications');
      final certifications =
          (resp.data!['certifications'] as List?)
              ?.map(
                (json) =>
                    CertificationModel.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      _certifications = certifications;
      AppLogger.success(_tag, 'fetchCertifications succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchCertifications DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchCertifications error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCertification(CertificationModel certification) async {
    AppLogger.info(_tag, 'addCertification called');
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.post<dynamic>(
        '/api/certifications',
        data: certification.toJson(),
      );
      // Refresh certifications after adding
      await fetchCertifications();
      AppLogger.success(_tag, 'addCertification succeeded');
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'addCertification DioException', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'addCertification error', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCertification(
    String certificationId,
    CertificationModel certification,
  ) async {
    AppLogger.info(_tag, 'updateCertification called');
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.put<dynamic>(
        '/api/certifications/$certificationId',
        data: certification.toJson(),
      );
      // Refresh certifications after updating
      await fetchCertifications();
      AppLogger.success(_tag, 'updateCertification succeeded');
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'updateCertification DioException', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'updateCertification error', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCertification(String certificationId) async {
    AppLogger.info(_tag, 'deleteCertification called');
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.delete<dynamic>('/api/certifications/$certificationId');
      // Refresh certifications after deleting
      await fetchCertifications();
      AppLogger.success(_tag, 'deleteCertification succeeded');
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'deleteCertification DioException', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'deleteCertification error', e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    AppLogger.info(_tag, 'clearError called');
    _errorMessage = null;
    notifyListeners();
  }
}
