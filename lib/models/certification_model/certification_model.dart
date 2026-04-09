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
    return CertificateRequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      certificateId: json['certificate_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      issuer: json['issuer'] ?? '',
      status: json['status'] ?? '',
      adminComment: json['admin_comment'],
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      reviewedAt: (json['reviewed_at'] != null && json['reviewed_at'] != '')
          ? DateTime.tryParse(json['reviewed_at'])
          : null,
      issueDate: DateTime.parse(
        json['issue_date'] ?? DateTime.now().toIso8601String(),
      ),
      completionDate:
          (json['completion_date'] != null && json['completion_date'] != '')
          ? DateTime.tryParse(json['completion_date'])
          : null,
      certificateUrl: json['certificate_url'] ?? '',
    );
  }
}
