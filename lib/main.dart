import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/router_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Router - 9Router Mobile UI Kit',
      debugShowCheckedModeBanner: false,
      theme: buildRouterTheme(),
      home: const SplashScreen(),
    );
  }
}
