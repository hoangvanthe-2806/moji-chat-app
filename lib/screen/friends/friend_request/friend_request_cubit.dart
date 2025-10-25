import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'friend_request_state.dart';

class FriendRequestCubit extends Cubit<FriendRequestState> {
  FriendRequestCubit() : super(FriendRequestInitial());
}
