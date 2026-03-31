import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/certification_model.dart';
import '../services/api_service.dart';

class CertificationsProvider extends ChangeNotifier {
  final Dio _dio = ApiClient.instance.dio;

  bool _isLoading = false;
  String? _errorMessage;
  List<CertificationModel> _certifications = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CertificationModel> get certifications => _certifications;

  Future<void> fetchCertifications() async {
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
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCertification(CertificationModel certification) async {
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.post<dynamic>(
        '/api/certifications',
        data: certification.toJson(),
      );
      // Refresh certifications after adding
      await fetchCertifications();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCertification(
    String certificationId,
    CertificationModel certification,
  ) async {
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.put<dynamic>(
        '/api/certifications/$certificationId',
        data: certification.toJson(),
      );
      // Refresh certifications after updating
      await fetchCertifications();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCertification(String certificationId) async {
    try {
      // TODO: Update endpoint based on API documentation
      await _dio.delete<dynamic>('/api/certifications/$certificationId');
      // Refresh certifications after deleting
      await fetchCertifications();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
