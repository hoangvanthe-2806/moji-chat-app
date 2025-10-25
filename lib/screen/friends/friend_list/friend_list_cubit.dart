import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/friend_service.dart';
import 'friend_list_state.dart';

class FriendListCubit extends Cubit<FriendListState> {
  final FriendService _service;

  FriendListCubit(this._service) : super(FriendListInitial());

  Future<void> loadFriends() async {
    try {
      emit(FriendListLoading());
      final friends = await _service.getFriends();
      emit(FriendListLoaded(friends));
    } catch (e) {
      emit(FriendListError(e.toString()));
    }
  }
}
