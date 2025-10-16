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
    for (final id in allResonatorIds) {
      final set = await StorageService.loadEchoSet(id);
      if (set != null) {
        _echoSets[id] = set;
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
