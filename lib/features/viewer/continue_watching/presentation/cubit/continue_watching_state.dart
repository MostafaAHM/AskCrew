import '../../data/models/continue_watching_item_model.dart';

abstract class ContinueWatchingState {}

class ContinueWatchingInitial extends ContinueWatchingState {}

class ContinueWatchingLoading extends ContinueWatchingState {}

class ContinueWatchingSuccess extends ContinueWatchingState {
  final List<ContinueWatchingItemModel> items;
  ContinueWatchingSuccess(this.items);
}

class ContinueWatchingError extends ContinueWatchingState {
  final String message;
  ContinueWatchingError(this.message);
}
