import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/friend_service.dart';
import '../chat_detail/ChatDetailScreen.dart';
import 'search_cubit.dart';
import 'search_state.dart';

class SearchScreen extends StatelessWidget {
  static const String route = '/search';
  final TextEditingController _controller = TextEditingController();

  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(FriendService()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tìm bạn bè')),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            final cubit = context.read<SearchCubit>();
            final supabase = Supabase.instance.client;
            final myId = supabase.auth.currentUser?.id ?? "";

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên người dùng...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            cubit.searchUsers(_controller.text.trim()),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                if (state.isLoading)
                  const Center(child: CircularProgressIndicator()),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final user = state.results[index];

                      final bool isFriend = user['isFriend'] == true;
                      final bool requestSent = user['requestSent'] == true;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (user['avatar_url'] != null &&
                              user['avatar_url'].toString().isNotEmpty)
                              ? NetworkImage(user['avatar_url'])
                              : null,
                          child: (user['avatar_url'] == null ||
                              user['avatar_url'].toString().isEmpty)
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user['name'] ?? 'Không rõ tên'),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: isFriend
                            ? ElevatedButton(
                          onPressed: () async {
                            final conversationId =
                            await cubit.getOrCreateConversation(
                                user['id']);

                            Navigator.pushNamed(
                              context,
                              ChatDetailScreen.route,
                              arguments: {
                                'conversationId': conversationId,
                                'senderId': myId,
                                'receiverId': user['id'],
                                'receiverName': user['name'],
                              },
                            );
                          },
                          child: const Text("Nhắn tin"),
                        )
                            : ElevatedButton(
                          onPressed: requestSent
                              ? null
                              : () => cubit.sendRequest(user['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: requestSent
                                ? Colors.grey
                                : Colors.blueAccent,
                          ),
                          child: Text(
                              requestSent ? 'Đã gửi' : 'Kết bạn'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
