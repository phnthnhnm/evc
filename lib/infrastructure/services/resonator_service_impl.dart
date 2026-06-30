import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/interfaces/resonator_service.dart';
import '../../core/result.dart';
import '../../domain/models/resonator.dart';

final class ResonatorServiceImpl implements IResonatorService {
  List<Resonator>? _cache;

  ResonatorServiceImpl();

  @override
  List<Resonator> get resonators => _cache!;

  @override
  bool get isLoaded => _cache != null;

  @override
  Future<Result<void>> load() async {
    if (_cache != null) return const Ok(null);
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/resonators.json',
      );
      final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
      _cache = list.map((e) => Resonator.fromJson(e)).toList();
      return const Ok(null);
    } catch (e) {
      return Err('Failed to load resonator data', cause: e);
    }
  }
}
