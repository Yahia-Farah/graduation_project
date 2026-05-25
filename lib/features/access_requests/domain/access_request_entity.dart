class AccessRequestEntity {
  final String requestId;
  final String lawyerId;
  final String lawyerName;
  final String caseId;
  final String caseNumber;
  final String status;
  final DateTime? requestedAt;

  AccessRequestEntity({
    required this.requestId,
    required this.lawyerId,
    required this.lawyerName,
    required this.caseId,
    required this.caseNumber,
    required this.status,
    this.requestedAt,
  });

  factory AccessRequestEntity.fromJson(Map<String, dynamic> json) {
    return AccessRequestEntity(
      requestId: json['requestId']?.toString() ?? '',
      lawyerId: json['lawyerId']?.toString() ?? '',
      lawyerName: json['lawyerName']?.toString() ?? '',
      caseId: json['caseId']?.toString() ?? '',
      caseNumber: json['caseNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
    );
  }
}
