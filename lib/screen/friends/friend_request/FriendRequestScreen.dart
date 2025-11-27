import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../models/friend_service.dart';
import 'friend_request_cubit.dart';
import 'friend_request_state.dart';
import '../../../widgets/user_avatar.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({Key? key}) : super(key: key);
  static const String route = '/friend_request';

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  late final FriendRequestCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = FriendRequestCubit(FriendService());
    _cubit.loadRequests();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Vừa xong';
          }
          return '${difference.inMinutes} phút trước';
        }
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays == 1) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendRequestCubit, FriendRequestState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is FriendRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<FriendRequestCubit, FriendRequestState>(
        bloc: _cubit,
        builder: (context, state) {
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
                'Lời mời kết bạn',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(FriendRequestState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (state is FriendRequestLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (state is FriendRequestError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.message}',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _cubit.loadRequests(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state is FriendRequestLoaded) {
      final requests = state.requests;
      if (requests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Không có lời mời nào',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: requests.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: isDark 
              ? const Color(0xFF2F2F2F)
              : const Color(0xFFDBDBDB),
          indent: 80,
        ),
        itemBuilder: (context, index) {
          final req = requests[index];
          final sender = req['sender'] as Map<String, dynamic>? ?? {};
          final requestId = req['id'] as String?;
          final senderName = sender['name'] ?? 'Người dùng ẩn danh';
          final senderAvatar = sender['avatar_url'] as String?;

          return Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Avatar with online indicator
                UserAvatar(
                  avatarUrl: senderAvatar,
                  size: 56,
                  isOnline: sender['is_online'] == true,
                ),
                const SizedBox(width: 12),
                // Name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(req['created_at'] as String?),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept button
                    Container(
                      width: 80,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: requestId == null
                            ? null
                            : () async {
                                await _cubit.accept(requestId);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã chấp nhận lời mời từ $senderName'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                        child: const Text(
                          'Đồng ý',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Decline button
                    Container(
                      width: 80,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: requestId == null
                            ? null
                            : () async {
                                await _cubit.decline(requestId);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã từ chối lời mời từ $senderName'),
                                      backgroundColor: Colors.orange,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: isDark 
                                ? const Color(0xFF2F2F2F)
                                : const Color(0xFFDBDBDB),
                            width: 1,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Từ chối',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return const SizedBox();
  }
}
