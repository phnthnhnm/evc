import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/resonator.dart';

class ResonatorService {
  static List<Resonator>? _cache;

  /// The loaded list of all resonators. Must call [load] first.
  static List<Resonator> get resonators => _cache!;

  /// Load resonator definitions from the bundled JSON asset.
  static Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/data/resonators.json');
    final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
    _cache = list.map((e) => Resonator.fromJson(e)).toList();
  }
}
