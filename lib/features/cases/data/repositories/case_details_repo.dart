import '../../domain/case_details_model.dart';

abstract class CaseDetailsRepo {
  Future<CaseDetailsModel> getDetails(String caseId);
}