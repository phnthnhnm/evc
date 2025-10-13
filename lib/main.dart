import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/character_list_screen.dart';
import 'utils/theme_provider.dart';

void main() {
  runApp(const EchoValueCalcApp());
}

class EchoValueCalcApp extends StatelessWidget {
  const EchoValueCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'EVC GUI',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            themeMode: themeProvider.themeMode,
            home: const CharacterListScreen(),
          );
        },
      ),
    );
  }
}
