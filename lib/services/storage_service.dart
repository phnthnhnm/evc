import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/echo.dart';

class StorageService {
  static Future<File> getJsonFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(supportDir.path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/echo_sets.json');
  }

  static Future<void> saveEchoSet(String resonatorId, EchoSet echoSet) async {
    final file = await getJsonFile();
    Map<String, EchoSet> allSets = {};
    if (await file.exists()) {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      allSets = data.map((k, v) => MapEntry(k, EchoSet.fromJson(v)));
    }
    allSets[resonatorId] = echoSet;
    final map = allSets.map((k, v) => MapEntry(k, v.toJson()));
    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(map));
  }

  static Future<EchoSet?> loadEchoSet(String resonatorId) async {
    final file = await getJsonFile();
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    if (!data.containsKey(resonatorId)) return null;
    return EchoSet.fromJson(data[resonatorId]);
  }

  static Future<void> deleteEchoSet(String resonatorId) async {
    final file = await getJsonFile();
    if (!await file.exists()) return;
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    if (data.containsKey(resonatorId)) {
      data.remove(resonatorId);
      final encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(data));
    }
  }

  static Future<String> backupAllData() async {
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

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
