import 'package:aflam/core/app_config/content_types.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/favorite_item_model.dart';
import '../../data/repository/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesInitial());

  String _getKey(String contentType, int objectId) =>
      '${AppContentTypes.mapForFavorite(contentType)}_$objectId';

  Future<void> loadFavorites() async {
    final user = UserHelper.userNotifier.value;
    if (user == null) {
      // Guest users don't have favorites
      return;
    }

    emit(FavoritesLoading(state.favoritesKeys));

    final result = await _repository.getFavorites();

    result.fold(
      (error) => emit(FavoritesError(error.message, state.favoritesKeys)),
      (response) {
        final keys = response.results.map((e) => e.key).toSet();
        emit(FavoritesLoaded(response.results, keys));
      },
    );
  }

  bool isFavorite(String contentType, int objectId) {
    return state.favoritesKeys.contains(_getKey(contentType, objectId));
  }

  Future<void> toggleFavorite({
    required String contentType,
    required int objectId,
  }) async {
    final key = _getKey(contentType, objectId);
    final currentlyFavorite = state.favoritesKeys.contains(key);

    // Optimistic Update
    final newKeys = Set<String>.from(state.favoritesKeys);
    if (currentlyFavorite) {
      newKeys.remove(key);
    } else {
      newKeys.add(key);
    }

    // Keep current favorites list if available
    List<FavoriteItemModel> currentFavorites = [];
    if (state is FavoritesLoaded) {
      currentFavorites = (state as FavoritesLoaded).favorites;
    }

    emit(FavoritesLoaded(currentFavorites, newKeys));

    final apiContentType = AppContentTypes.mapForFavorite(contentType);

    final result = currentlyFavorite
        ? await _repository.removeFavorite(
            contentType: apiContentType,
            objectId: objectId,
          )
        : await _repository.addFavorite(
            contentType: apiContentType,
            objectId: objectId,
          );

    result.fold(
      (error) {
        // Rollback on failure
        final rollbackKeys = Set<String>.from(state.favoritesKeys);
        if (currentlyFavorite) {
          rollbackKeys.add(key);
        } else {
          rollbackKeys.remove(key);
        }
        emit(FavoritesError(error.message, rollbackKeys));
        // After showing error, go back to loaded state with old keys
        emit(FavoritesLoaded(currentFavorites, rollbackKeys));
      },
      (_) {
        // Success - we might want to refresh the full list to get the new FavoriteItemModel
        // with its actual ID and createdAt if we are on the favorites screen
        // But for toggle from other screens, optimistic update is enough.
        // Optional: loadFavorites();
      },
    );
  }
}
