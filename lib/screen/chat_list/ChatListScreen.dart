import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/chat_service.dart';
import '../chat_detail/ChatDetailScreen.dart';

class ChatListScreen extends StatefulWidget {
  static const String route = "ChatListScreen";

  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> users = [];
  bool isLoading = true;

  late final currentUserId;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    currentUserId = user?.id;
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      // Lấy danh sách cuộc trò chuyện có mình tham gia
      final conversations = await supabase
          .from('conversations')
          .select('id, user1_id, user2_id')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId');

      // Lấy ra ID của những người đã chat với mình
      final Set<String> friendIds = {};
      for (var conv in conversations) {
        final user1 = conv['user1_id'];
        final user2 = conv['user2_id'];
        if (user1 != currentUserId) friendIds.add(user1);
        if (user2 != currentUserId) friendIds.add(user2);
      }

      // Nếu không có ai, danh sách rỗng
      if (friendIds.isEmpty) {
        setState(() {
          users = [];
          isLoading = false;
        });
        return;
      }

      // Lấy thông tin user từ bảng users
      final response = await supabase
          .from('users')
          .select()
          .filter('id', 'in', friendIds.toList());

      setState(() {
        users = response;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi lấy danh sách bạn chat: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user['avatar_url'] != null &&
                  user['avatar_url'].isNotEmpty
                  ? NetworkImage(user['avatar_url'])
                  : const NetworkImage(
                "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
              ),
            ),
            title: Text(user['name'] ?? 'No Name'),
            subtitle: Text(user['bio'] ?? 'Không có giới thiệu'),
              onTap: () async {
                // Lấy current user
                final currentUser = Supabase.instance.client.auth.currentUser;

                if (currentUser == null) {
                  print("[DEBUG] currentUser = null ❌ (chưa đăng nhập)");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bạn cần đăng nhập trước khi nhắn tin")),
                  );
                  return;
                }

                final myId = currentUser.id;
                final otherUserId = user['id'];
                final otherUserName = user['name'];

                print("===== DEBUG CHAT START =====");
                print("My ID: $myId");
                print("Other User ID: $otherUserId");
                print("Other User Name: $otherUserName");
                print("=============================");

                try {
                  // Dùng ChatService để tạo hoặc lấy conversation
                  final chatService = ChatService();
                  final conversationId =
                  await chatService.getOrCreateConversation(myId, otherUserId);

                  print("Conversation ID: $conversationId ✅");

                  // Chuyển đến ChatDetailScreen
                  Navigator.pushNamed(
                    context,
                    ChatDetailScreen.route,
                    arguments: {
                      'conversationId': conversationId,
                      'senderId': myId,
                      'receiverId': otherUserId,
                      'receiverName': otherUserName,
                    },
                  );
                } catch (e) {
                  print("[ERROR] Gặp lỗi khi tạo conversation: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi khi tạo cuộc trò chuyện: $e")),
                  );
                }
              }

          );
        },
      ),
    );
  }
}


/*onTap: () async {
  final myId = Supabase.instance.client.auth.currentUser!.id;
  final otherUserId = user['id']; // user mà bạn click
  final otherUserName = user['name'];

  final service = ConversationService();
  final conversationId = await service.getOrCreateConversation(myId, otherUserId);

  if (conversationId != null) {
    Navigator.pushNamed(
      context,
      ChatDetailScreen.route,
      arguments: {
        'conversationId': conversationId,
        'senderId': myId,
        'receiverId': otherUserId,
        'receiverName': otherUserName,
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Không thể tạo cuộc trò chuyện")),
    );
  }
},*/