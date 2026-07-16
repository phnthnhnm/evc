import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/interfaces/storage_service.dart';
import '../../core/result.dart';
import '../../domain/models/echo.dart';
import '../../domain/models/echo_set.dart';
import '../../domain/models/resonator.dart';

final class StorageServiceImpl implements IStorageService {
  List<Resonator>? _resonators;
  final String? customDirectory;

  StorageServiceImpl({this.customDirectory});

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
      final set = EchoSet.fromJson(original);

      // Stat sanitization: remove stats no longer valid for this resonator.
      Resonator? resonator;
      try {
        resonator = _resonators!.firstWhere((r) => r.id == resonatorId);
      } catch (_) {
        return Ok(set);
      }

      final allowedApiNames = resonator.usableStats
          .map((s) => s.apiName)
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
        return Ok(sanitizedSet);
      }

      return Ok(set);
    } catch (e) {
      return Err('Failed to load echo set for $resonatorId', cause: e);
    }
  }

  @override
  Future<Result<void>> saveEchoSet(String resonatorId, EchoSet echoSet) async {
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
  Future<Result<int>> migrateEchoSets(Map<String, String> migrations) async {
    if (migrations.isEmpty) return const Ok(0);
    try {
      final data = await _readData();
      var count = 0;
      for (final entry in migrations.entries) {
        if (data.containsKey(entry.key)) {
          data[entry.value] = data.remove(entry.key);
          count++;
        }
      }
      if (count > 0) {
        await _writeData(data);
      }
      return Ok(count);
    } catch (e) {
      return Err('Failed to migrate echo sets', cause: e);
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

  Future<File> _getJsonFile() async {
    final dirPath =
        customDirectory ?? (await getApplicationSupportDirectory()).path;
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('$dirPath/echo_sets.json');
  }

  List<String> loadRecentResonatorIdsSync() {
    try {
      final dirPath = customDirectory ?? _getAppSupportDirSync();
      final file = File('$dirPath/recent_resonators.json');
      if (!file.existsSync()) return [];
      final content = file.readAsStringSync();
      final list = jsonDecode(content) as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  String _getAppSupportDirSync() {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? 'C:\\';
      return '$appData\\com.example.evc';
    }
    return Directory.systemTemp.path;
  }

  Future<List<String>> loadRecentResonatorIds() async {
    try {
      final file = await _getRecentIdsFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentResonatorIds(List<String> ids) async {
    try {
      final file = await _getRecentIdsFile();
      final dir = Directory(file.parent.path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      await file.writeAsString(jsonEncode(ids));
    } catch (_) {}
  }

  Future<File> _getRecentIdsFile() async {
    final dirPath =
        customDirectory ?? (await getApplicationSupportDirectory()).path;
    return File('$dirPath/recent_resonators.json');
  }

  Future<Map<String, dynamic>> _readData() async {
    final file = await _getJsonFile();
    if (!await file.exists()) {
      return {};
    }

    final content = await file.readAsString();
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    final file = await _getJsonFile();
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(data));
  }
}
