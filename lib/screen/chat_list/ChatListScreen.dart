import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
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

      if (conversations.isEmpty) {
        setState(() {
          users = [];
          isLoading = false;
        });
        return;
      }

      // Lấy ra ID của những người đã chat với mình
      final Set<String> friendIds = {};
      final Map<String, String> conversationMap = {}; // Map user_id -> conversation_id
      
      for (var conv in conversations) {
        final user1 = conv['user1_id'] as String?;
        final user2 = conv['user2_id'] as String?;
        final conversationId = conv['id'] as String?;
        
        if (conversationId == null) continue;
        
        if (user1 != null && user1 != currentUserId) {
          friendIds.add(user1);
          conversationMap[user1] = conversationId;
        }
        if (user2 != null && user2 != currentUserId) {
          friendIds.add(user2);
          conversationMap[user2] = conversationId;
        }
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
      final userResponse = await supabase
          .from('users')
          .select()
          .filter('id', 'in', friendIds.toList());

      // Lấy tin nhắn cuối cùng cho mỗi conversation
      final List<Map<String, dynamic>> combinedList = [];
      for (var userInfo in userResponse) {
        final userId = userInfo['id'] as String?;
        if (userId == null) continue;
        
        final conversationId = conversationMap[userId];
        if (conversationId == null) continue;

        // Lấy tin nhắn cuối cùng (có thể null nếu chưa có tin nhắn)
        Map<String, dynamic>? lastMessage;
        try {
          lastMessage = await supabase
              .from('messages')
              .select('id, sender_id, content, created_at, read_by')
              .eq('conversation_id', conversationId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
        } catch (e) {
          print('Lỗi lấy last message cho conversation $conversationId: $e');
          // Tiếp tục với lastMessage = null
        }

        // Kiểm tra tin nhắn chưa đọc
        bool isUnread = false;
        if (lastMessage != null && lastMessage['sender_id'] != currentUserId) {
          final readBy = lastMessage['read_by'] as List<dynamic>?;
          isUnread = readBy == null || !readBy.contains(currentUserId);
        }

        combinedList.add({
          ...userInfo,
          'conversation_id': conversationId,
          'last_message': lastMessage?['content'],
          'last_message_time': lastMessage?['created_at'],
          'is_unread': isUnread,
        });
      }

      // Sắp xếp theo thời gian tin nhắn cuối (mới nhất trước)
      // Nếu không có tin nhắn, sắp xếp theo conversation created_at
      combinedList.sort((a, b) {
        final timeA = a['last_message_time'] as String?;
        final timeB = b['last_message_time'] as String?;
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA);
      });

      setState(() {
        users = combinedList;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi lấy danh sách bạn chat: $e');
      setState(() => isLoading = false);
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (difference.inDays == 1) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE', 'vi').format(date);
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có cuộc trò chuyện nào',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: users.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark 
                        ? const Color(0xFF2F2F2F)
                        : const Color(0xFFDBDBDB),
                    indent: 80,
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return InkWell(
                      onTap: () async {
                        // Lấy current user
                        final currentUser = Supabase.instance.client.auth.currentUser;

                        if (currentUser == null) {
                          print("[DEBUG] currentUser = null ❌ (chưa đăng nhập)");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bạn cần đăng nhập trước khi nhắn tin"),
                            ),
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
                          // Dùng conversation_id nếu có, nếu không thì tạo mới
                          String conversationId = user['conversation_id'] as String? ?? '';
                          
                          if (conversationId.isEmpty) {
                            final chatService = ChatService();
                            conversationId = await chatService.getOrCreateConversation(myId, otherUserId);
                          }

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
                          ).then((_) {
                            // Reload danh sách sau khi quay lại để cập nhật trạng thái đã đọc
                            fetchUsers();
                          });
                        } catch (e) {
                          print("[ERROR] Gặp lỗi khi tạo conversation: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Lỗi khi tạo cuộc trò chuyện: $e")),
                          );
                        }
                      },
                      child: Container(
                        color: theme.colorScheme.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark 
                                      ? const Color(0xFF2F2F2F)
                                      : const Color(0xFFDBDBDB),
                                  width: 0.5,
                                ),
                              ),
                              child: ClipOval(
                                child: user['avatar_url'] != null &&
                                        user['avatar_url'].toString().isNotEmpty
                                    ? Image.network(
                                        user['avatar_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 32,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 32,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name and Last Message
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user['name'] ?? 'No Name',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 16,
                                            fontWeight: user['is_unread'] == true 
                                                ? FontWeight.w600 
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (user['last_message_time'] != null)
                                        Text(
                                          _formatTime(user['last_message_time']),
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user['last_message'] ?? 'Không có tin nhắn',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 14,
                                            fontWeight: user['is_unread'] == true 
                                                ? FontWeight.w500 
                                                : FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (user['is_unread'] == true)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Arrow icon
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF8E8E8E),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
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