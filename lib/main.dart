import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:evc/core/providers/service_providers.dart';
import 'package:evc/core/providers/shared_preferences_provider.dart';
import 'package:evc/core/router.dart';
import 'package:evc/domain/enums/stat.dart';
import 'package:evc/infrastructure/services/resonator_service_impl.dart';
import 'package:evc/infrastructure/services/storage_service_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Load resonator definitions
  final resonatorSvc = ResonatorServiceImpl();
  await resonatorSvc.load();

  final resonators = resonatorSvc.resonators;
  final storageSvc = StorageServiceImpl();
  storageSvc.setResonators(resonators);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        resonatorServiceProvider.overrideWithValue(resonatorSvc),
        storageServiceProvider.overrideWithValue(storageSvc),
      ],
      child: const EchoValueCalcApp(),
    ),
  );
}

class EchoValueCalcApp extends ConsumerStatefulWidget {
  const EchoValueCalcApp({super.key});

  @override
  ConsumerState<EchoValueCalcApp> createState() => _EchoValueCalcAppState();
}

class _EchoValueCalcAppState extends ConsumerState<EchoValueCalcApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Precache all images in parallel
      final futures = <Future>[];

      for (final stat in Stat.all) {
        futures.add(precacheImage(AssetImage(stat.assetPath), context));
      }

      final resonators = ref.read(resonatorServiceProvider).resonators;
      for (final resonator in resonators) {
        futures.add(
            precacheImage(AssetImage(resonator.iconAsset), context));
      }

      await Future.wait(futures);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Echo Value Calculator GUI',
      // Dark theme only — no theme switching
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
