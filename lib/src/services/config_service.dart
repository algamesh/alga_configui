// lib/services/config_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ConfigService {
  static const _assetFilePath = 'assets/config.json';
  static const _localFileName = 'config.json'; // Name of the local copy

  // Singleton pattern (optional)
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  /// Ensure the local config file exists by copying from assets if needed.
  Future<File> _ensureLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final localFile = File('${directory.path}/$_localFileName');

    if (!await localFile.exists()) {
      final jsonString = await rootBundle.loadString(_assetFilePath);
      await localFile.writeAsString(jsonString);
    }
    return localFile;
  }

  /// Load the JSON from the local file.
  Future<Map<String, dynamic>> loadJson() async {
    final file = await _ensureLocalFile();
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Save a Map<String, dynamic> back to the local JSON file.
  Future<void> saveJson(Map<String, dynamic> data) async {
    final file = await _ensureLocalFile();
    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString, flush: true);
  }
}
