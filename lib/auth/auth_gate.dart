/*
*
* AUTH GATE - This will continuously listen for auth state changes.
*
*
* ---------------------------------------------------------------------
*
* unauthenticated ->login  Page
* authenticated -> profile
*
* */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screen/home/HomeScreen.dart';
import '../screen/login/LoginScreen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  static const String route = "/auth_gate";
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // lis ten to auth state changes
        stream: Supabase.instance.client.auth.onAuthStateChange,
        //build appropiate page based on auth state
        builder: (context, snapshot) {
          //loading..
          if(snapshot.connectionState == ConnectionState.waiting) {
            return  Scaffold(
              body: Center(child: CircularProgressIndicator(),),
            );
          }
          //check if there is  a valid session currently
          final session = snapshot.hasData?snapshot.data!.session : null;

          if(session!=null) {
            return HomeScreen();
          }else {
            return LoginScreen();
          }
        },
    );
  }
}
