import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';
import '../login/LoginScreen.dart';

class SettingScreen extends StatelessWidget {

  static const String route = "SettingScreen";
  //get auth
  final authService = AuthService();

  Future<void> logout(BuildContext context) async {
    await authService.singOut();

    // Điều hướng về LoginScreen sau khi đăng xuất
    Navigator.pushReplacementNamed(context, LoginScreen.route);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10,left: 10),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Logout"),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                await logout(context);
              },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Đổi mật khẩu"),
              IconButton(
                icon: Icon(Icons.lock_reset),
                onPressed: () async {
                  await logout(context);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Quên mật khẩu"),
              IconButton(
                icon: Icon(Icons.question_mark ),
                onPressed: () async {
                  await logout(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
