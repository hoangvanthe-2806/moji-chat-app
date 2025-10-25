part of 'chat_detail_cubit.dart';

abstract class ChatDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatDetailLoading extends ChatDetailState {}

class ChatDetailLoaded extends ChatDetailState {
  final List<dynamic> messages;
  ChatDetailLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatDetailError extends ChatDetailState {
  final String message;
  ChatDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
