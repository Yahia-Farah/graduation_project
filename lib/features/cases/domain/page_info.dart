class PageInfo {
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const PageInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      currentPage: (json['currentPage'] ?? 0) as int,
      totalPages: (json['totalPages'] ?? 0) as int,
      totalElements: (json['totalElements'] ?? 0) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      hasNext: (json['hasNext'] ?? false) as bool,
      hasPrevious: (json['hasPrevious'] ?? false) as bool,
    );
  }

  static const empty = PageInfo(
    currentPage: 0,
    totalPages: 0,
    totalElements: 0,
    pageSize: 10,
    hasNext: false,
    hasPrevious: false,
  );
}