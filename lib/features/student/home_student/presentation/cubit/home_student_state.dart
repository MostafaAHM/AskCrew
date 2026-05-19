import 'package:equatable/equatable.dart';

import '../../../../enter_prise/home_enterprise/data/model/talent_model.dart';
import '../../../../enter_prise/work_enterprise/data/models/response/workshop_response_model.dart';
import '../../../../enter_prise/work_enterprise/data/models/response/movie_model.dart';
import '../../data/model/student_profile_model.dart';

abstract class HomeStudentState extends Equatable {
  const HomeStudentState();

  @override
  List<Object?> get props => [];
}

class HomeStudentInitial extends HomeStudentState {}

class HomeStudentLoading extends HomeStudentState {}

class HomeStudentLoaded extends HomeStudentState {
  final StudentProfileModel profile;
  final List<TalentModel> talents;
  final List<TalentModel> students;
  final List<WorkshopResponseModel> workshops;
  final List<MovieModel> trending;

  const HomeStudentLoaded({
    required this.profile,
    required this.talents,
    required this.students,
    required this.workshops,
    required this.trending,
  });

  @override
  List<Object?> get props => [profile, talents, students, workshops, trending];
}

class HomeStudentError extends HomeStudentState {
  final String message;

  const HomeStudentError(this.message);

  @override
  List<Object?> get props => [message];
}
