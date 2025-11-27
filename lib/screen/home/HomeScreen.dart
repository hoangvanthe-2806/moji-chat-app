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
            FriendListScreen(),
            ProfileScreen(),
            SettingScreen(),
          ];

          // Tên tab tương ứng
          final tabTitles = ['Chat', 'Friends', 'Profile', 'Settings'];
          final tabIcons = [
            Icons.chat_bubble_outline,
            Icons.people_outline,
            Icons.person_outline,
            Icons.settings_outlined,
          ];
          final selectedTabIcons = [
            Icons.chat_bubble,
            Icons.people,
            Icons.person,
            Icons.settings,
          ];

          // Tên section theo tab
          final sectionTitles = ['Chats', 'Friends', 'Profile', 'Settings'];

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            // AppBar đơn giản, nhẹ nhàng như Instagram
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              title: Row(
                children: [
                  Text(
                    'Moji',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    sectionTitles[state],
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, SearchScreen.route);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            body: Container(
              color: theme.scaffoldBackgroundColor,
              child: pages[state],
            ),
            
            // Bottom Navigation Bar đơn giản như Instagram
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark 
                        ? const Color(0xFF2F2F2F)
                        : const Color(0xFFDBDBDB),
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: state,
                selectedItemColor: theme.colorScheme.onSurface,
                unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                onTap: (index) {
                  context.read<HomeCubit>().changeTab(index);
                },
                items: List.generate(
                  tabTitles.length,
                  (index) => BottomNavigationBarItem(
                    icon: Icon(
                      state == index
                          ? selectedTabIcons[index]
                          : tabIcons[index],
                      size: 28,
                    ),
                    label: tabTitles[index],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}