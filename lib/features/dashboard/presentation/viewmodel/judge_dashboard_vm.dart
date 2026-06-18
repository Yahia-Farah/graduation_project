import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cases/cases_providers.dart';
import '../../../cases/domain/case_model.dart';
import '../../../cases/domain/page_info.dart';

class JudgeDashboardState {
  final bool loading;
  final String? error;
  final int newCount;
  final int inProgressCount;
  final int completedCount;
  final List<CaseModel> allItems;
  final List<CaseModel> items;
  final PageInfo pageInfo;
  final int page;
  final int pageSize;
  final String query;
  final Set<String> selectedCaseIds;

  const JudgeDashboardState({
    this.loading = false,
    this.error,
    this.newCount = 0,
    this.inProgressCount = 0,
    this.completedCount = 0,
    this.allItems = const [],
    this.items = const [],
    this.pageInfo = PageInfo.empty,
    this.page = 0,
    this.pageSize = 10,
    this.query = '',
    this.selectedCaseIds = const {},
  });

  JudgeDashboardState copyWith({
    bool? loading,
    String? error,
    int? newCount,
    int? inProgressCount,
    int? completedCount,
    List<CaseModel>? allItems,
    List<CaseModel>? items,
    PageInfo? pageInfo,
    int? page,
    String? query,
    Set<String>? selectedCaseIds,
  }) {
    return JudgeDashboardState(
      loading: loading ?? this.loading,
      error: error,
      newCount: newCount ?? this.newCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      completedCount: completedCount ?? this.completedCount,
      allItems: allItems ?? this.allItems,
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
      page: page ?? this.page,
      pageSize: pageSize,
      query: query ?? this.query,
      selectedCaseIds: selectedCaseIds ?? this.selectedCaseIds,
    );
  }
}

class JudgeDashboardVm extends Notifier<JudgeDashboardState> {
  @override
  JudgeDashboardState build() {
    Future.microtask(load);
    return const JudgeDashboardState();
  }

  void setQuery(String v) {
    state = state.copyWith(query: v, error: null);
  }

  void search() {
    state = state.copyWith(page: 0);
    load(forceRefresh: true);
  }

  void toggleCaseSelection(String caseId) {
    final newSet = Set<String>.from(state.selectedCaseIds);
    if (newSet.contains(caseId)) {
      newSet.remove(caseId);
    } else {
      newSet.add(caseId);
    }
    state = state.copyWith(selectedCaseIds: newSet);
  }

  void clearSelection() {
    state = state.copyWith(selectedCaseIds: {});
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
      final result = await repo.getCases(page: 0, pageSize: 1000, query: '');

      final allItems = result.items;
      final newCount =
          allItems.where((c) => c.status.toUpperCase() == 'PENDING').length;
      final inProgressCount = allItems
          .where((c) => c.status.toUpperCase() == 'IN_PROGRESS')
          .length;
      final completedCount = allItems
          .where((c) => c.status.toUpperCase() == 'COMPLETED')
          .length;

      state = state.copyWith(
        allItems: allItems,
        newCount: newCount,
        inProgressCount: inProgressCount,
        completedCount: completedCount,
        page: 0,
      );
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

final judgeDashboardVmProvider =
    NotifierProvider<JudgeDashboardVm, JudgeDashboardState>(
        JudgeDashboardVm.new);
