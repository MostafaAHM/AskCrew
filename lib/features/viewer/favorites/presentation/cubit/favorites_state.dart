import '../../data/model/favorite_item_model.dart';

abstract class FavoritesState {
  final Set<String> favoritesKeys;
  FavoritesState({this.favoritesKeys = const {}});
}

class FavoritesInitial extends FavoritesState {
  FavoritesInitial() : super();
}

class FavoritesLoading extends FavoritesState {
  FavoritesLoading(Set<String> favoritesKeys)
    : super(favoritesKeys: favoritesKeys);
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItemModel> favorites;
  FavoritesLoaded(this.favorites, Set<String> favoritesKeys)
    : super(favoritesKeys: favoritesKeys);
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message, Set<String> favoritesKeys)
    : super(favoritesKeys: favoritesKeys);
}

class FavoritesToggleInProgress extends FavoritesState {
  FavoritesToggleInProgress(Set<String> favoritesKeys)
    : super(favoritesKeys: favoritesKeys);
}
