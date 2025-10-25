import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final SupabaseClient supabase;
  final String currentUserId;

  ChatListCubit(this.supabase, this.currentUserId) : super(ChatListLoading());

  Future<void> loadConversations() async {
    emit(ChatListLoading());
    try {
      final response = await supabase
          .from('conversations')
          .select('id, is_group, group_name, user1_id, user2_id, created_at')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
          .order('created_at', ascending: false);

      emit(ChatListLoaded(response));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}
