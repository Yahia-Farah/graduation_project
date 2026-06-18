import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cases_providers.dart';
import '../../domain/case_model.dart';
import '../../domain/page_info.dart';

class JudgeArchiveState {
  final bool loading;
  final String? error;
  final List<CaseModel> allItems;
  final List<CaseModel> items;
  final PageInfo pageInfo;
  final int page;
  final int pageSize;
  final String query;

  const JudgeArchiveState({
    this.loading = false,
    this.error,
    this.allItems = const [],
    this.items = const [],
    this.pageInfo = PageInfo.empty,
    this.page = 0,
    this.pageSize = 10,
    this.query = '',
  });

  JudgeArchiveState copyWith({
    bool? loading,
    String? error,
    List<CaseModel>? allItems,
    List<CaseModel>? items,
    PageInfo? pageInfo,
    int? page,
    String? query,
  }) {
    return JudgeArchiveState(
      loading: loading ?? this.loading,
      error: error,
      allItems: allItems ?? this.allItems,
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
      page: page ?? this.page,
      pageSize: pageSize,
      query: query ?? this.query,
    );
  }
}

class JudgeArchiveVm extends Notifier<JudgeArchiveState> {
  @override
  JudgeArchiveState build() {
    Future.microtask(load);
    return const JudgeArchiveState();
  }

  void setQuery(String v) {
    state = state.copyWith(query: v, error: null);
  }

  void search() {
    state = state.copyWith(page: 0);
    load(forceRefresh: true);
  }

  void nextPage() {
    if (!state.pageInfo.hasNext || state.loading) return;
    state = state.copyWith(page: state.page + 1);
    _applyFilters();
  }

  void prevPage() {
    if (!state.pageInfo.hasPrevious || state.loading) return;
    state = state.copyWith(page: state.page - 1);
    _applyFilters();
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && state.allItems.isNotEmpty) {
      state = state.copyWith(loading: false, error: null);
      return;
    }
    state = state.copyWith(loading: true, error: null);

    try {
      final repo = ref.read(casesRepoProvider);
      // Fetch all cases and filter to COMPLETED for archive
      final result = await repo.getCases(page: 0, pageSize: 1000, query: '');

      final completedItems = result.items
          .where((c) => c.status.toUpperCase() == 'COMPLETED')
          .toList();

      state = state.copyWith(allItems: completedItems, page: 0);
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _applyFilters() {
    var filtered = state.allItems;

    if (state.query.isNotEmpty) {
      final q = state.query.toLowerCase();
      filtered = filtered
          .where((c) =>
              c.caseNumber.toLowerCase().contains(q) ||
              c.courtRuling.toLowerCase().contains(q))
          .toList();
    }

    final totalElements = filtered.length;
    final totalPages = (totalElements / state.pageSize).ceil();
    var currentPage = state.page;
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }

    final startIndex = currentPage * state.pageSize;
    final endIndex = (startIndex + state.pageSize > totalElements)
        ? totalElements
        : startIndex + state.pageSize;

    final pageItems = startIndex < totalElements
        ? filtered.sublist(startIndex, endIndex)
        : <CaseModel>[];

    final pageInfo = PageInfo(
      currentPage: currentPage,
      totalPages: totalPages,
      totalElements: totalElements,
      pageSize: state.pageSize,
      hasNext: currentPage < totalPages - 1,
      hasPrevious: currentPage > 0,
    );

    state = state.copyWith(
      loading: false,
      items: pageItems,
      pageInfo: pageInfo,
      page: currentPage,
    );
  }
}

final judgeArchiveVmProvider =
    NotifierProvider<JudgeArchiveVm, JudgeArchiveState>(JudgeArchiveVm.new);
