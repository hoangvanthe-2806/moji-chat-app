import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<UserModel?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle(); // tránh lỗi nếu không có row

    if (data == null) return null;

    return UserModel.fromMap(data);
  }

  // Thêm method kiểm tra trạng thái bạn bè
  Future<bool> isFriend(String userId) async {
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return false;

    final response = await supabase
        .from('friends')
        .select()
        .or('and(user_id.eq.$myId,friend_id.eq.$userId),and(user_id.eq.$userId,friend_id.eq.$myId)')
        .maybeSingle();

    return response != null;
  }
}
