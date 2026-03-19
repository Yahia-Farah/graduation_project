class DashboardSummary {
  final int activeCases;
  final int newCases;
  final int todayHearings;

  const DashboardSummary({
    required this.activeCases,
    required this.newCases,
    required this.todayHearings,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeCases: (json['activeCases'] ?? 0) as int,
      newCases: (json['newCases'] ?? 0) as int,
      todayHearings: (json['todayHearings'] ?? 0) as int,
    );
  }
}