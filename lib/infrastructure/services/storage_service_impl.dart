import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/interfaces/storage_service.dart';
import '../../core/result.dart';
import '../../domain/enums/stat.dart';
import '../../domain/models/echo.dart';
import '../../domain/models/echo_set.dart';
import '../../domain/models/resonator.dart';

final class StorageServiceImpl implements IStorageService {
  List<Resonator>? _resonators;

  StorageServiceImpl();

  // ---------------------------------------------------------------------------
  // IStorageService
  // ---------------------------------------------------------------------------

  @override
  void setResonators(List<Resonator> resonators) {
    _resonators = resonators;
  }

  @override
  Future<Result<EchoSet?>> loadEchoSet(String resonatorId) async {
    try {
      final data = await _readData();
      if (!data.containsKey(resonatorId)) return const Ok(null);

      final original = data[resonatorId] as Map<String, dynamic>;
      final set = EchoSet.fromLegacyJson(original);

      // Stat sanitization: remove stats no longer valid for this resonator.
      Resonator? resonator;
      try {
        resonator = _resonators!.firstWhere((r) => r.id == resonatorId);
      } catch (_) {
        return Ok(set);
      }

      final allowedApiNames =
          resonator.usableStats.map((s) => s.apiName).toSet();

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
        return Echo(
          stats: newStats,
          score: echo.score,
          tier: echo.tier,
        );
      }).toList();

      if (changed) {
        final sanitizedSet = set.copyWith(echoes: sanitizedEchoes);
        data[resonatorId] = sanitizedSet.toJson();
        await _writeData(data);
        return Ok(sanitizedSet);
      }

      return Ok(set);
    } catch (e) {
      return Err('Failed to load echo set for $resonatorId', cause: e);
    }
  }

  @override
  Future<Result<void>> saveEchoSet(
    String resonatorId,
    EchoSet echoSet,
  ) async {
    try {
      final data = await _readData();
      final allSets = data.map((k, v) => MapEntry(k, EchoSet.fromJson(v)));
      allSets[resonatorId] = echoSet;
      final map = allSets.map((k, v) => MapEntry(k, v.toJson()));
      await _writeData(map);
      return const Ok(null);
    } catch (e) {
      return Err('Failed to save echo set for $resonatorId', cause: e);
    }
  }

  @override
  Future<Result<void>> deleteEchoSet(String resonatorId) async {
    try {
      final data = await _readData();
      if (data.containsKey(resonatorId)) {
        data.remove(resonatorId);
        await _writeData(data);
      }
      return const Ok(null);
    } catch (e) {
      return Err('Failed to delete echo set for $resonatorId', cause: e);
    }
  }

  @override
  Future<Result<String>> backupAllData() async {
    try {
      final echoFile = await _getJsonFile();
      Map<String, dynamic> echoSets = {};
      if (await echoFile.exists()) {
        final echoJson = await echoFile.readAsString();
        echoSets = jsonDecode(echoJson) as Map<String, dynamic>;
      }

      final prefs = await SharedPreferences.getInstance();
      final settings = <String, dynamic>{};
      for (final key in prefs.getKeys()) {
        final value = prefs.get(key);
        settings[key] = value;
      }

      final backupData = {'echo_sets': echoSets, 'settings': settings};
      final encoder = const JsonEncoder.withIndent('  ');
      return Ok(encoder.convert(backupData));
    } catch (e) {
      return Err('Failed to create backup', cause: e);
    }
  }

  @override
  Future<Result<void>> restoreAllData(String inputJson) async {
    try {
      final backupData = jsonDecode(inputJson) as Map<String, dynamic>;
      final echoFile = await _getJsonFile();
      final encoder = const JsonEncoder.withIndent('  ');
      await echoFile.writeAsString(
        encoder.convert(backupData['echo_sets'] ?? {}),
      );

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
      return const Ok(null);
    } catch (e) {
      return Err('Failed to restore data', cause: e);
    }
  }

  @override
  Future<Result<void>> resetAllData() async {
    try {
      final echoFile = await _getJsonFile();
      await echoFile.writeAsString('{}');

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        await prefs.remove(key);
      }
      return const Ok(null);
    } catch (e) {
      return Err('Failed to reset data', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // File helpers
  // ---------------------------------------------------------------------------

  Future<File> _getJsonFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(supportDir.path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/echo_sets.json');
  }

  Future<Map<String, dynamic>> _readData() async {
    final file = await _getJsonFile();
    if (!await file.exists()) {
      return {};
    }

    final content = await file.readAsString();
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Migration: detect legacy or backend-style entries and normalize them.
      const ssrOrder = [
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
      for (final key in data.keys.toList()) {
        final entry = data[key];
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
                  for (int j = 0;
                      j < row.length && j < ssrOrder.length;
                      j++) {
                    final raw = row[j];
                    double? val;
                    if (raw is String) {
                      val = double.tryParse(raw);
                    } else if (raw is num) {
                      val = raw.toDouble();
                    }
                    if (val != null && val != 0.0) {
                      final statName = ssrOrder[j].apiName;
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
            if (!mapCopy.containsKey('team') &&
                mapCopy.containsKey('energyBuff')) {
              mapCopy['team'] = mapCopy['energyBuff'];
            }
            data[key] = mapCopy;
            migrationNeeded = true;
          } else {
            if (!mapCopy.containsKey('team') &&
                mapCopy.containsKey('energyBuff')) {
              mapCopy['team'] = mapCopy['energyBuff'];
              data[key] = mapCopy;
              migrationNeeded = true;
            }
            if (!mapCopy.containsKey('totalER') &&
                mapCopy.containsKey('totEr')) {
              mapCopy['totalER'] = mapCopy['totEr'];
              data[key] = mapCopy;
              migrationNeeded = true;
            }
          }
        }
      }
      if (migrationNeeded) {
        await _writeData(data);
      }
      return data;
    } catch (e) {
      // Backup corrupt file and start with empty data to avoid crashes.
      final backup = File(
        '${file.path}.corrupt_${DateTime.now().millisecondsSinceEpoch}.bak',
      );
      await backup.writeAsString(content);
      return {};
    }
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    final file = await _getJsonFile();
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(data));
  }
}
