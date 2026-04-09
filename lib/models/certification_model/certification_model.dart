class CertificateRequestModel {
  final String id;
  final String certificateId;
  final String title;
  final String? description;
  final String issuer;
  final String status;
  final String? adminComment;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final DateTime issueDate;
  final DateTime? completionDate;
  final String certificateUrl;

  CertificateRequestModel({
    required this.id,
    required this.certificateId,
    required this.title,
    this.description,
    required this.issuer,
    required this.status,
    this.adminComment,
    required this.createdAt,
    this.reviewedAt,
    required this.issueDate,
    this.completionDate,
    required this.certificateUrl,
  });

  factory CertificateRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) {
        return DateTime.now();
      }
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null || value.toString().isEmpty) {
        return null;
      }
      return DateTime.tryParse(value.toString());
    }

    return CertificateRequestModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      certificateId: (json['certificate_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      issuer: (json['issuer'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      adminComment: json['admin_comment']?.toString(),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      reviewedAt: parseNullableDate(json['reviewed_at']),
      issueDate: parseDate(json['issue_date']),
      completionDate: parseNullableDate(json['completion_date']),
      certificateUrl: (json['certificate_url'] ?? '').toString(),
    );
  }
}