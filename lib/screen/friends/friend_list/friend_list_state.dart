part of 'friend_list_cubit.dart';

sealed class FriendListState extends Equatable {
  const FriendListState();
}

final class FriendListInitial extends FriendListState {
  @override
  List<Object> get props => [];
}
