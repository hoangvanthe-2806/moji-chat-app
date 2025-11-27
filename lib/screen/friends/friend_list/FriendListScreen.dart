// lib/screen/friends/friend_list/friend_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/friend_service.dart';
import '../friend_request/FriendRequestScreen.dart';
import 'friend_list_cubit.dart';
import 'friend_list_state.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({Key? key}) : super(key: key);
  static const String route = '/friend_list';

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late final FriendListCubit _cubit;
  int pendingCount = 0; // số lời mời đang chờ

  @override
  void initState() {
    super.initState();
    _cubit = FriendListCubit(FriendService());
    _loadData();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _cubit.loadFriends();

    if (!mounted) return;
    await _loadPendingRequests();

    if (!mounted) return;
  }

  Future<void> _loadPendingRequests() async {
    try {
      final count = await FriendService().countPendingRequests();
      if (!mounted) return;
      setState(() {
        pendingCount = count;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        pendingCount = 0;
      });
    }
  }

  Future<void> _onRemovePressed(String friendId, String friendName) async {
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bạn'),
        content: Text('Bạn có chắc muốn xóa $friendName khỏi danh sách bạn bè không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm != true) return;

    // Hiển thị loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // gọi cubit để xóa và reload
      await _cubit.removeFriend(friendId);

      // Đóng loading dialog
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Kiểm tra state sau khi xóa
      final currentState = _cubit.state;
      if (currentState is FriendListError) {
        // Lỗi đã được xử lý bởi BlocListener
        return;
      }

      // Hiển thị thông báo thành công
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa $friendName khỏi danh sách bạn bè'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // sau khi xóa, reload pending count (nếu cần)
      if (!mounted) return;
      await _loadPendingRequests();
    } catch (e) {
      // Đóng loading dialog nếu có lỗi
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Hiển thị lỗi
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa bạn bè: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendListCubit, FriendListState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is FriendListError) {
          // Hiển thị lỗi nếu có
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<FriendListCubit, FriendListState>(
        bloc: _cubit,
        builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        // Loading state
        if (state is FriendListLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Bạn bè',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        // Error state
        if (state is FriendListError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Bạn bè',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Center(
              child: Text(
                '❌ ${state.message}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        // Loaded
        if (state is FriendListLoaded) {
          final friends = state.friends;
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Bạn bè',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                // Search icon
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Navigate to search screen
                    Navigator.pushNamed(context, '/search');
                  },
                ),
                // Add friend icon with badge
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.person_add_outlined,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(context, FriendRequestScreen.route);
                        // reload pending count and friends when come back
                        if (!mounted) return;
                        await _cubit.loadFriends();
                        if (!mounted) return;
                        await _loadPendingRequests();
                      },
                    ),
                    if (pendingCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            pendingCount > 9 ? '9+' : '$pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: friends.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có bạn bè nào',
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
                    itemCount: friends.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 0.5,
                      color: isDark 
                          ? const Color(0xFF2F2F2F)
                          : const Color(0xFFDBDBDB),
                      indent: 80,
                    ),
                    itemBuilder: (context, index) {
                      final f = friends[index];
                      final friend = (f['friend'] as Map<String, dynamic>?) ?? {};
                      final friendId = (friend['id'] as String?) ?? '';
                      final friendName = (friend['name'] as String?) ?? 'Người dùng';
                      final avatar = friend['avatar_url'] as String?;

                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/user_profile',
                            arguments: {
                              'userId': friendId,
                              'userName': friendName,
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
                                  child: avatar != null && avatar.isNotEmpty
                                      ? Image.network(
                                          avatar,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
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
                              // Name
                              Expanded(
                                child: Text(
                                  friendName,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                onPressed: friendId.isEmpty
                                    ? null
                                    : () => _onRemovePressed(friendId, friendName),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        }

        // Initial / fallback
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'Bạn bè',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: const SizedBox(),
        );
        },
      ),
    );
  }
}
