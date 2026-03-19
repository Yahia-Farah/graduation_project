abstract class CaseStatusRepo {
  Future<void> updateStatus({
    required String caseId,
    required String status,
  });
}