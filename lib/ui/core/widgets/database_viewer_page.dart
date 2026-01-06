import 'package:flutter/material.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/data/local/seed/demo_business_seed.dart';
import 'package:street_cart_pos/data/repositories/menu_repository.dart';

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

  Future<void> _seedDemoData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seed demo data?'),
          content: const Text(
            'This will reset the local database and seed menu + 50 days of served orders for reporting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Seed'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await DemoBusinessSeed.seedLast50Days(resetDatabase: true);
      // The UI reads menu data from the in-memory MenuRepository cache, so we
      // must refresh it after reseeding/resetting the DB.
      await MenuRepository().refresh();
      await _loadTables();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seeded demo data (menu + 50 days of served orders). Re-open Report if it was already open.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to seed demo data: $e')));
      setState(() => _isLoading = false);
    }
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
                    items: _tables
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) _loadTableData(val);
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _seedDemoData,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Seed 50 days'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      if (_selectedTable != null) {
                        _loadTableData(_selectedTable!);
                      }
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
                        columns: _columns
                            .map((c) => DataColumn(label: Text(c)))
                            .toList(),
                        rows: _rows.map((row) {
                          return DataRow(
                            cells: _columns.map((c) {
                              return DataCell(
                                Text(row[c]?.toString() ?? 'null'),
                              );
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
