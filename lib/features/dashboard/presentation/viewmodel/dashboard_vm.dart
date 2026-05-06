import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dashboard_repo.dart';
import '../../data/repositories/dashboard_repo_impl.dart';
import '../../domain/dashboard_summary.dart';

final dashboardVmProvider = StateNotifierProvider<DashboardVm, AsyncValue<DashboardSummary>>((ref) {
  final repo = ref.watch(dashboardRepoProvider);
  return DashboardVm(repo)..fetchSummary();
});

class DashboardVm extends StateNotifier<AsyncValue<DashboardSummary>> {
  final DashboardRepo _repo;
  DashboardVm(this._repo) : super(const AsyncValue.loading());

  Future<void> fetchSummary() async {
    state = const AsyncValue.loading();
    try {
      final summary = await _repo.fetchSummary();
      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
