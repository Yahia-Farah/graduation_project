import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cases_providers.dart';
import '../../domain/case_model.dart';
import '../../domain/page_info.dart';
import '../../data/repositories/cases_repo.dart';

class CasesState {
  final bool loading;
  final String? error;

  final List<CaseModel> allItems;
  final List<CaseModel> items;
  final PageInfo pageInfo;

  final int page; // 0-based
  final int pageSize;
  final String query;

  final String statusFilter; // ALL / PENDING / IN_PROGRESS / COMPLETED
  final DateTime? dateFilter;
  const CasesState({
    this.loading = false,
    this.error,
    this.allItems = const [],
    this.items = const [],
    this.pageInfo = PageInfo.empty,
    this.page = 0,
    this.pageSize = 10,
    this.query = '',
    this.statusFilter = 'ALL',
    this.dateFilter,
  });

  CasesState copyWith({
    bool? loading,
    String? error,
    List<CaseModel>? allItems,
    List<CaseModel>? items,
    PageInfo? pageInfo,
    int? page,
    int? pageSize,
    String? query,
    String? statusFilter,
    DateTime? dateFilter,
    bool clearDate = false,
  }) {
    return CasesState(
      loading: loading ?? this.loading,
      error: error,
      allItems: allItems ?? this.allItems,
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
      dateFilter: clearDate ? null : (dateFilter ?? this.dateFilter),
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
    load(forceRefresh: true);
  }

  Future<void> nextPage() async {
    if (!state.pageInfo.hasNext || state.loading) return;
    state = state.copyWith(page: state.page + 1);
    _applyFilters();
  }

  Future<void> prevPage() async {
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
      // Fetch all cases once for client-side filtering
      final CasesResult result = await repo.getCases(
        page: 0,
        pageSize: 1000,
        query: '',
      );

      state = state.copyWith(
        allItems: result.items,
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

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status, page: 0);
    load(forceRefresh: true);
  }

  void setDateFilter(DateTime? date) {
    state = state.copyWith(dateFilter: date, clearDate: date == null, page: 0);
    load(forceRefresh: true);
  }

  void _applyFilters() {
    var filtered = state.allItems;

    if (state.query.isNotEmpty) {
      final q = state.query.toLowerCase();
      filtered = filtered.where((c) =>
          c.caseNumber.toLowerCase().contains(q) ||
          c.courtRuling.toLowerCase().contains(q)).toList();
    }

    if (state.statusFilter != 'ALL') {
      filtered = filtered
          .where((c) =>
              c.status.toUpperCase() == state.statusFilter.toUpperCase())
          .toList();
    }

    if (state.dateFilter != null) {
      final d = state.dateFilter!;
      filtered = filtered.where((c) =>
          c.createdAt.year == d.year &&
          c.createdAt.month == d.month &&
          c.createdAt.day == d.day).toList();
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

    final pageItems = startIndex < totalElements ? filtered.sublist(startIndex, endIndex) : <CaseModel>[];

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

final casesVmProvider = NotifierProvider<CasesVm, CasesState>(CasesVm.new);
