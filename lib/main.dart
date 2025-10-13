import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/resonator_list_screen.dart';
import 'utils/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runApp(const EchoValueCalcApp());
}

class EchoValueCalcApp extends StatefulWidget {
  const EchoValueCalcApp({super.key});

  @override
  State<EchoValueCalcApp> createState() => _EchoValueCalcAppState();
}

class _EchoValueCalcAppState extends State<EchoValueCalcApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      WindowOptions windowOptions = const WindowOptions(center: true);
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.maximize();
        await windowManager.show();
        await windowManager.focus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Echo Value Calculator GUI',
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
            home: const ResonatorListScreen(),
          );
        },
      ),
    );
  }
}
