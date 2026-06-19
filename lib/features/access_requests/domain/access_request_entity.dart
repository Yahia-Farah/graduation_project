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
    // Check for nested lawyer object
    final lawyerMap = json['lawyer'] is Map ? json['lawyer'] : null;
    final lawyerName = json['lawyerName'] ??
        (lawyerMap != null
            ? '${lawyerMap['firstName'] ?? ''} ${lawyerMap['lastName'] ?? ''}'.trim()
            : null);

    // Check for nested case object
    final caseMap = json['case'] is Map ? json['case'] : json['legalCase'] is Map ? json['legalCase'] : null;

    return AccessRequestEntity(
      requestId: (json['requestId'] ?? json['id'])?.toString() ?? '',
      lawyerId: (json['lawyerId'] ?? lawyerMap?['id'])?.toString() ?? '',
      lawyerName: lawyerName?.toString() ?? '',
      caseId: (json['caseId'] ?? caseMap?['id'])?.toString() ?? '',
      caseNumber: (json['caseNumber'] ?? caseMap?['caseNumber'])?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null),
    );
  }
}
