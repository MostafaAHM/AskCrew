import 'package:equatable/equatable.dart';
import '../../data/models/response/advertise_model.dart';

abstract class GetAdvertisesState extends Equatable {
  const GetAdvertisesState();

  @override
  List<Object> get props => [];
}

class GetAdvertisesInitial extends GetAdvertisesState {
  const GetAdvertisesInitial();
}

class GetAdvertisesLoading extends GetAdvertisesState {
  const GetAdvertisesLoading();
}

class GetAdvertisesLoaded extends GetAdvertisesState {
  final List<AdvertiseModel> advertises;
  const GetAdvertisesLoaded(this.advertises);

  @override
  List<Object> get props => [advertises];
}

class GetAdvertisesError extends GetAdvertisesState {
  final String message;
  const GetAdvertisesError(this.message);

  @override
  List<Object> get props => [message];
}
