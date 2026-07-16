// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';

import 'package:evc/core/providers/navigation_history_provider.dart';
import 'package:evc/core/providers/notification_provider.dart';
import 'package:evc/core/providers/service_providers.dart';
import 'package:evc/core/providers/shared_preferences_provider.dart';
import 'package:evc/core/result.dart';
import 'package:evc/core/router.dart';
import 'package:evc/domain/enums/stat.dart';
import 'package:evc/features/command_palette/providers/command_palette_provider.dart';
import 'package:evc/features/command_palette/widgets/command_palette_dialog.dart'
    show CommandPaletteLayer;
import 'package:evc/infrastructure/services/resonator_service_impl.dart';
import 'package:evc/infrastructure/services/storage_service_impl.dart';
import 'package:evc/presentation/widgets/mouse_navigation_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In debug mode, isolate echo_sets.json and recent_resonators.json in a
  // temp directory so debug sessions don't affect release data.
  // SharedPreferences uses in-memory mock values to keep settings isolated.
  String? storageDir;
  if (kDebugMode) {
    SharedPreferences.setMockInitialValues({});

    final prodDir = await getApplicationSupportDirectory();
    final prodFile = File('${prodDir.path}/echo_sets.json');
    final tempDir = await getTemporaryDirectory();
    final sessionDir = Directory('${tempDir.path}/evc_debug');

    if (await sessionDir.exists()) {
      await sessionDir.delete(recursive: true);
    }
    await sessionDir.create(recursive: true);
    if (await prodFile.exists()) {
      await prodFile.copy('${sessionDir.path}/echo_sets.json');
    }
    storageDir = sessionDir.path;
  }

  // Pre-initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Load resonator definitions
  final resonatorSvc = ResonatorServiceImpl();
  await resonatorSvc.load();

  final resonators = resonatorSvc.resonators;
  final storageSvc = StorageServiceImpl(customDirectory: storageDir);
  storageSvc.setResonators(resonators);

  // Migrate saved echo sets whose resonator IDs changed in this release.
  _migrateEchoSets(storageSvc);

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

Future<void> _migrateEchoSets(StorageServiceImpl storage) async {
  try {
    final json = await rootBundle.loadString(
      'assets/data/resonator_id_migrations.json',
    );
    final map = jsonDecode(json) as Map<String, dynamic>;
    final migrations = Map<String, String>.from(map);

    final result = await storage.migrateEchoSets(migrations);
    switch (result) {
      case Ok(value: final count) when count > 0:
        debugPrint(
          '[migrate] Renamed $count saved echo set(s) '
          'to match updated resonator IDs.',
        );
      case Ok():
        break; // nothing to migrate
      case Err(message: final msg):
        debugPrint('[migrate] Migration skipped: $msg');
    }
  } catch (_) {
    // Asset not found or malformed — nothing to migrate.
  }
}

class EchoValueCalcApp extends ConsumerStatefulWidget {
  const EchoValueCalcApp({super.key});

  @override
  ConsumerState<EchoValueCalcApp> createState() => _EchoValueCalcAppState();
}

class _EchoValueCalcAppState extends ConsumerState<EchoValueCalcApp> {
  void Function()? _routerListener;

  @override
  void initState() {
    super.initState();

    // Seed navigation history with the initial route.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final initialRoute = router.state.uri.toString();
      ref.read(navigationHistoryProvider.notifier).recordRoute(initialRoute);
    });

    // Listen for all GoRouter route changes and record them in the
    // browser-style linear navigation history. The delegate notifies
    // synchronously during the build phase, so we defer the Riverpod
    // state modification to after the frame.
    _routerListener = () {
      if (!mounted) return;
      final route = router.state.uri.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(navigationHistoryProvider.notifier).recordRoute(route);

          // Track resonator navigation for the command palette MRU list.
          final uri = Uri.parse(route);
          final segments = uri.pathSegments;
          if (segments.length >= 2 && segments[0] == 'resonator') {
            ref
                .read(commandPaletteProvider.notifier)
                .recordNavigation(segments[1]);
          }
        }
      });
    };
    router.routerDelegate.addListener(_routerListener!);

    // Precache all images in parallel.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final futures = <Future>[];

      for (final stat in Stat.all) {
        futures.add(precacheImage(AssetImage(stat.assetPath), context));
      }

      final resonators = ref.read(resonatorServiceProvider).resonators;
      for (final resonator in resonators) {
        futures.add(precacheImage(AssetImage(resonator.iconAsset), context));
      }

      await Future.wait(futures);
    });
  }

  @override
  void dispose() {
    if (_routerListener != null) {
      router.routerDelegate.removeListener(_routerListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capture the notifier for use inside the builder callback where Riverpod
    // ref is not directly available.
    final navNotifier = ref.read(navigationHistoryProvider.notifier);
    final paletteNotifier = ref.read(commandPaletteProvider.notifier);

    return MaterialApp.router(
      title: 'Echo Value Calculator GUI',
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
      builder: (context, child) => CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.escape): () {
            if (paletteNotifier.isOpen) {
              paletteNotifier.close();
              return;
            }
            final target = navNotifier.prepareBack();
            if (target != null) {
              router.go(target);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navNotifier.onNavigationComplete();
              });
            }
          },
          LogicalKeySet(LogicalKeyboardKey.f1): () {
            paletteNotifier.toggle();
          },
        },
        child: CommandPaletteLayer(
          child: MouseNavigationListener(
            router: router,
            child: ToastLayer(child: child!),
          ),
        ),
      ),
    );
  }
}
