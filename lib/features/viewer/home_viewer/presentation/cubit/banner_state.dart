part of 'banner_cubit.dart';

@immutable
sealed class BannerState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerFailure extends BannerState {
  final String message;
  BannerFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BannerSuccess extends BannerState {
  final BannersResponseModel response;
  BannerSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

