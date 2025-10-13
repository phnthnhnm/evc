import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/echo.dart';

class StorageService {
  static Future<void> saveEchoSet(String characterId, EchoSet echoSet) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(echoSet.toJson());
    await prefs.setString(characterId, jsonStr);
  }

  static Future<EchoSet?> loadEchoSet(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(characterId);
    if (jsonStr == null) return null;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return EchoSet.fromJson(data);
  }
}
