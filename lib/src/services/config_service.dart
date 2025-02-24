import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ConfigService {
  static const _localFileName = 'config.json';

  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_localFileName');
  }

  Future<Map<String, dynamic>> loadJson() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } else {
      // Return an empty map if no local configuration exists.
      return <String, dynamic>{};
    }
  }

  Future<void> saveJson(Map<String, dynamic> data) async {
    final file = await _getLocalFile();
    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString, flush: true);
  }
}
