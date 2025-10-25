part of 'chat_list_cubit.dart';

abstract class ChatListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<dynamic> conversations;

  ChatListLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}
