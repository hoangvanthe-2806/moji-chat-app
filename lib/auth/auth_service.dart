import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password, String name) async {
    final res = await _supabase.auth.signUp(email: email, password: password);

    if (res.user != null) {
      final userId = res.user!.id;

      // 1️⃣ Tạo record user
      await _supabase.from('users').insert({
        'id': userId,
        'name': name,
        'avatar_url': '',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2️⃣ (Tùy chọn) Tạo conversation mặc định hoặc thêm vào conversation chung
      const conversationId = '826b13ba-5429-4db7-bca7-c062bc387e1a'; // ví dụ conversation sẵn có
      await _supabase.from('conversation_members').insert({
        'conversation_id': conversationId,
        'user_id': userId,
        'role': 'member',
      });
    }

    return res;
  }

  // sign out
  Future<void> singOut() async {
    await _supabase.auth.signOut();
  }

  // get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
