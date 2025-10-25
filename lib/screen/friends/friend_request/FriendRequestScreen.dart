import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/friend_service.dart';
import 'friend_request_cubit.dart';
import 'friend_request_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendRequestCubit, FriendRequestState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Lời mời kết bạn')),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(FriendRequestState state) {
    if (state is FriendRequestLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FriendRequestError) {
      return Center(child: Text('❌ ${state.message}'));
    }

    if (state is FriendRequestLoaded) {
      final requests = state.requests;
      if (requests.isEmpty) {
        return const Center(child: Text('Không có lời mời nào'));
      }

      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final sender = req['sender'] as Map<String, dynamic>? ?? {};
          final requestId = req['id'] as String?;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: sender['avatar_url'] != null
                    ? NetworkImage(sender['avatar_url'])
                    : null,
                child:
                sender['avatar_url'] == null ? const Icon(Icons.person) : null,
              ),
              title: Text(sender['name'] ?? 'Người dùng ẩn danh'),
              subtitle: Text('Gửi lúc: ${req['created_at'] ?? ''}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: requestId == null ? null : () => _cubit.accept(requestId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: requestId == null ? null : () => _cubit.decline(requestId),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const SizedBox();
  }
}
