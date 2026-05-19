import 'package:equatable/equatable.dart';
import '../../data/models/talent_profile_model.dart';

abstract class TalentProfileState extends Equatable {
  const TalentProfileState();

  @override
  List<Object?> get props => [];
}

class TalentProfileInitial extends TalentProfileState {}

class TalentProfileLoading extends TalentProfileState {}

class TalentProfileLoaded extends TalentProfileState {
  final TalentProfileModel profile;

  const TalentProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TalentProfileError extends TalentProfileState {
  final String message;

  const TalentProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
