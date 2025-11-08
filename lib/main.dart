import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/seed_resonators.dart';
import 'data/stat.dart';
import 'models/resonator.dart';
import 'screens/resonator_list_screen.dart';
import 'utils/echo_set_provider.dart';
import 'utils/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      if (!mounted) return;
      
      // Precache all images in parallel for better performance
      final futures = <Future>[];
      
      // Add stat icons
      for (final stat in allStats) {
        futures.add(precacheImage(AssetImage(statAsset(stat)), context));
      }
      
      // Add resonator icons
      for (final resonator in seedResonators) {
        futures.add(precacheImage(AssetImage(resonator.iconAsset), context));
      }
      
      // Wait for all images to load in parallel
      await Future.wait(futures);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EchoSetProvider()),
      ],
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
