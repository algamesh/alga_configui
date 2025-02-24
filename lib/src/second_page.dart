import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:alga_configui/src/services/web_config_service.dart';
import 'package:dart_datakit/dart_datakit.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final _configService = WebConfigService();

  // Now we store each table as a Datacat instance.
  Map<String, Datacat>? _allData;
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
      // Load the raw JSON from the config service.
      final rawData = await _configService.loadJson();
      // Convert each table (assumed to be a List of maps) into a Datacat.
      final Map<String, Datacat> datacatMap = {};
      rawData.forEach((tableName, tableData) {
        // tableData is expected to be a List of maps.
        final jsonStr = jsonEncode(tableData);
        datacatMap[tableName] = Datacat.fromJsonString(jsonStr);
      });
      setState(() {
        _allData = datacatMap;
        _tableNames = datacatMap.keys.toList();
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
      // Convert each Datacat back into a list of maps.
      final Map<String, dynamic> toSave = {};
      _allData!.forEach((tableName, datacat) {
        final List<Map<String, dynamic>> tableRows = [];
        for (final row in datacat.rows) {
          final Map<String, dynamic> rowMap = {};
          for (int i = 0; i < datacat.columns.length; i++) {
            rowMap[datacat.columns[i]] = i < row.length ? row[i] : null;
          }
          tableRows.add(rowMap);
        }
        toSave[tableName] = tableRows;
      });
      await _configService.saveJson(toSave);
    } catch (e) {
      debugPrint('Error saving config data: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Datacat? get _selectedTableData {
    if (_selectedTable == null || _allData == null) return null;
    return _allData![_selectedTable];
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
    final datacat = _selectedTableData;
    if (datacat == null) {
      return const Center(child: Text('No table selected.'));
    }
    final columns = datacat.columns;
    final rows = datacat.rows;

    if (rows.isEmpty) {
      return const Center(child: Text('No rows in this table.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: List<DataRow>.generate(rows.length, (rowIndex) {
          final row = rows[rowIndex];
          return DataRow(
            cells: List<DataCell>.generate(columns.length, (colIndex) {
              final cellValue = row[colIndex]?.toString() ?? '';
              return DataCell(
                Text(cellValue),
                showEditIcon: true,
                onTap: () async {
                  final newVal =
                      await _showEditDialog(columns[colIndex], cellValue);
                  if (newVal != null) {
                    setState(() {
                      row[colIndex] = _parseValue(newVal);
                    });
                  }
                },
              );
            }),
          );
        }),
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
