part of 'content_management_cubit.dart';

abstract class ContentManagementState {}

class ContentManagementInitial extends ContentManagementState {}

class ContentManagementLoading extends ContentManagementState {}

class ContentManagementSuccess extends ContentManagementState {
  final String message;
  final dynamic data;
  ContentManagementSuccess({this.message = '', this.data});
}

class ContentManagementError extends ContentManagementState {
  final String message;
  ContentManagementError(this.message);
}
