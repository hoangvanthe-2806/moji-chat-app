import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../chat_list/ChatListScreen.dart';
import '../friends/friend_list/FriendListScreen.dart';
import '../profile/ProfileScreen.dart';
import '../settings/SettingScreen.dart';
import '../search/SearchScreen.dart';
import 'home_cubit.dart';

class HomeScreen extends StatelessWidget {
  static const String route = 'HomeScreen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(
        builder: (context, state) {
          final pages = [
            ChatListScreen(),
            FriendListScreen(), // ✅ Thêm tab bạn bè
            ProfileScreen(),
            SettingScreen(),
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Moji'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.pushNamed(context, SearchScreen.route);
                  },
                ),
              ],
            ),
            body: pages[state],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: state,
              selectedItemColor: Colors.blue, // ✅ Màu khi chọn
              unselectedItemColor: Colors.grey, // ✅ Màu khi chưa chọn
              showUnselectedLabels: true,
              onTap: (index) {
                print("Clicked index: $index");
                context.read<HomeCubit>().changeTab(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Friends',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),

          );
        },
      ),
    );
  }
}
