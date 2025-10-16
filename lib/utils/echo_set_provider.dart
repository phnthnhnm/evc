import 'package:flutter/material.dart';

import '../data/seed_resonators.dart';
import '../models/echo.dart';
import '../services/storage_service.dart';

class EchoSetProvider extends ChangeNotifier {
  final Map<String, EchoSet> _echoSets = {};
  bool _initialized = false;

  Map<String, EchoSet> get echoSets => _echoSets;
  bool get initialized => _initialized;

  Future<void> loadAll() async {
    final List<String> allResonatorIds = seedResonators
        .map((r) => r.id)
        .toList();
    final results = await Future.wait(
      allResonatorIds.map((id) async {
        final set = await StorageService.loadEchoSet(id);
        return MapEntry(id, set);
      }),
    );
    for (final entry in results) {
      if (entry.value != null) {
        _echoSets[entry.key] = entry.value!;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> loadEchoSet(String resonatorId) async {
    final set = await StorageService.loadEchoSet(resonatorId);
    if (set != null) {
      _echoSets[resonatorId] = set;
      notifyListeners();
    }
  }

  Future<void> saveEchoSet(String resonatorId, EchoSet echoSet) async {
    await StorageService.saveEchoSet(resonatorId, echoSet);
    _echoSets[resonatorId] = echoSet;
    notifyListeners();
  }

  void updateEchoSet(String resonatorId, EchoSet echoSet) {
    _echoSets[resonatorId] = echoSet;
    notifyListeners();
  }

  EchoSet? getEchoSet(String resonatorId) => _echoSets[resonatorId];

  Future<void> deleteEchoSet(String resonatorId) async {
    await StorageService.deleteEchoSet(resonatorId);
    _echoSets.remove(resonatorId);
    notifyListeners();
  }
}
