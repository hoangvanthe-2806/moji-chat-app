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
}
