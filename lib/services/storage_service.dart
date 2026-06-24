import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/stat.dart';
import '../models/echo.dart';
import '../models/resonator.dart';

class StorageService {
  // Cache to avoid redundant file reads
  static Map<String, dynamic>? _cachedData;
  static DateTime? _lastCacheTime;
  static const _cacheValidityDuration = Duration(seconds: 5);

  static List<Resonator>? _resonators;

  /// Set the resonator definitions used for stat sanitization on load.
  static void setResonators(List<Resonator> resonators) {
    _resonators = resonators;
  }

  static Future<File> getJsonFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(supportDir.path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/echo_sets.json');
  }

  // Helper to read and cache file data
  static Future<Map<String, dynamic>> _readData() async {
    final now = DateTime.now();

    // Return cached data if still valid
    if (_cachedData != null &&
        _lastCacheTime != null &&
        now.difference(_lastCacheTime!) < _cacheValidityDuration) {
      return _cachedData!;
    }

    final file = await getJsonFile();
    if (!await file.exists()) {
      _cachedData = {};
      _lastCacheTime = now;
      return _cachedData!;
    }

    final content = await file.readAsString();
    try {
      _cachedData = jsonDecode(content) as Map<String, dynamic>;
      // Migration: detect legacy or backend-style entries and normalize them.
      // - Convert 'ssr' arrays into canonical 'echoes' format.
      // - Migrate 'energyBuff' -> 'team' when appropriate.
      // - Accept 'totEr' as fallback for 'totalER'.
      final ssrOrder = [
        Stat.critRate,
        Stat.critDamage,
        Stat.atkPercent,
        Stat.flatAtk,
        Stat.hpPercent,
        Stat.flatHp,
        Stat.defPercent,
        Stat.flatDef,
        Stat.basicPercent,
        Stat.heavyPercent,
        Stat.skillPercent,
        Stat.liberationPercent,
        Stat.erPercent,
      ];

      var migrationNeeded = false;
      for (final key in _cachedData!.keys.toList()) {
        final entry = _cachedData![key];
        if (entry is Map<String, dynamic>) {
          final mapCopy = Map<String, dynamic>.from(entry);

          // If backend-style 'ssr' exists and 'echoes' missing, convert it.
          if (mapCopy.containsKey('ssr') && !mapCopy.containsKey('echoes')) {
            final ssrRaw = mapCopy['ssr'] as List?;
            final converted = <Map<String, dynamic>>[];
            if (ssrRaw != null) {
              for (int i = 0; i < 5; i++) {
                final stats = <String, double>{};
                final row = i < ssrRaw.length ? ssrRaw[i] as List? : null;
                if (row != null) {
                  for (int j = 0; j < row.length && j < ssrOrder.length; j++) {
                    final raw = row[j];
                    double? val;
                    if (raw is String) {
                      val = double.tryParse(raw);
                    } else if (raw is num) {
                      val = raw.toDouble();
                    }
                    if (val != null && val != 0.0) {
                      final statName = statApiNames[ssrOrder[j]]!;
                      stats['$statName ${i + 1}'] = val;
                    }
                  }
                }
                converted.add({
                  'stats': stats,
                  'score': 0.0,
                  'tier': 'Unbuilt',
                });
              }
            }
            mapCopy['echoes'] = converted;
            // Migrate totEr/totalER
            if (mapCopy.containsKey('totEr') &&
                !mapCopy.containsKey('totalER')) {
              mapCopy['totalER'] = mapCopy['totEr'];
            }
            // Migrate energyBuff -> team if missing
            if (!mapCopy.containsKey('team') &&
                mapCopy.containsKey('energyBuff')) {
              mapCopy['team'] = mapCopy['energyBuff'];
            }
            _cachedData![key] = mapCopy;
            migrationNeeded = true;
          } else {
            // Ensure team exists when energyBuff was used previously
            if (!mapCopy.containsKey('team') &&
                mapCopy.containsKey('energyBuff')) {
              mapCopy['team'] = mapCopy['energyBuff'];
              _cachedData![key] = mapCopy;
              migrationNeeded = true;
            }
            // Ensure totalER exists when only totEr present
            if (!mapCopy.containsKey('totalER') &&
                mapCopy.containsKey('totEr')) {
              mapCopy['totalER'] = mapCopy['totEr'];
              _cachedData![key] = mapCopy;
              migrationNeeded = true;
            }
          }
        }
      }
      if (migrationNeeded) {
        // Persist migrated data back to disk
        await _writeData(_cachedData!);
      }
    } catch (e) {
      // Backup corrupt file and start with empty data to avoid crashes.
      final backup = File(
        '${file.path}.corrupt_${DateTime.now().millisecondsSinceEpoch}.bak',
      );
      await backup.writeAsString(content);
      _cachedData = {};
      _lastCacheTime = now;
      return _cachedData!;
    }
    _lastCacheTime = now;
    return _cachedData!;
  }

  // Helper to write data and invalidate cache
  static Future<void> _writeData(Map<String, dynamic> data) async {
    final file = await getJsonFile();
    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(data));
    _cachedData = data;
    _lastCacheTime = DateTime.now();
  }

  // Clear cache to force reload
  static void clearCache() {
    _cachedData = null;
    _lastCacheTime = null;
  }

  static Future<void> saveEchoSet(String resonatorId, EchoSet echoSet) async {
    final data = await _readData();
    final allSets = data.map((k, v) => MapEntry(k, EchoSet.fromJson(v)));
    allSets[resonatorId] = echoSet;
    final map = allSets.map((k, v) => MapEntry(k, v.toJson()));
    await _writeData(map);
  }

  static Future<EchoSet?> loadEchoSet(String resonatorId) async {
    final data = await _readData();
    if (!data.containsKey(resonatorId)) return null;

    final original = data[resonatorId] as Map<String, dynamic>;
    final set = EchoSet.fromJson(original);

    // Find resonator to know which stats are currently allowed.
    Resonator? resonator;
    try {
      resonator = _resonators!.firstWhere((r) => r.id == resonatorId);
    } catch (_) {
      return set;
    }

    final allowedApiNames = resonator.usableStats
        .map((s) => statApiNames[s]!)
        .toSet();

    var changed = false;
    final sanitizedEchoes = set.echoes.map((echo) {
      final newStats = Map<String, double>.from(echo.stats);
      final keysToRemove = <String>[];
      for (final key in newStats.keys) {
        final base = key.replaceAll(RegExp(r' \d+$'), '');
        if (!allowedApiNames.contains(base)) {
          keysToRemove.add(key);
        }
      }
      if (keysToRemove.isNotEmpty) {
        for (final k in keysToRemove) {
          newStats.remove(k);
        }
        changed = true;
      }
      return Echo(stats: newStats, score: echo.score, tier: echo.tier);
    }).toList();

    if (changed) {
      final sanitizedSet = set.copyWith(echoes: sanitizedEchoes);
      data[resonatorId] = sanitizedSet.toJson();
      await _writeData(data);
      return sanitizedSet;
    }

    return set;
  }

  static Future<void> deleteEchoSet(String resonatorId) async {
    final data = await _readData();
    if (data.containsKey(resonatorId)) {
      data.remove(resonatorId);
      await _writeData(data);
    }
  }

  static Future<String> backupAllData() async {
    // Clear cache to ensure we read fresh data from disk
    clearCache();
    final echoFile = await getJsonFile();
    Map<String, dynamic> echoSets = {};
    if (await echoFile.exists()) {
      final echoJson = await echoFile.readAsString();
      echoSets = jsonDecode(echoJson) as Map<String, dynamic>;
    }

    final prefs = await SharedPreferences.getInstance();
    final settings = <String, dynamic>{};
    final keys = prefs.getKeys();
    for (final key in keys) {
      final value = prefs.get(key);
      settings[key] = value;
    }

    final backupData = {'echo_sets': echoSets, 'settings': settings};
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(backupData);
  }

  static Future<void> restoreAllData(String inputJson) async {
    final backupData = jsonDecode(inputJson) as Map<String, dynamic>;
    // Restore echo_sets
    final echoFile = await getJsonFile();
    final encoder = JsonEncoder.withIndent('  ');
    await echoFile.writeAsString(
      encoder.convert(backupData['echo_sets'] ?? {}),
    );
    // Clear cache after restore
    clearCache();

    if (backupData['settings'] != null) {
      final prefs = await SharedPreferences.getInstance();
      final settings = backupData['settings'] as Map<String, dynamic>;
      for (final entry in settings.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List) {
          if (value.isEmpty || value.every((e) => e is String)) {
            await prefs.setStringList(key, List<String>.from(value));
          }
        }
      }
    }
  }

  static Future<void> resetAllData() async {
    final echoFile = await getJsonFile();
    await echoFile.writeAsString('{}');
    // Clear cache after reset
    clearCache();

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
