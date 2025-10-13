import 'package:flutter/material.dart';

import 'screens/character_list_screen.dart';

void main() {
  runApp(const EchoValueCalcApp());
}

class EchoValueCalcApp extends StatelessWidget {
  const EchoValueCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'EVC GUI',
      theme: theme,
      home: const CharacterListScreen(),
    );
  }
}
