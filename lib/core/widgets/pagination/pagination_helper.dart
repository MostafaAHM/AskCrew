import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// A reusable pagination controller class that works with any data type [T].
/// You provide your own fetch logic by passing a `Future<List<T>> Function(int pageKey)` callback.
class PaginationController<T> {
  /// Public PagingController you can bind to any Paged widget
  final PagingController<int, T> pagingController;

  /// Page size used in each fetch
  final int pageSize;

  /// Fetch logic provided externally
  final Future<List<T>> Function(int pageKey) fetchPage;

  /// Optional debug tag for logging
  final String? debugTag;

  PaginationController({
    required this.fetchPage,
    this.pageSize = 20,
    this.debugTag,
  }) : pagingController = PagingController(firstPageKey: 1) {
    pagingController.addPageRequestListener(_handlePageRequest);
  }

  /// Internal function triggered when a new page is requested
  Future<void> _handlePageRequest(int pageKey) async {
    try {
      if (debugTag != null) debugPrint('[$debugTag] Fetching page $pageKey');

      final newItems = await fetchPage(pageKey);
      final isLastPage = newItems.length < pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
        if (debugTag != null) debugPrint('[$debugTag] Last page reached.');
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(newItems, nextPageKey);
        if (debugTag != null) debugPrint('[$debugTag] Appended page $pageKey');
      }
    } catch (error) {
      pagingController.error = error;
      if (debugTag != null) debugPrint('[$debugTag] Error: $error');
    }
  }

  /// Adds manual items at the beginning of the list (useful for chat)

  void insertItemsAtTop(List<T> items) {
    final currentItems = List<T>.from(pagingController.itemList ?? []);
    final updatedItems = [...items, ...currentItems];
    pagingController.itemList = updatedItems;

    if (debugTag != null) {
      debugPrint('[$debugTag] Inserted ${items.length} items at the top.');
    }
  }

  void updateItem(bool Function(T item) matcher, T Function(T old) updateFn) {
    final items = pagingController.itemList;
    if (items == null) return;

    final index = items.indexWhere(matcher);
    if (index == -1) return;

    final updatedItem = updateFn(items[index]);
    final newList = List<T>.from(items);
    newList[index] = updatedItem;

    pagingController.itemList = newList;

    if (debugTag != null) {
      debugPrint('[$debugTag] Updated item at index $index');
    }
  }

  /// Refresh data
  void refresh() {
    pagingController.refresh();
  }

  /// Dispose the controller when done
  void dispose() {
    pagingController.dispose();
  }
}
