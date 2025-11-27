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
  Future<void> removeFriend(String friendId) async {
    try {
      if (friendId.isEmpty) {
        emit(FriendListError('Friend ID không hợp lệ'));
        return;
      }
      
      await _service.removeFriend(friendId);
      // Tải lại danh sách sau khi xóa thành công
      await loadFriends();
    } catch (e) {
      emit(FriendListError(e.toString()));
      // Re-emit state hiện tại để không mất dữ liệu
      // Nếu đang ở trạng thái loaded, giữ nguyên state đó
      final currentState = state;
      if (currentState is FriendListLoaded) {
        // Không cần làm gì, error đã được emit
      }
    }
  }
}
