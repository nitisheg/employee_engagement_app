import 'dart:io';
import 'package:flutter/material.dart';

import '../models/certification_model/certification_model.dart';
import '../services/api/certifications_api_service.dart';

class CertificateViewModel extends ChangeNotifier {
  final CertificationsApiService service;

  CertificateViewModel(this.service);

  List<CertificateRequestModel> _certificates = [];
  List<CertificateRequestModel> get certificates => _certificates;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// 🔹 Fetch Certificates
  Future<void> fetchCertificates({String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _certificates = await service.getCertificates(status: status);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Submit Certificate
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
      final success = await service.submitCertificate(
        certificateId: certificateId,
        title: title,
        issuer: issuer,
        issueDate: issueDate,
        completionDate: completionDate,
        description: description,
        file: file,
      );

      if (success) {
        await fetchCertificates(); // refresh list
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}