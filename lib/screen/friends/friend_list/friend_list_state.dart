abstract class FriendListState {}

class FriendListInitial extends FriendListState {}

class FriendListLoading extends FriendListState {}

class FriendListLoaded extends FriendListState {
  final List<Map<String, dynamic>> friends;
  FriendListLoaded(this.friends);
}

class FriendListError extends FriendListState {
  final String message;
  FriendListError(this.message);
}
