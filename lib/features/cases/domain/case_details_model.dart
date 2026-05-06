class CaseFile {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;

  const CaseFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
  });

  factory CaseFile.fromJson(Map<String, dynamic> json) {
    return CaseFile(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
    );
  }
}

class CaseDetailsModel {
  final String id;
  final String caseNumber;
  final String title;
  final String description;
  final String status;
  final String? judgeName;
  final String? lawyerName;
  final String? courtRuling;

  final List<CaseFile> caseFiles;
  final List<CaseFile> defenseFiles;

  const CaseDetailsModel({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.description,
    required this.status,
    this.judgeName,
    this.lawyerName,
    this.courtRuling,
    required this.caseFiles,
    required this.defenseFiles,
  });

  factory CaseDetailsModel.fromJson(Map<String, dynamic> json) {
    return CaseDetailsModel(
      id: json['id'],
      caseNumber: json['caseNumber'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'],
      judgeName: json['judgeName'],
      lawyerName: json['lawyerName'],
      courtRuling: json['courtRuling'],
      caseFiles: (json['caseFiles'] as List? ?? [])
          .map((e) => CaseFile.fromJson(e))
          .toList(),
      defenseFiles: (json['defenseFiles'] as List? ?? [])
          .map((e) => CaseFile.fromJson(e))
          .toList(),
    );
  }
}
