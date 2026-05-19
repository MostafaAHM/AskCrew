part of 'get_seasons_cubit.dart';

abstract class GetSeasonsState {}

class GetSeasonsInitial extends GetSeasonsState {}

class GetSeasonsLoading extends GetSeasonsState {}

class GetSeasonsLoaded extends GetSeasonsState {
  final List<SeasonModel> seasons;
  GetSeasonsLoaded(this.seasons);
}

class GetSeasonsError extends GetSeasonsState {
  final String message;
  GetSeasonsError(this.message);
}
