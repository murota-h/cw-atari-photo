import 'package:flutter/material.dart';
import 'screens/title_screen.dart';

void main() {
  runApp(const PhotoRenamerApp());
}

class PhotoRenamerApp extends StatelessWidget {
  const PhotoRenamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW当たり確認',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D4FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TitleScreen(),
    );
  }
}