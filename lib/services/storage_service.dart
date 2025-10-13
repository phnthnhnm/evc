import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/echo.dart';

class StorageService {
  static Future<void> saveEchoSet(String resonatorId, EchoSet echoSet) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(echoSet.toJson());
    await prefs.setString(resonatorId, jsonStr);
  }

  static Future<EchoSet?> loadEchoSet(String resonatorId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(resonatorId);
    if (jsonStr == null) return null;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return EchoSet.fromJson(data);
  }
}
