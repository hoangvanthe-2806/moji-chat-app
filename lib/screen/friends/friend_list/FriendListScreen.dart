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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bạn'),
        content: Text('Bạn có chắc muốn xóa $friendName khỏi danh sách bạn bè không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm != true) return;

    // gọi cubit để xóa và reload
    await _cubit.removeFriend(friendId);

    // sau khi xóa, reload pending count (nếu cần)
    if (!mounted) return;
    await _loadPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendListCubit, FriendListState>(
      bloc: _cubit,
      builder: (context, state) {
        // Loading state
        if (state is FriendListLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bạn bè')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (state is FriendListError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bạn bè')),
            body: Center(child: Text('❌ ${state.message}')),
          );
        }

        // Loaded
        if (state is FriendListLoaded) {
          final friends = state.friends;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bạn bè'),
              actions: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add),
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
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: friends.isEmpty
                ? const Center(child: Text('Chưa có bạn bè nào'))
                : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final f = friends[index];
                final friend = (f['friend'] as Map<String, dynamic>?) ?? {};
                final friendId = (friend['id'] as String?) ?? '';
                final friendName = (friend['name'] as String?) ?? 'Người dùng';
                final avatar = friend['avatar_url'] as String?;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(friendName),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: friendId.isEmpty
                        ? null
                        : () => _onRemovePressed(friendId, friendName),
                  ),
                );
              },
            ),
          );
        }

        // Initial / fallback
        return Scaffold(
          appBar: AppBar(title: const Text('Bạn bè')),
          body: const SizedBox(),
        );
      },
    );
  }
}
