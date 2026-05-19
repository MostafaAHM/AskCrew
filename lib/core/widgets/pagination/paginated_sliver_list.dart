import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../errors/app_error_widget.dart';
import 'pagination_helper.dart';

class PaginatedSliverList<T> extends StatelessWidget {
  final PaginationController<T> paginationController;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final bool withSeparators;
  final bool pullToRefresh;
  final Widget? emptyWidget;
  final bool isReverse;
  const PaginatedSliverList({
    super.key,
    required this.paginationController,
    required this.itemBuilder,
    this.onRefresh,
    this.separatorBuilder,
    this.withSeparators = false,
    this.pullToRefresh = true,
    this.emptyWidget,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final sliverChild = withSeparators
        ? PagedSliverList<int, T>.separated(
            pagingController: paginationController.pagingController,
            // reverse: isReverse,
            builderDelegate: _buildDelegate(context),
            separatorBuilder:
                separatorBuilder ??
                (context, index) => const Divider(height: 0),
          )
        : PagedSliverList<int, T>(
            pagingController: paginationController.pagingController,
            // reverse: isReverse,
            builderDelegate: _buildDelegate(context),
          );

    return sliverChild;
  }

  PagedChildBuilderDelegate<T> _buildDelegate(BuildContext context) {
    return PagedChildBuilderDelegate<T>(
      itemBuilder: itemBuilder,
      noItemsFoundIndicatorBuilder: (context) =>
          emptyWidget ??
          Center(
            child: Text(
              "No items found",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ),
      firstPageErrorIndicatorBuilder: (context) => AppErrorWidget(
        onRetry: () => paginationController.pagingController.refresh(),
      ),
      newPageErrorIndicatorBuilder: (context) => AppErrorWidget(
        onRetry: () => paginationController.pagingController.refresh(),
      ),
    );
  }
}
