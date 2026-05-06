import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/dashboard_summary.dart';
import '../sources/dashboard_remote_ds.dart';
import 'dashboard_repo.dart';

final dashboardRepoProvider = Provider<DashboardRepo>((ref) {
  final dio = ref.watch(dioProvider);
  final remoteDs = DashboardRemoteDs(dio);
  return DashboardRepoImpl(remoteDs);
});

class DashboardRepoImpl implements DashboardRepo {
  final DashboardRemoteDs _remoteDs;
  DashboardRepoImpl(this._remoteDs);

  @override
  Future<DashboardSummary> fetchSummary() async {
    final res = await _remoteDs.fetchSummary();
    return DashboardSummary.fromJson(res);
  }
}
