import 'package:equatable/equatable.dart';
import 'package:aflam/core/models/movie_model.dart';

abstract class HomeSearchState extends Equatable {
  const HomeSearchState();

  @override
  List<Object?> get props => [];
}

class HomeSearchInitial extends HomeSearchState {}

class HomeSearchLoading extends HomeSearchState {}

class HomeSearchLoaded extends HomeSearchState {
  final List<MovieModel> movies;

  const HomeSearchLoaded({required this.movies});

  @override
  List<Object?> get props => [movies];
}

class HomeSearchError extends HomeSearchState {
  final String message;

  const HomeSearchError({required this.message});

  @override
  List<Object?> get props => [message];
}

class HomeSearchEmpty extends HomeSearchState {}
