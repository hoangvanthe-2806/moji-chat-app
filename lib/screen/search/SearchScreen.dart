import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/friend_service.dart';
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
        appBar: AppBar(
          title: const Text('Tìm bạn bè'),
          centerTitle: true,
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            final cubit = context.read<SearchCubit>();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                    padding: const EdgeInsets.all(8.0),
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
                      final bool sent = user['requestSent'] == true;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['avatar_url'] != null
                              ? NetworkImage(user['avatar_url'])
                              : null,
                          child: user['avatar_url'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user['name'] ?? 'Không rõ tên'),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: sent
                              ? null
                              : () => cubit.sendRequest(user['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            sent ? Colors.grey : Colors.blueAccent,
                          ),
                          child: Text(sent ? 'Đã gửi' : 'Kết bạn'),
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
