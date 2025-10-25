import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentication_with_supabase/models/friend_service.dart'; // đường dẫn của bạn
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final FriendService _friendService;

  SearchCubit(this._friendService) : super(const SearchState());

  /// 🔍 Tìm người dùng
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) return;
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await _friendService.searchUsers(query);
      emit(state.copyWith(isLoading: false, results: results));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// 📨 Gửi lời mời kết bạn
  Future<void> sendRequest(String receiverId) async {
    try {
      await _friendService.sendFriendRequest(receiverId);

      final updatedResults = state.results.map((user) {
        if (user['id'] == receiverId) {
          return {...user, 'requestSent': true};
        }
        return user;
      }).toList();

      emit(state.copyWith(results: updatedResults));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
