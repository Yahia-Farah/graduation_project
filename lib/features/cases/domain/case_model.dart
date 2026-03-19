class CaseModel {
  final String id;
  final String caseNumber;
  final String title;
  final String status;
  final DateTime createdAt;

  final String? judgeName;
  final String? lawyerName;

  const CaseModel({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.status,
    required this.createdAt,
    this.judgeName,
    this.lawyerName,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: (json['id'] ?? '').toString(),
      caseNumber: (json['caseNumber'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      judgeName: json['judgeName']?.toString(),
      lawyerName: json['lawyerName']?.toString(),
    );
  }
}