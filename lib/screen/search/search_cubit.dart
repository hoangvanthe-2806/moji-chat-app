import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/friend_service.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final FriendService _service;

  SearchCubit(this._service) : super(const SearchState());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await _service.searchUsers(query);
      emit(state.copyWith(isLoading: false, results: results));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> sendRequest(String userId) async {
    try {
      await _service.sendFriendRequest(userId);

      final updated = state.results.map((user) {
        if (user['id'] == userId) return {...user, 'requestSent': true};
        return user;
      }).toList();

      emit(state.copyWith(results: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<String> getOrCreateConversation(String receiverId) async {
    final supabase = Supabase.instance.client;
    final myId = supabase.auth.currentUser!.id;

    // 🟢 Kiểm tra xem đã có conversation chưa
    final existing = await supabase
        .from('conversations')
        .select()
        .or('and(user1_id.eq.$myId,user2_id.eq.$receiverId),and(user1_id.eq.$receiverId,user2_id.eq.$myId)')
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    // 🆕 Nếu chưa có thì tạo mới
    final newConv = await supabase
        .from('conversations')
        .insert({
      'user1_id': myId,
      'user2_id': receiverId,
      'created_at': DateTime.now().toIso8601String(),
    })
        .select()
        .single();

    return newConv['id'];
  }
}
