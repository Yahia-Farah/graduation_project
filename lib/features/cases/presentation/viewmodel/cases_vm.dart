import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cases_providers.dart';
import '../../domain/case_model.dart';
import '../../domain/page_info.dart';
import '../../data/repositories/cases_repo.dart';

class CasesState {
  final bool loading;
  final String? error;

  final List<CaseModel> items;
  final PageInfo pageInfo;

  final int page; // 0-based
  final int pageSize;
  final String query;

  final String statusFilter; // ALL / PENDING / IN_PROGRESS / COMPLETED
  const CasesState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.pageInfo = PageInfo.empty,
    this.page = 0,
    this.pageSize = 10,
    this.query = '',
    this.statusFilter = 'ALL',
  });

  CasesState copyWith({
    bool? loading,
    String? error,
    List<CaseModel>? items,
    PageInfo? pageInfo,
    int? page,
    int? pageSize,
    String? query,
    String? statusFilter,
  }) {
    return CasesState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class CasesVm extends Notifier<CasesState> {
  @override
  CasesState build() {
    Future.microtask(load);
    return const CasesState();
  }

  void setQuery(String v) {
    state = state.copyWith(query: v, error: null);
  }

  Future<void> search() async {
    state = state.copyWith(page: 0);
    await load();
  }

  Future<void> nextPage() async {
    if (!state.pageInfo.hasNext || state.loading) return;
    state = state.copyWith(page: state.page + 1);
    await load();
  }

  Future<void> prevPage() async {
    if (!state.pageInfo.hasPrevious || state.loading) return;
    state = state.copyWith(page: state.page - 1);
    await load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final repo = ref.read(casesRepoProvider);
      final CasesResult result = await repo.getCases(
        page: state.page,
        pageSize: state.pageSize,
        query: state.query,
      );

      state = state.copyWith(
        loading: false,
        items: result.items,
        pageInfo: result.pageInfo,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status, page: 0);
    load();
  }
}

final casesVmProvider = NotifierProvider<CasesVm, CasesState>(CasesVm.new);
