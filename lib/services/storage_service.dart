import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/echo.dart';

class StorageService {
  static const String keyPrefix = 'char_echo_set_';

  static Future<void> saveEchoSet(String characterId, EchoSet echoSet) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(echoSet.toJson());
    await prefs.setString('$keyPrefix$characterId', jsonStr);
  }

  static Future<EchoSet?> loadEchoSet(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$keyPrefix$characterId');
    if (jsonStr == null) return null;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return EchoSet.fromJson(data);
  }
}
