import 'package:flutter/material.dart';
import 'package:flexidrive/presentation/pages/splash/splash_page.dart';

void main() {
  runApp(const FlexiDriveApp());
}

class FlexiDriveApp extends StatelessWidget {
  const FlexiDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexiDrive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B5BCD)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
