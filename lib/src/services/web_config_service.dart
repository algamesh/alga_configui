import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class WebConfigService {
  static const _prefsKey = 'config_data';

  Future<Map<String, dynamic>> loadJson() async {
    final prefs = await SharedPreferences.getInstance();
    final storedString = prefs.getString(_prefsKey);

    if (storedString != null) {
      return jsonDecode(storedString) as Map<String, dynamic>;
    } else {
      final assetString = await rootBundle.loadString('assets/config.json');
      return jsonDecode(assetString) as Map<String, dynamic>;
    }
  }

  Future<void> saveJson(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(_prefsKey, jsonString);
  }

  Future<void> clearStoredConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
