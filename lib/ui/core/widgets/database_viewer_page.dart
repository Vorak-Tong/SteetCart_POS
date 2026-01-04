import 'package:flutter/material.dart';
import 'package:street_cart_pos/data/local/app_database.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  List<String> _tables = [];
  String? _selectedTable;
  List<Map<String, Object?>> _rows = [];
  List<String> _columns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    final db = await AppDatabase.instance();
    // Query sqlite_master to find all user tables (excluding system tables)
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
    );

    if (!mounted) return;

    setState(() {
      _tables = result.map((row) => row['name'] as String).toList();
      _isLoading = false;
      if (_tables.isNotEmpty) {
        _selectedTable = _tables.first;
        _loadTableData(_selectedTable!);
      }
    });
  }

  Future<void> _loadTableData(String tableName) async {
    setState(() => _isLoading = true);
    final db = await AppDatabase.instance();
    final result = await db.query(tableName);

    if (!mounted) return;

    setState(() {
      _selectedTable = tableName;
      _rows = result;
      _isLoading = false;
      if (_rows.isNotEmpty) {
        _columns = _rows.first.keys.toList();
      } else {
        _columns = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Viewer')),
      body: Column(
        children: [
          if (_isLoading && _tables.isEmpty)
            const LinearProgressIndicator()
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Table: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedTable,
                    hint: const Text('Select Table'),
                    items: _tables.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) _loadTableData(val);
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      if (_selectedTable != null) _loadTableData(_selectedTable!);
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                    ? const Center(child: Text('No data in this table'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: _columns.map((c) => DataColumn(label: Text(c))).toList(),
                            rows: _rows.map((row) {
                              return DataRow(
                                cells: _columns.map((c) {
                                  return DataCell(Text(row[c]?.toString() ?? 'null'));
                                }).toList(),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}