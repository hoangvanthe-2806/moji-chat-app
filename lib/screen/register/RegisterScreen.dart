
import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String route = "Registerscreen";
  @override
  State<RegisterScreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<RegisterScreen> {

  static const String route = "Registerscreen";

  //get auth service
  final authService = AuthService();
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController  = TextEditingController();
  //sign up button pressed
  void signUp() async{
    //prepare data
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final confirmPassword = _confirmPasswordController.text;

    //check that passwords match
    if(password!=confirmPassword){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password don't match")));
      return;
    }
    //attemp sign up..
    try{
      await authService.signUpWithEmailPassword(email,password,name);
      Navigator.of(context).pop();
    }catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $e")));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up"),),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView(
          children: [
            SizedBox(height: 50),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 50),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signUp, child: Text("Register")),
            SizedBox(height: 10),
            
          ],
        ),
      ),
    );
  }
}
