import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'auth/auth_gate.dart';
import 'routes.dart';
import 'services/ThemeService.dart';

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
    return ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'Chat App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF0095F6),
                surface: Colors.white,
                background: const Color(0xFFFAFAFA),
                onSurface: const Color(0xFF262626),
                onBackground: const Color(0xFF262626),
              ),
              scaffoldBackgroundColor: const Color(0xFFFAFAFA),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF262626),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF0095F6),
                surface: const Color(0xFF1A1A1A),
                background: Colors.black,
                onSurface: Colors.white,
                onBackground: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: themeService.themeMode,
            // AuthGate là entrypoint -> quyết định render LoginScreen hoặc HomeScreen
            home: const AuthGate(),
            onGenerateRoute: mainRoute,
          );
        },
      ),
    );
  }
}