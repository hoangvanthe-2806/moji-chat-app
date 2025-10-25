import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../chat_list/ChatListScreen.dart';
import '../profile/ProfileScreen.dart';
import '../settings/SettingScreen.dart';
import '../search/SearchScreen.dart';
import 'home_cubit.dart';

class HomeScreen extends StatelessWidget {
  // ✅ Giống cấu trúc route trong mainRoute
  static const String route = 'HomeScreen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(
        builder: (context, state)  {
          final pages = [
             ChatListScreen(),
             ProfileScreen(),
             SettingScreen(),
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Chats'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // ✅ Dùng route của SearchScreen thay vì '/search'
                    Navigator.pushNamed(context, SearchScreen.route,);
                  },
                ),
              ],
            ),
            body: pages[state],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state,
              onTap: (index) {
                print(index);
                context.read<HomeCubit>().changeTab(index);
              },
              items:  [
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profile'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
          );
        },
      ),
    );
  }
}
