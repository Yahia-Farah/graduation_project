import 'package:dio/dio.dart';
import '../../domain/case_model.dart';
import '../../domain/page_info.dart';

class CasesResult {
  final List<CaseModel> items;
  final PageInfo pageInfo;

  const CasesResult({required this.items, required this.pageInfo});
}

abstract class CasesRepo {
  Future<CasesResult> getCases({
    required int page,
    required int pageSize,
    String? query,
    String? status,
    String? date,
  });

  Future<void> createCase(Map<String, dynamic> data);
  Future<void> assignUser(String caseId, String userId);
  Future<dynamic> getCaseById(String caseId);
  Future<List<int>> getFileBytes(String caseId, String fileName);
  Future<void> uploadCaseFiles(
    String caseId,
    List<MultipartFile> files,
    void Function(int, int) onProgress,
  );
}
