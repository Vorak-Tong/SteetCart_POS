import 'package:street_cart_pos/data/local/app_database.dart';

class ReportRepository {
  /// Calculates total revenue for the given date range.
  Future<double> getTotalRevenue(DateTime start, DateTime end) async {
    final db = await AppDatabase.instance();
    
    // SQLite stores dates as strings (ISO8601) usually.
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    // Assuming table 'orders' exists with 'total_amount' and 'created_at'
    final result = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM orders WHERE created_at BETWEEN ? AND ?',
      [startStr, endStr],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  /// Aggregates product sales to find top selling items and their revenue share.
  Future<List<Map<String, dynamic>>> getTopSellingProducts(DateTime start, DateTime end) async {
    final db = await AppDatabase.instance();
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    // 1. Get total revenue for the period to calculate percentages
    final totalRevenue = await getTotalRevenue(start, end);
    if (totalRevenue == 0) return [];

    // 2. Group sales by product
    // Assuming table 'order_items' with 'product_id', 'product_name', 'total_price'
    // and 'orders' table for the date filter.
    final result = await db.rawQuery('''
      SELECT 
        oi.product_name as name, 
        SUM(oi.total_price) as value,
        p.image_path as imagePath
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      LEFT JOIN products p ON oi.product_id = p.id
      WHERE o.created_at BETWEEN ? AND ?
      GROUP BY oi.product_id
      ORDER BY value DESC
    ''', [startStr, endStr]);

    // 3. Map to UI model with percentage calculation
    return result.map((row) {
      final value = (row['value'] as num).toDouble();
      final percentage = (value / totalRevenue * 100).round();
      
      return {
        'name': row['name'],
        'percentage': percentage,
        'imagePath': row['imagePath'],
      };
    }).toList();
  }
}