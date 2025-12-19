// main.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const KwikMedApp());
}

class KwikMedApp extends StatelessWidget {
  const KwikMedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0288D1),
      ),
      home: const HomeScreen(),
    );
  }
}
