class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      perPage: json['per_page'] as int,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
}
