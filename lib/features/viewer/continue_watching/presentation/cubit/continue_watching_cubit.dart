import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/helpers/user_helper.dart';
import '../../data/models/continue_watching_item_model.dart';
import '../../data/models/continue_watching_request_model.dart';
import '../../data/repo/continue_watching_repository.dart';
import 'continue_watching_state.dart';

class ContinueWatchingCubit extends Cubit<ContinueWatchingState> {
  final ContinueWatchingRepository repository;

  List<ContinueWatchingItemModel> _items = [];
  List<ContinueWatchingItemModel> get items => _items;

  static ContinueWatchingCubit get(context) => BlocProvider.of(context);

  ContinueWatchingCubit(this.repository) : super(ContinueWatchingInitial());

  Future<void> loadContinueWatching({bool isRefresh = false}) async {
    if (UserHelper.userNotifier.value == null) {
      emit(ContinueWatchingSuccess(const []));
      return;
    }

    if (!isRefresh && _items.isEmpty) {
      emit(ContinueWatchingLoading());
    }

    final result = await repository.getContinueWatching();
    result.fold((error) => emit(ContinueWatchingError(error.message)), (
      newItems,
    ) {
      _items = _deduplicateAndSort(newItems);
      emit(ContinueWatchingSuccess(_items));
    });
  }

  Future<void> updateProgress(UpdateContinueWatchingRequest request) async {
    if (UserHelper.userNotifier.value == null) return;
    await repository.updateContinueWatching(request: request);
  }

  /// Get existing continue watching ID if available
  int? getContinueWatchingId(int contentId, String type) {
    try {
      final item = _items.firstWhere((element) {
        if (element.contentData == null) return false;
        final itemType = element.contentData!.artWorkType;
        return element.objectId == contentId && itemType == type;
      });
      return item.id;
    } catch (_) {
      return null;
    }
  }

  List<ContinueWatchingItemModel> _deduplicateAndSort(
    List<ContinueWatchingItemModel> items,
  ) {
    // Sort descending by updatedAt
    items.sort((a, b) {
      final dateA = DateTime.tryParse(a.updatedAt) ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.updatedAt) ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    final Map<String, ContinueWatchingItemModel> uniqueMap = {};
    for (var item in items) {
      if (item.contentData == null) continue;

      final type =
          item.contentData!.artWorkType ??
          (item.contentData!.isSeries ? 'series' : 'movie');
      final key = '${item.objectId}_$type';

      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = item;
      }
    }
    return uniqueMap.values.toList();
  }
}
