import '../../domain/dashboard_summary.dart';

abstract class DashboardRepo {
  Future<DashboardSummary> fetchSummary();
}
