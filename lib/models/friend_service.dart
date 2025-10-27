import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 👥 Lấy danh sách bạn bè của current user
  Future<List<Map<String, dynamic>>> getFriends() async {
    final myId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('friends')
    // ⚙️ Chỉ embed theo friend_id để tránh lỗi "more than one relationship"
        .select('friend_id, friend:users!friends_friend_id_fkey(id, name, avatar_url)')
        .eq('user_id', myId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔍 Tìm người dùng (loại trừ chính mình)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final myId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('users')
        .select('id, name, email, avatar_url')
        .ilike('name', '%$query%')
        .neq('id', myId);

    return List<Map<String, dynamic>>.from(response);
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

    // Thêm vào bảng friends 2 chiều
    await _supabase.from('friends').insert([
      {'user_id': senderId, 'friend_id': receiverId},
      {'user_id': receiverId, 'friend_id': senderId},
    ]);
  }

  /// ❌ Từ chối lời mời
  Future<void> rejectFriendRequest(String requestId) async {
    await _supabase
        .from('friend_requests')
        .update({'status': 'rejected'})
        .eq('id', requestId);
  }

  /// 📩 Lấy tất cả lời mời nhận được của current user
  Future<List<Map<String, dynamic>>> getIncomingRequests() async {
    final myId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('friend_requests')
        .select(
      '*, sender:users!friend_requests_sender_id_fkey(id, name, avatar_url)',
    )
        .eq('receiver_id', myId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔔 Đếm số lượng lời mời kết bạn đang chờ
  Future<int> countPendingRequests() async {
    final myId = _supabase.auth.currentUser!.id; // ✅ dùng _supabase thay vì supabase
    final response = await _supabase
        .from('friend_requests')
        .select()
        .eq('receiver_id', myId)
        .eq('status', 'pending');

    return response.length;
  }
  /// ❌ Xóa bạn bè
  Future<void> removeFriend(String friendId) async {
    final myId = _supabase.auth.currentUser!.id;

    // Xóa 2 chiều: mình với họ, họ với mình
    await _supabase.from('friends')
        .delete()
        .or('and(user_id.eq.$myId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$myId)');
  }

}
