import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
}
