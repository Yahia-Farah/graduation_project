import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../cases/cases_providers.dart';
import '../../../cases/data/repositories/cases_repo.dart';
import '../../../access_requests/domain/access_request_entity.dart';

class SentRequestsState {
  final bool loading;
  final String? error;
  final List<AccessRequestEntity> requests;
  final String statusFilter; // PENDING, APPROVED, REJECTED

  const SentRequestsState({
    this.loading = false,
    this.error,
    this.requests = const [],
    this.statusFilter = 'PENDING',
  });

  SentRequestsState copyWith({
    bool? loading,
    String? error,
    List<AccessRequestEntity>? requests,
    String? statusFilter,
    bool clearError = false,
  }) {
    return SentRequestsState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      requests: requests ?? this.requests,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class SentRequestsVm extends Notifier<SentRequestsState> {
  @override
  SentRequestsState build() {
    Future.microtask(load);
    return const SentRequestsState();
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && state.requests.isNotEmpty) return;
    
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(casesRepoProvider);
      final rawData = await repo.getSentRequests(state.statusFilter);
      
      final items = rawData
          .whereType<Map>()
          .map((e) => AccessRequestEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      state = state.copyWith(loading: false, requests: items);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setStatusFilter(String status) {
    if (state.statusFilter == status) return;
    state = state.copyWith(statusFilter: status, requests: []);
    load(forceRefresh: true);
  }
}

final sentRequestsVmProvider = NotifierProvider<SentRequestsVm, SentRequestsState>(SentRequestsVm.new);
