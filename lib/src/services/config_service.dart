import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ConfigService {
  static const _assetFilePath = 'assets/config.json';
  static const _localFileName = 'config.json';

  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Future<File> _ensureLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final localFile = File('${directory.path}/$_localFileName');

    if (!await localFile.exists()) {
      final jsonString = await rootBundle.loadString(_assetFilePath);
      await localFile.writeAsString(jsonString);
    }
    return localFile;
  }

  Future<Map<String, dynamic>> loadJson() async {
    final file = await _ensureLocalFile();
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> saveJson(Map<String, dynamic> data) async {
    final file = await _ensureLocalFile();
    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString, flush: true);
  }
}
