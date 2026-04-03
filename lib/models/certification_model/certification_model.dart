enum CertVisibility { organization, team, managementOnly }

enum CertStatus { pending, verified, rejected, expired }

class CertificationModel {
  final int id;
  final String name;
  final String issuingOrganization;
  final String issueDate;
  final String? expiryDate;
  final String credentialId;
  final CertStatus status;
  final CertVisibility visibility;
  final int pointsAwarded;

  const CertificationModel({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expiryDate,
    required this.credentialId,
    required this.status,
    required this.visibility,
    required this.pointsAwarded,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      issuingOrganization: json['issuing_organization'] as String,
      issueDate: json['issue_date'] as String,
      expiryDate: json['expiry_date'] as String?,
      credentialId: json['credential_id'] as String,
      status: _parseStatus(json['status'] as String),
      visibility: _parseVisibility(json['visibility'] as String),
      pointsAwarded: json['points_awarded'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'issuing_organization': issuingOrganization,
        'issue_date': issueDate,
        'expiry_date': expiryDate,
        'credential_id': credentialId,
        'status': status.name,
        'visibility': visibility.name,
        'points_awarded': pointsAwarded,
      };

  static CertStatus _parseStatus(String s) {
    switch (s) {
      case 'verified':
        return CertStatus.verified;
      case 'rejected':
        return CertStatus.rejected;
      case 'expired':
        return CertStatus.expired;
      default:
        return CertStatus.pending;
    }
  }

  static CertVisibility _parseVisibility(String s) {
    switch (s) {
      case 'team':
        return CertVisibility.team;
      case 'management_only':
        return CertVisibility.managementOnly;
      default:
        return CertVisibility.organization;
    }
  }
}

class AddCertificationRequest {
  final String name;
  final String issuingOrganization;
  final String issueDate;
  final String? expiryDate;
  final String credentialId;
  final CertVisibility visibility;

  const AddCertificationRequest({
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expiryDate,
    required this.credentialId,
    required this.visibility,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'issuing_organization': issuingOrganization,
        'issue_date': issueDate,
        'expiry_date': expiryDate,
        'credential_id': credentialId,
        'visibility': visibility.name,
      };
}

