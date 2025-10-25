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

  @override
  void initState() {
    super.initState();
    _cubit = FriendListCubit(FriendService());
    _cubit.loadFriends();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendListCubit, FriendListState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is FriendListLoading) {
          return  Scaffold(
            appBar: AppBar(title: Text('Bạn bè')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is FriendListError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bạn bè')),
            body: Center(child: Text('❌ ${state.message}')),
          );
        }

        if (state is FriendListLoaded) {
          final friends = state.friends;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bạn bè'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    Navigator.pushNamed(context, FriendRequestScreen.route);
                  },
                ),
              ],
            ),
            body: friends.isEmpty
                ? const Center(child: Text('Chưa có bạn bè nào'))
                : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final f = friends[index];
                final friend = f['friend'];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend['avatar_url'] != null
                        ? NetworkImage(friend['avatar_url'])
                        : null,
                    child: friend['avatar_url'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(friend['name'] ?? 'Không rõ tên'),
                );
              },
            ),
          );
        }

        return  Scaffold(
          appBar: AppBar(title: Text('Bạn bè')),
          body: SizedBox(),
        );
      },
    );
  }
}
