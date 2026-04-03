import 'package:flutter/material.dart';
import 'common_widgets.dart';

class CommonPaginatedList<T> extends StatelessWidget {
  final List<T> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Future<void> Function() onLoadMore;
  final Future<void> Function()? onRefresh;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final String noMoreDataText;
  final String retryButtonText;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry? padding;

  const CommonPaginatedList({
    super.key,
    required this.items,
    this.isInitialLoading = false,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    this.onRefresh,
    this.errorMessage,
    this.onRetry,
    required this.itemBuilder,
    this.emptyTitle = 'Nothing Here Yet',
    this.emptyMessage = 'No items available right now.',
    this.emptyIcon = Icons.inbox_rounded,
    this.noMoreDataText = 'No more data',
    this.retryButtonText = 'Retry',
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && items.isEmpty) {
      return EmptyStateWidget(
        title: 'Something Went Wrong',
        message: errorMessage!,
        icon: Icons.error_outline_rounded,
        actionLabel: retryButtonText,
        onAction: onRetry,
      );
    }

    if (items.isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle,
        message: emptyMessage,
        icon: emptyIcon,
      );
    }

    final listView = NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent * 0.9) {
          if (!isLoadingMore && hasMore) {
            onLoadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        physics: physics,
        padding: padding,
        itemCount: items.length + _extraItemCount(),
        itemBuilder: (context, index) {
          if (index < items.length) {
            return itemBuilder(context, items[index], index);
          }

          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (!hasMore && items.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  noMoreDataText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );

    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: listView);
    }

    return listView;
  }

  int _extraItemCount() {
    if (isLoadingMore) return 1;
    if (!hasMore && items.isNotEmpty) return 1;
    return 0;
  }
}
