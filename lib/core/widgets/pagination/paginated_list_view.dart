import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../errors/app_error_widget.dart';
import 'pagination_helper.dart';

class PaginatedListView<T> extends StatelessWidget {
  final PaginationController<T> paginationController;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final bool withSeparators;
  final bool shrinkWrap;
  final bool physics;
  final bool pullToRefresh;
  final Widget? emptyWidget;
  final bool isReverse;
  final EdgeInsetsGeometry? padding;
  const PaginatedListView({
    super.key,
    required this.paginationController,
    required this.itemBuilder,
    this.onRefresh,
    this.separatorBuilder,
    this.shrinkWrap = false,
    this.withSeparators = false,
    this.physics = false,
    this.pullToRefresh = true,
    this.emptyWidget,
    this.isReverse = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final child = withSeparators
        ? PagedListView<int, T>.separated(
            padding: padding,
            pagingController: paginationController.pagingController,
            shrinkWrap: shrinkWrap,
            reverse: isReverse,
            physics: physics ? const NeverScrollableScrollPhysics() : null,
            builderDelegate: PagedChildBuilderDelegate<T>(
              itemBuilder: itemBuilder,
              noItemsFoundIndicatorBuilder: (context) =>
                  emptyWidget ??
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // CustomLottie(
                        //   assetPath: Images.emptyBoxJson,
                        //   width: double.infinity / 1.5,
                        //   // height: double.infinity/2,
                        // ),
                        Text(
                          "No items found",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
            ),
            separatorBuilder:
                separatorBuilder ??
                (context, index) => const Divider(height: 0),
          )
        : PagedListView<int, T>(
            padding: padding,
            reverse: isReverse,
            pagingController: paginationController.pagingController,
            shrinkWrap: shrinkWrap,
            physics: physics ? const NeverScrollableScrollPhysics() : null,
            builderDelegate: PagedChildBuilderDelegate<T>(
              itemBuilder: itemBuilder,
              noItemsFoundIndicatorBuilder: (context) =>
                  emptyWidget ??
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No items found",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              firstPageErrorIndicatorBuilder: (context) => AppErrorWidget(
                onRetry: () {
                  paginationController.pagingController.refresh();
                },
              ),
              newPageErrorIndicatorBuilder: (context) => AppErrorWidget(
                onRetry: () {
                  paginationController.pagingController.refresh();
                },
              ),
            ),
          );

    return pullToRefresh
        ? RefreshIndicator(
            onRefresh:
                onRefresh ??
                () async {
                  paginationController.refresh();
                },
            child: child,
          )
        : child;
  }
}
