enum CaseStatus { pending, inProgress, completed }

CaseStatus parseCaseStatus(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':
      return CaseStatus.pending;
    case 'IN_PROGRESS':
      return CaseStatus.inProgress;
    case 'COMPLETED':
      return CaseStatus.completed;
    default:
      return CaseStatus.pending;
  }
}

String caseStatusToApi(CaseStatus s) {
  switch (s) {
    case CaseStatus.pending:
      return 'PENDING';
    case CaseStatus.inProgress:
      return 'IN_PROGRESS';
    case CaseStatus.completed:
      return 'COMPLETED';
  }
}

String caseStatusLabel(CaseStatus s) {
  switch (s) {
    case CaseStatus.pending:
      return 'لم يبدأ التحليل';
    case CaseStatus.inProgress:
      return 'قيد التحليل';
    case CaseStatus.completed:
      return 'مكتملة';
  }
}
