import 'package:equatable/equatable.dart';

import '../../data/model/enterprise_profile_model.dart';
import '../../data/model/performance_metric_model.dart';
import '../../data/model/talent_model.dart';
import '../../data/model/workshop_model.dart';
import '../../../work_enterprise/data/models/response/movie_model.dart';

abstract class HomeEnterpriseState extends Equatable {
  const HomeEnterpriseState();

  @override
  List<Object?> get props => [];
}

class HomeEnterpriseInitial extends HomeEnterpriseState {}

class HomeEnterpriseLoading extends HomeEnterpriseState {}

class HomeEnterpriseLoaded extends HomeEnterpriseState {
  final EnterpriseProfileModel profile;
  final List<PerformanceMetricModel> metrics;
  final List<WorkshopModel> workshops;
  final List<dynamic> forRent; // Using dynamic to support MovieModel
  final List<TalentModel> talents;
  final List<TalentModel> students;
  final List<MovieModel> trending;

  const HomeEnterpriseLoaded({
    required this.profile,
    required this.metrics,
    required this.workshops,
    required this.forRent,
    required this.talents,
    required this.students,
    required this.trending,
  });

  @override
  List<Object?> get props => [
    profile,
    metrics,
    workshops,
    forRent,
    talents,
    students,
    trending,
  ];
}

class HomeEnterpriseError extends HomeEnterpriseState {
  final String message;

  const HomeEnterpriseError(this.message);

  @override
  List<Object?> get props => [message];
}
