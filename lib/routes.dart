import 'package:flutter/material.dart';
import '../screen/home/HomeScreen.dart';
import '../screen/login/LoginScreen.dart';
import '../screen/register/RegisterScreen.dart';
import '../screen/profile/ProfileScreen.dart';
import '../screen/profile/profile_edit/ProfileEditScreen.dart';
import '../screen/chat_list/ChatListScreen.dart';
import '../screen/chat_detail/ChatDetailScreen.dart';
import '../screen/search/SearchScreen.dart';
import '../screen/settings/SettingScreen.dart';
import '../screen/friends/friend_request/FriendRequestScreen.dart';
import '../screen/friends/friend_list/FriendListScreen.dart';

Route<dynamic>? mainRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.route:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case RegisterScreen.route:
      return MaterialPageRoute(builder: (context) => RegisterScreen());
    case HomeScreen.route:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case SettingScreen.route:
      return MaterialPageRoute(builder: (context) => SettingScreen());
    case ProfileScreen.route:
      return MaterialPageRoute(builder: (context) => ProfileScreen());
    case ProfileEditScreen.route:
      return MaterialPageRoute(builder: (context) => ProfileEditScreen());
    case ChatListScreen.route:
      return MaterialPageRoute(builder: (context) => ChatListScreen());
    case ChatDetailScreen.route:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          conversationId: args['conversationId'],
          senderId: args['senderId'],
          receiverId: args['receiverId'],
          receiverName: args['receiverName'],
        ),
      );
    case SearchScreen.route:
      return MaterialPageRoute(builder: (context) => SearchScreen());
    case FriendRequestScreen.route:
      return MaterialPageRoute(builder: (_) => const FriendRequestScreen());
    case FriendListScreen.route:
      return MaterialPageRoute(builder: (_) => const FriendListScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Không tìm thấy route: ${settings.name}')),
        ),
      );
  }
}
