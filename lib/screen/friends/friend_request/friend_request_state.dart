part of 'friend_request_cubit.dart';

sealed class FriendRequestState extends Equatable {
  const FriendRequestState();
}

final class FriendRequestInitial extends FriendRequestState {
  @override
  List<Object> get props => [];
}
