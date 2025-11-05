part of 'profile_edit_cubit.dart';

abstract class ProfileEditState {}

class ProfileEditInitial extends ProfileEditState {}

class ProfileEditImagePicked extends ProfileEditState {}

class ProfileEditSaving extends ProfileEditState {}

class ProfileEditSuccess extends ProfileEditState {}

class ProfileEditError extends ProfileEditState {
  final String message;
  ProfileEditError(this.message);
}
