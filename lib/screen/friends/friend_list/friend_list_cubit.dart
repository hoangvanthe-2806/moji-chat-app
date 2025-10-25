import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'friend_list_state.dart';

class FriendListCubit extends Cubit<FriendListState> {
  FriendListCubit() : super(FriendListInitial());
}
