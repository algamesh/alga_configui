import 'package:flutter/material.dart';
import 'package:dart_datakit/dart_datakit.dart';

class ConfigPage extends StatefulWidget {
  /// Optionally provide a [Datacat] object for a single table.
  final Datacat? datacat;

  /// Optionally provide a [Datakitties] instance for multiple tables.
  final Datakitties? datakitties;

  const ConfigPage({super.key, this.datacat, this.datakitties});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  // Stores all tables (except metadata) as Datacat instances.
  Map<String, Datacat>? _allData;
  List<String> _tableNames = [];
  String? _selectedTable;

  // Optionally store metadata (if present) as a Datacat.
  Datacat? _metadata;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.datakitties != null) {
      // Use the provided Datakitties.
      final tables = Map<String, Datacat>.from(widget.datakitties!.catalogues);
      if (tables.containsKey("metadata")) {
        _metadata = tables["metadata"];
        tables.remove("metadata");
      }
      _allData = tables;
      _tableNames = tables.keys.toList();
      if (_tableNames.isNotEmpty) {
        _selectedTable = _tableNames.first;
      }
      _isLoading = false;
    } else if (widget.datacat != null) {
      // Fallback to a single table.
      _allData = {'default': widget.datacat!};
      _tableNames = ['default'];
      _selectedTable = 'default';
      _isLoading = false;
    } else {
      // No external data provided; create a placeholder using Datakitties.
      _allData = _createPlaceholder();
      _tableNames = _allData!.keys.toList();
      if (_tableNames.isNotEmpty) {
        _selectedTable = _tableNames.first;
      }
      _isLoading = false;
    }
  }

  /// Creates a placeholder Datakitties instance from inline JSON,
  /// extracts metadata (if any) and returns the remaining tables.
  Map<String, Datacat> _createPlaceholder() {
    const placeholderJson = '''
{
  "metadata": [
    { "table": "Users", "description": "User information", "columns": "id,name,role" },
    { "table": "Products", "description": "Product listings", "columns": "product_id,product_name,price" }
  ],
  "Users": [
    { "id": 1, "name": "Alice", "role": "Administrator" },
    { "id": 2, "name": "Bob", "role": "Editor" },
    { "id": 3, "name": "Charlie", "role": "Viewer" }
  ],
  "Products": [
    { "product_id": 101, "product_name": "Widget", "price": 9.99 },
    { "product_id": 102, "product_name": "Gadget", "price": 12.99 },
    { "product_id": 103, "product_name": "Thingamajig", "price": 14.99 }
  ]
}
    ''';
    final datakitties = Datakitties.fromJsonMapString(placeholderJson);
    final tables = Map<String, Datacat>.from(datakitties.catalogues);
    if (tables.containsKey("metadata")) {
      _metadata = tables["metadata"];
      tables.remove("metadata");
    }
    return tables;
  }

  Future<void> _saveConfig() async {
    // For now, we'll simulate a save operation.
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isSaving = false);
    // Optionally, display a confirmation message.
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
          _buildMetadataSection(),
          _buildTableSelector(),
          Expanded(child: _buildDataTable()),
        ],
      ),
    );
  }

  /// Display metadata if available.
  Widget _buildMetadataSection() {
    if (_metadata == null) return Container();
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metadata',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          // Display each metadata row as a comma-separated string.
          ..._metadata!.rows.map((row) {
            return Text(row.join(", "));
          }).toList(),
        ],
      ),
    );
  }

  /// Build dropdown to select a table.
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

  /// Build the DataTable for the selected Datacat.
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
