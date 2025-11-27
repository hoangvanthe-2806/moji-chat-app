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
      'read_by': [senderId], // Tin nhắn mình gửi tự động đánh dấu đã đọc
    };
    await _supabase.from('messages').insert(payload);
  }

  /// Đánh dấu tất cả tin nhắn trong conversation là đã đọc bởi userId
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    // Lấy tất cả tin nhắn chưa đọc (chưa có userId trong read_by)
    final unreadMessages = await _supabase
        .from('messages')
        .select('id, read_by')
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId); // Chỉ đánh dấu tin nhắn không phải từ mình

    // Cập nhật từng tin nhắn: thêm userId vào mảng read_by nếu chưa có
    for (var msg in unreadMessages) {
      final readBy = (msg['read_by'] as List<dynamic>?) ?? [];
      if (!readBy.contains(userId)) {
        final updatedReadBy = [...readBy, userId];
        await _supabase
            .from('messages')
            .update({'read_by': updatedReadBy})
            .eq('id', msg['id']);
      }
    }
  }

  /// Xóa conversation và tất cả messages liên quan
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Xóa tất cả messages trong conversation trước
      final deleteMessagesResult = await _supabase
          .from('messages')
          .delete()
          .eq('conversation_id', conversationId);
      print("✅ Đã xóa messages: $deleteMessagesResult");
      
      // Sau đó xóa conversation
      final deleteConvResult = await _supabase
          .from('conversations')
          .delete()
          .eq('id', conversationId);
      print("✅ Đã xóa conversation: $deleteConvResult");
    } catch (e) {
      print("❌ Lỗi khi xóa conversation: $e");
      rethrow;
    }
  }

  /// Xóa một message (chỉ user gửi mới xóa được)
  Future<void> deleteMessage(String messageId, String userId) async {
    // Kiểm tra message có phải của user này không
    final message = await _supabase
        .from('messages')
        .select('sender_id')
        .eq('id', messageId)
        .maybeSingle();
    
    if (message == null) {
      throw Exception('Tin nhắn không tồn tại');
    }
    
    if (message['sender_id'] != userId) {
      throw Exception('Bạn không có quyền xóa tin nhắn này');
    }
    
    // Xóa message
    await _supabase
        .from('messages')
        .delete()
        .eq('id', messageId);
  }
}
