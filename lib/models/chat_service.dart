import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tìm conversation giữa 2 user; nếu không có thì tạo mới và trả về id conversation
  Future<String> getOrCreateConversation(String userA, String userB) async {
    // 1) Tìm conversation với thứ tự (user1=userA,user2=userB)
    final List? res1 = await _supabase
        .from('conversations')
        .select('id')
        .eq('user1_id', userA)
        .eq('user2_id', userB)
        .limit(1);
    if (res1 != null && res1.isNotEmpty) {
      return res1.first['id'] as String;
    }

    // 2) Tìm ngược lại (user1=userB,user2=userA)
    final List? res2 = await _supabase
        .from('conversations')
        .select('id')
        .eq('user1_id', userB)
        .eq('user2_id', userA)
        .limit(1);
    if (res2 != null && res2.isNotEmpty) {
      return res2.first['id'] as String;
    }

    // 3) Nếu vẫn không có -> tạo mới (để hợp schema của bạn, dùng các cột user1_id/user2_id)
    final insertRes = await _supabase.from('conversations').insert({
      'user1_id': userA,
      'user2_id': userB,
    }).select('id').single();
    // insertRes trả về object với id
    return insertRes['id'] as String;
  }

  /// Stream danh sách messages của conversation (Supabase `.stream`)
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    final stream = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    // stream emits List<Map<String, dynamic>>
    return stream.map((list) {
      return (list as List).map((e) => MessageModel.fromJson(e)).toList();
    });
  }

  /// Lấy history messages (1 lần)
  Future<List<MessageModel>> fetchMessages(String conversationId) async {
    final res = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    if (res == null) return [];
    return (res as List).map((e) => MessageModel.fromJson(e)).toList();
  }

  /// Gửi message (insert vào bảng messages)
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    String? content,
    String? imageUrl,
  }) async {
    final payload = {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'image_url': imageUrl,
    };
    await _supabase.from('messages').insert(payload);
  }
}
