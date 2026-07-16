import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import 'package:evc/core/interfaces/api_service.dart';
import 'package:evc/core/interfaces/resonator_service.dart';
import 'package:evc/core/interfaces/storage_service.dart';
import 'package:evc/core/providers/service_providers.dart';
import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/enums/weapon_attribute.dart';
import 'package:evc/domain/models/echo.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/domain/models/resonator.dart';

// ---------------------------------------------------------------------------
// Mocktail mocks
// ---------------------------------------------------------------------------

class MockApiService extends Mock implements IApiService {}

class MockStorageService extends Mock implements IStorageService {}

class MockResonatorService extends Mock implements IResonatorService {}

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

/// Creates a mock resonator for testing.
Resonator mockResonator({
  String id = 'test-resonator',
  String name = 'Test Resonator',
  int stars = 5,
  Attribute attribute = Attribute.fusion,
  Weapon weapon = Weapon.sword,
  List<String> teams = const [],
}) {
  return Resonator(
    id: id,
    name: name,
    stars: stars,
    attribute: attribute,
    weapon: weapon,
    iconAsset: 'assets/resonator_icons/test.webp',
    portraitAsset: 'assets/resonator_portraits/test.webp',
    usableStats: Stat.all,
    teams: teams,
  );
}

/// Like [mockResonator] but allows injecting [teamER] data.
Resonator mockResonatorWithTeamER({
  String id = 'test-resonator',
  String name = 'Test Resonator',
  int stars = 5,
  Attribute attribute = Attribute.fusion,
  Weapon weapon = Weapon.sword,
  List<String> teams = const [],
  Map<String, dynamic>? teamER,
}) {
  return Resonator(
    id: id,
    name: name,
    stars: stars,
    attribute: attribute,
    weapon: weapon,
    iconAsset: 'assets/resonator_icons/test.webp',
    portraitAsset: 'assets/resonator_portraits/test.webp',
    usableStats: Stat.all,
    teams: teams,
    teamER: teamER,
  );
}

/// Creates a mock [Echo] for testing.
Echo mockEcho({
  Map<String, double> stats = const {},
  double score = 0.0,
  String tier = 'Unbuilt',
}) {
  return Echo(stats: stats, score: score, tier: tier);
}

/// Creates a mock [EchoSet] for testing.
EchoSet mockEchoSet({
  List<Echo> echoes = const [],
  double overallScore = 0.0,
  String overallTier = 'Unbuilt',
  double totalER = 100.0,
  String? team,
}) {
  return EchoSet(
    echoes: echoes,
    overallScore: overallScore,
    overallTier: overallTier,
    totalER: totalER,
    team: team,
  );
}

// ---------------------------------------------------------------------------
// Provider container helper
// ---------------------------------------------------------------------------

/// Creates a [ProviderContainer] with mocked service interfaces.
///
/// If a mock is not provided, a default [Mock*] instance is created
/// automatically.
ProviderContainer createTestContainer({
  MockResonatorService? resonatorService,
  MockApiService? apiService,
  MockStorageService? storageService,
}) {
  final rs = resonatorService ?? MockResonatorService();
  final api = apiService ?? MockApiService();
  final storage = storageService ?? MockStorageService();

  return ProviderContainer(
    overrides: [
      resonatorServiceInterfaceProvider.overrideWith((ref) => rs),
      apiServiceInterfaceProvider.overrideWith((ref) => api),
      storageServiceInterfaceProvider.overrideWith((ref) => storage),
    ],
  );
}
