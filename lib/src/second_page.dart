import 'package:flutter/material.dart';
import 'package:alga_configuikit/src/services/web_config_service.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final _configService = WebConfigService();

  Map<String, dynamic>? _allData; // entire JSON
  List<String> _tableNames = [];
  String? _selectedTable;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    try {
      final data = await _configService.loadJson();
      setState(() {
        _allData = data;
        _tableNames = data.keys.toList();
      });
    } catch (e) {
      debugPrint('Error loading config data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    if (_allData == null) return;
    setState(() => _isSaving = true);
    try {
      await _configService.saveJson(_allData!);
    } catch (e) {
      debugPrint('Error saving config data: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  List<Map<String, dynamic>> get _selectedTableRows {
    if (_selectedTable == null || _allData == null) return [];
    final raw = _allData![_selectedTable];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  List<String> get _columnNames {
    final rows = _selectedTableRows;
    final allKeys = <String>{};
    for (var row in rows) {
      allKeys.addAll(row.keys);
    }
    return allKeys.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Tables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveConfig,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTableSelector(),
          Expanded(child: _buildDataTable()),
        ],
      ),
    );
  }

  Widget _buildTableSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _selectedTable,
        hint: const Text('Select a table'),
        items: _tableNames.map((tableName) {
          return DropdownMenuItem(
            value: tableName,
            child: Text(tableName),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTable = value;
          });
        },
      ),
    );
  }

  Widget _buildDataTable() {
    if (_selectedTable == null) {
      return const Center(child: Text('No table selected.'));
    }
    final columns = _columnNames;
    final rows = _selectedTableRows;

    if (rows.isEmpty) {
      return const Center(child: Text('No rows in this table.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: columns.map((col) {
              final cellValue = row[col]?.toString() ?? '';
              return DataCell(
                Text(cellValue),
                showEditIcon: true,
                onTap: () async {
                  final newVal = await _showEditDialog(col, cellValue);
                  if (newVal != null) {
                    setState(() {
                      row[col] = _parseValue(newVal);
                    });
                  }
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Future<String?> _showEditDialog(String colName, String initialValue) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit "$colName"'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  dynamic _parseValue(String val) {
    final intVal = int.tryParse(val);
    if (intVal != null) return intVal;

    final doubleVal = double.tryParse(val);
    if (doubleVal != null) return doubleVal;

    final lower = val.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;

    return val;
  }
}
