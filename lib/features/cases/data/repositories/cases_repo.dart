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
  });
}
