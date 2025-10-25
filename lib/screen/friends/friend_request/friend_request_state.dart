abstract class FriendRequestState {}

class FriendRequestInitial extends FriendRequestState {}

class FriendRequestLoading extends FriendRequestState {}

class FriendRequestLoaded extends FriendRequestState {
  final List<Map<String, dynamic>> requests;
  FriendRequestLoaded(this.requests);
}

class FriendRequestError extends FriendRequestState {
  final String message;
  FriendRequestError(this.message);
}
