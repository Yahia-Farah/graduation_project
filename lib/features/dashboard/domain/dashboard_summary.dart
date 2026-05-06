class DashboardSummary {
  final int accessRequests;
  final int lawyerRequests;
  final int unassignedCases;

  const DashboardSummary({
    required this.accessRequests,
    required this.lawyerRequests,
    required this.unassignedCases,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      accessRequests: (json['accessRequests'] ?? json['access_requests'] ?? json['requests_count'] ?? 0) as int,
      lawyerRequests: (json['lawyerRequests'] ?? json['lawyer_requests'] ?? json['lawyers_count'] ?? 0) as int,
      unassignedCases: (json['unassignedCases'] ?? json['unassigned_cases'] ?? json['unassigned_count'] ?? 0) as int,
    );
  }
}
