import 'package:supabase_flutter/supabase_flutter.dart';

class ConversationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lấy hoặc tạo mới conversation giữa 2 user
  Future<String?> getOrCreateConversation(String user1Id, String user2Id) async {
    try {
      // 1. Kiểm tra xem 2 người đã có conversation chưa
      final existing = await _supabase
          .from('conversations')
          .select('id')
          .eq('is_group', false)
          .contains('participants', [user1Id, user2Id]) // nếu bạn có cột JSON participants
          .maybeSingle();

      if (existing != null && existing['id'] != null) {
        return existing['id'] as String;
      }

      // 2. Nếu chưa có, tạo mới conversation
      final newConversation = await _supabase
          .from('conversations')
          .insert({
        'is_group': false,
        'created_at': DateTime.now().toIso8601String(),
      })
          .select('id')
          .single();

      final conversationId = newConversation['id'] as String;

      // 3. Thêm 2 người vào conversation_members
      await _supabase.from('conversation_members').insert([
        {
          'conversation_id': conversationId,
          'user_id': user1Id,
          'role': 'member',
        },
        {
          'conversation_id': conversationId,
          'user_id': user2Id,
          'role': 'member',
        },
      ]);

      return conversationId;
    } catch (e) {
      print('❌ Lỗi getOrCreateConversation: $e');
      return null;
    }
  }
}
