import 'package:equatable/equatable.dart';
import '../../../../auth/login/data/model/response/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  final UserModel? previousUser;
  
  const ProfileLoading({this.previousUser});
  
  @override
  List<Object?> get props => [previousUser];
}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final bool isOwner;

  const ProfileLoaded({
    required this.user,
    required this.isOwner,
  });

  @override
  List<Object?> get props => [user, isOwner];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

