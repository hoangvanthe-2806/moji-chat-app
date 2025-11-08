abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final Map<String, dynamic> user;
  final bool isFriend;
  UserProfileLoaded(this.user, this.isFriend);
}


class UserProfileError extends UserProfileState {
  final String message;
  UserProfileError(this.message);
}
