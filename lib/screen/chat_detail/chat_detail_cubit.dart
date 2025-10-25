import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_detail_state.dart';

class ChatDetailCubit extends Cubit<ChatDetailState> {
  final SupabaseClient supabase;
  final String conversationId;
  final String currentUserId;

  ChatDetailCubit(this.supabase, this.conversationId, this.currentUserId)
      : super(ChatDetailLoading());

  Future<void> loadMessages() async {
    emit(ChatDetailLoading());
    try {
      final response = await supabase
          .from('messages')
          .select('id, sender_id, content, image_url, created_at')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      emit(ChatDetailLoaded(response));
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      await supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'content': content,
      });
    } catch (e) {
      emit(ChatDetailError("Gửi tin nhắn thất bại: $e"));
    }
  }

  /// Lắng nghe realtime tin nhắn mới
  void subscribeMessages() {
    final channel = supabase.channel('conversation_$conversationId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) {
        final newMessage = payload.newRecord;
        if (state is ChatDetailLoaded) {
          final currentMessages =
          List<Map<String, dynamic>>.from((state as ChatDetailLoaded).messages);
          emit(ChatDetailLoaded([...currentMessages, newMessage]));
        }
      },
    );

    channel.subscribe();
  }
}
