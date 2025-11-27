import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/friend_service.dart';
import '../chat_detail/ChatDetailScreen.dart';
import 'search_cubit.dart';
import 'search_state.dart';
import '../../widgets/user_avatar.dart';

class SearchScreen extends StatefulWidget {
  static const String route = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(FriendService()),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Tìm bạn bè',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            final cubit = context.read<SearchCubit>();
            final supabase = Supabase.instance.client;
            final myId = supabase.auth.currentUser?.id ?? "";

            return Column(
              children: [
                // Search Field
                Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark 
                            ? const Color(0xFF2F2F2F)
                            : const Color(0xFFDBDBDB),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'hoangthe',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 24,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          cubit.searchUsers(value.trim());
                        }
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          cubit.searchUsers(value.trim());
                        }
                      },
                    ),
                  ),
                ),

                // Loading
                if (state.isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                // Error
                if (state.error != null && !state.isLoading)
                  Expanded(
                    child: Center(
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                // Results
                if (!state.isLoading && state.error == null)
                  Expanded(
                    child: state.results.isEmpty
                        ? Center(
                            child: Text(
                              'Không tìm thấy kết quả',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: state.results.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 0.5,
                              color: isDark 
                                  ? const Color(0xFF2F2F2F)
                                  : const Color(0xFFDBDBDB),
                              indent: 80,
                            ),
                            itemBuilder: (context, index) {
                              final user = state.results[index];
                              final bool isFriend = user['isFriend'] == true;
                              final bool requestSent = user['requestSent'] == true;

                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/user_profile',
                                    arguments: {
                                      'userId': user['id'],
                                      'userName': user['name'] ?? 'Không rõ tên',
                                    },
                                  );
                                },
                                child: Container(
                                  color: theme.colorScheme.surface,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar with online indicator
                                      UserAvatar(
                                        avatarUrl: user['avatar_url']?.toString(),
                                        size: 56,
                                        isOnline: user['is_online'] == true,
                                      ),
                                      const SizedBox(width: 12),
                                      // Name
                                      Expanded(
                                        child: Text(
                                          user['name'] ?? 'Không rõ tên',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      // Action Button
                                      if (isFriend)
                                        IconButton(
                                          icon: Icon(
                                            Icons.chat_bubble_outline,
                                            color: theme.colorScheme.onSurface,
                                            size: 24,
                                          ),
                                          onPressed: () async {
                                            final conversationId = await cubit
                                                .getOrCreateConversation(user['id']);
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
                                        )
                                      else
                                        TextButton(
                                          onPressed: requestSent
                                              ? null
                                              : () => cubit.sendRequest(user['id']),
                                          style: TextButton.styleFrom(
                                            foregroundColor: requestSent
                                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                                : theme.colorScheme.primary,
                                            disabledForegroundColor:
                                                theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          child: Text(
                                            requestSent ? 'Đã gửi' : 'Kết bạn',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ],
            );
          },
        ),
          );
        },
      ),
    );
  }
}
