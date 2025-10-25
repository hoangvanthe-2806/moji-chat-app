import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_gate.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://htwxyqmaiushsortlmet.supabase.co/',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0d3h5cW1haXVzaHNvcnRsbWV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwMDQ2MzAsImV4cCI6MjA3NTU4MDYzMH0.tUHHFqPGEVCKIZhC3ak3_fMymrr_YIsKYVFUeS7APuM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      // AuthGate là entrypoint -> quyết định render LoginScreen hoặc HomeScreen
      home:  AuthGate(),


      onGenerateRoute: mainRoute,
    );
  }
}