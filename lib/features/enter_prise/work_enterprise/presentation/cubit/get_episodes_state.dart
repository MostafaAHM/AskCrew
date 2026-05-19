part of 'get_episodes_cubit.dart';

abstract class GetEpisodesState {}

class GetEpisodesInitial extends GetEpisodesState {}

class GetEpisodesLoading extends GetEpisodesState {}

class GetEpisodesLoaded extends GetEpisodesState {
  final List<EpisodeModel> episodes;
  GetEpisodesLoaded(this.episodes);
}

class GetEpisodesError extends GetEpisodesState {
  final String message;
  GetEpisodesError(this.message);
}
