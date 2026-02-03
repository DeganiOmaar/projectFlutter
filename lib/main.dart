import 'package:flutter/material.dart';
import 'package:project/screens/homepage.dart';
import 'package:project/services/auth_service.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> hasToken() async {
    final token = await AuthService.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: hasToken(),
        builder: (context, snap) {
          if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return snap.data! ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
