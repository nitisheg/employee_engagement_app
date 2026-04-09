import 'dart:io';
import 'package:dio/dio.dart';

import '../../core/utils/app_logger.dart';
import '../../models/certification_model/certification_model.dart';

class CertificationsApiService {
  final Dio dio;

  CertificationsApiService(this.dio);

  Future<bool> submitCertificate({
    required String certificateId,
    required String title,
    required String issuer,
    required String issueDate,
    String? completionDate,
    String? description,
    required File file,
  }) async {
    try {
      AppLogger.info('CertificationsApiService', 'submitCertificate called');

      final formData = FormData.fromMap({
        "certificate_id": certificateId.toUpperCase(),
        "title": title,
        "issuer": issuer,
        "issue_date": issueDate,
        if (completionDate != null) "completion_date": completionDate,
        if (description != null) "description": description,
        "certificate": await MultipartFile.fromFile(file.path),
      });

      AppLogger.debug(
        'CertificationsApiService',
        'POST → /certificates/requests',
      );

      final response = await dio.post(
        "/api/user/certificates/requests",
        data: formData,
      );

      AppLogger.debug(
        'CertificationsApiService',
        'Status: ${response.statusCode}',
      );
      AppLogger.debug('CertificationsApiService', 'Response: ${response.data}');

      if (response.statusCode == 201 && response.data['success'] == true) {
        AppLogger.success(
          'CertificationsApiService',
          'submitCertificate success',
        );
        return true;
      }

      return false;
    } on DioException catch (e) {
      AppLogger.error('CertificationsApiService', 'Dio error', e);

      if (e.response != null) {
        AppLogger.error(
          'CertificationsApiService',
          'Error data: ${e.response?.data}',
        );
      }

      throw Exception(e.message);
    }
  }

  Future<List<CertificateRequestModel>> getCertificates({
    String? status,
  }) async {
    try {
      AppLogger.info('CertificationsApiService', 'getCertificates called');

      final response = await dio.get(
        "/api/user/certificates/requests",
        queryParameters: {if (status != null) "status": status},
      );
      // Safely access nested keys to avoid null crash
      List list = [];
      final data = response.data;

      final List requests =
          (data['data']?['requests'] ?? data['requests']) as List? ?? [];

      return requests
          .map(
            (e) => CertificateRequestModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      AppLogger.error('CertificationsApiService', 'Dio error', e);

      if (e.response != null) {
        AppLogger.error(
          'CertificationsApiService',
          'Error data: ${e.response?.data}',
        );
      }

      throw Exception("Fetch failed: ${e.message}");
    }
  }
}
