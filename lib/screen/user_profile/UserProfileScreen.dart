import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../chat_detail/ChatDetailScreen.dart';
import 'user_profile_cubit.dart';
import 'user_profile_state.dart';

class UserProfileScreen extends StatelessWidget {
  static const String route = '/user_profile';
  final String userId;
  final String userName;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  Future<String> getOrCreateConversation(String otherUserId) async {
    final supabase = Supabase.instance.client;
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('User not logged in');

    try {
      final data = await supabase
          .from('conversations')
          .select()
          .or('user1_id.eq.$myId,user2_id.eq.$myId')
          .or('user1_id.eq.$otherUserId,user2_id.eq.$otherUserId')
          .limit(1)
          .maybeSingle();

      if (data != null) {
        return data['id'];
      }

      final result = await supabase
          .from('conversations')
          .insert({
        'user1_id': myId,
        'user2_id': otherUserId,
      })
          .select()
          .single();

      return result['id'];
    } catch (e) {
      throw Exception('Không thể tạo cuộc trò chuyện');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserProfileCubit()..loadUserProfile(userId),
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(userName)),
            body: _buildBody(state, context),
          );
        },
      ),
    );
  }

  Widget _buildBody(UserProfileState state, BuildContext context) {
    if (state is UserProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UserProfileError) {
      return Center(child: Text(state.message));
    }

    if (state is UserProfileLoaded) {
      final user = state.user;
      return Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: user['avatar_url']?.isNotEmpty == true
                ? NetworkImage(user['avatar_url'])
                : null,
            child: user['avatar_url']?.isEmpty ?? true
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user['name'] ?? 'Không rõ tên',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (user['bio']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(user['bio']),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    String conversationId = await getOrCreateConversation(userId);
                    if (!context.mounted) return;

                    Navigator.pushNamed(
                      context,
                      ChatDetailScreen.route,
                      arguments: {
                        'conversationId': conversationId,
                        'senderId': Supabase.instance.client.auth.currentUser?.id ?? "",
                        'receiverId': userId,
                        'receiverName': userName,
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không thể tạo cuộc trò chuyện')),
                    );
                  }
                },
                icon: const Icon(Icons.message),
                label: const Text('Nhắn tin'),
              ),
            ],
          )
        ],
      );
    }

    return const SizedBox();
  }
}
