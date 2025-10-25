import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔍 Tìm người dùng (loại trừ chính mình)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final myId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('users')
        .select('id, name, email, avatar_url')
        .ilike('name', '%$query%')
        .neq('id', myId);

    return response;
  }

  /// 📨 Gửi lời mời kết bạn
  Future<void> sendFriendRequest(String receiverId) async {
    final myId = _supabase.auth.currentUser!.id;

    final existing = await _supabase
        .from('friend_requests')
        .select()
        .eq('sender_id', myId)
        .eq('receiver_id', receiverId)
        .maybeSingle();

    if (existing != null) return; // đã gửi rồi thì bỏ qua

    await _supabase.from('friend_requests').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// ✅ Chấp nhận lời mời
  Future<void> acceptFriendRequest(String requestId) async {
    final response = await _supabase
        .from('friend_requests')
        .update({'status': 'accepted'})
        .eq('id', requestId)
        .select()
        .single();

    final senderId = response['sender_id'];
    final receiverId = response['receiver_id'];

    // thêm vào bảng friends
    await _supabase.from('friends').insert([
      {'user_id': senderId, 'friend_id': receiverId},
      {'user_id': receiverId, 'friend_id': senderId},
    ]);
  }

  /// ❌ Từ chối lời mời
  Future<void> rejectFriendRequest(String requestId) async {
    await _supabase.from('friend_requests')
        .update({'status': 'rejected'})
        .eq('id', requestId);
  }

  /// 👥 Lấy danh sách bạn bè
  Future<List<Map<String, dynamic>>> getFriends() async {
    final myId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('friends')
        .select('friend_id, users(name, avatar_url)')
        .eq('user_id', myId);

    return response;
  }
}
