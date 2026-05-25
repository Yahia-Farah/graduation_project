import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/access_request_entity.dart';
import '../../access_requests_providers.dart';

class AccessRequestsViewModel extends AsyncNotifier<List<AccessRequestEntity>> {
  String _currentStatus = 'PENDING';

  @override
  Future<List<AccessRequestEntity>> build() async {
    return _fetchRequests(_currentStatus);
  }

  Future<List<AccessRequestEntity>> _fetchRequests(String status) async {
    final repo = ref.read(accessRequestsRepoProvider);
    return await repo.getRequestsByStatus(status);
  }

  Future<void> changeTab(String newStatus) async {
    _currentStatus = newStatus;
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _fetchRequests(_currentStatus));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveRequest(String requestId) async {
    final previousList = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(accessRequestsRepoProvider);
      await repo.approveRequest(requestId);
      final updatedList = previousList.where((r) => r.requestId != requestId).toList();
      state = AsyncValue.data(updatedList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectRequest(String requestId) async {
    final previousList = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(accessRequestsRepoProvider);
      await repo.rejectRequest(requestId);
      final updatedList = previousList.where((r) => r.requestId != requestId).toList();
      state = AsyncValue.data(updatedList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final accessRequestsViewModelProvider =
    AsyncNotifierProvider<AccessRequestsViewModel, List<AccessRequestEntity>>(
        AccessRequestsViewModel.new);
