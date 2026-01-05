import 'package:street_cart_pos/data/local/app_database.dart';

class ReportRepository {
  static const _servedStatus = 'served';
  static const _finalizedStatus = 'finalized';

  /// Calculates total revenue for the given date range.
  Future<double> getTotalRevenue(DateTime start, DateTime end) async {
    final db = await AppDatabase.instance();

    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT SUM(COALESCE(oi.unit_price, 0) * oi.quantity) as total
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      WHERE o.cart_status = ? AND o.order_status = ? AND o.timestamp BETWEEN ? AND ?
      ''',
      [_finalizedStatus, _servedStatus, startMs, endMs],
    );

    final total = result.isEmpty ? null : result.first['total'];
    return total == null ? 0.0 : (total as num).toDouble();
  }

  /// Aggregates product sales to find top selling items and their revenue share.
  /// Returns: `name`, `percentage` (revenue share), `unitsSold`, `imagePath`.
  ///
  /// Note: `imagePath` prefers the *current* product image from `products.image`
  /// (so menu updates are reflected in reports), and falls back to the snapshot
  /// stored on `order_items.product_image`.
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    DateTime start,
    DateTime end,
  ) async {
    final db = await AppDatabase.instance();
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    // 1. Get total revenue for the period to calculate percentages
    final totalRevenue = await getTotalRevenue(start, end);
    if (totalRevenue == 0) return [];

    // 2. Group sales by product
    final result = await db.rawQuery(
      '''
      SELECT 
        oi.product_id as productId,
        oi.product_name as name, 
        SUM(COALESCE(oi.unit_price, 0) * oi.quantity) as revenue,
        SUM(oi.quantity) as unitsSold,
        COALESCE(MAX(p.image), MAX(oi.product_image)) as imagePath
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      LEFT JOIN products p ON p.id = oi.product_id
      WHERE o.cart_status = ? AND o.order_status = ? AND o.timestamp BETWEEN ? AND ?
      GROUP BY oi.product_id, oi.product_name
      ORDER BY revenue DESC
    ''',
      [_finalizedStatus, _servedStatus, startMs, endMs],
    );

    // 3. Map to UI model with percentage calculation
    return result.map((row) {
      final revenue = (row['revenue'] as num? ?? 0).toDouble();
      final percentage = (revenue / totalRevenue * 100).round();

      return {
        'name': row['name'],
        'percentage': percentage,
        'unitsSold': (row['unitsSold'] as num?)?.toInt(),
        'imagePath': row['imagePath'],
      };
    }).toList();
  }

  /// Gets the total number of orders in the date range.
  Future<int> getTotalOrders(DateTime start, DateTime end) async {
    final db = await AppDatabase.instance();
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM orders
      WHERE cart_status = ? AND order_status = ? AND timestamp BETWEEN ? AND ?
      ''',
      [_finalizedStatus, _servedStatus, startMs, endMs],
    );

    if (result.isNotEmpty && result.first['count'] != null) {
      return (result.first['count'] as num).toInt();
    }
    return 0;
  }

  /// Gets the total quantity of items sold in the date range.
  Future<int> getTotalItemsSold(DateTime start, DateTime end) async {
    final db = await AppDatabase.instance();
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT SUM(oi.quantity) as count 
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      WHERE o.cart_status = ? AND o.order_status = ? AND o.timestamp BETWEEN ? AND ?
    ''',
      [_finalizedStatus, _servedStatus, startMs, endMs],
    );

    if (result.isNotEmpty && result.first['count'] != null) {
      return (result.first['count'] as num).toInt();
    }
    return 0;
  }

  /// Gets the percentage distribution of order types (e.g., Dine-in vs Take-away).
  Future<Map<String, int>> getOrderTypePercentages(
    DateTime start,
    DateTime end,
  ) async {
    final db = await AppDatabase.instance();
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    try {
      final result = await db.rawQuery(
        '''
        SELECT order_type, COUNT(*) as count 
        FROM orders 
        WHERE cart_status = ? AND order_status = ? AND timestamp BETWEEN ? AND ?
        GROUP BY order_type
      ''',
        [_finalizedStatus, _servedStatus, startMs, endMs],
      );

      int total = 0;
      final counts = <String, int>{};

      for (var row in result) {
        final type = row['order_type'] as String? ?? 'Unknown';
        final count = (row['count'] as num).toInt();
        counts[type] = count;
        total += count;
      }

      if (total == 0) return {};

      return counts.map(
        (key, value) => MapEntry(key, (value / total * 100).round()),
      );
    } catch (e) {
      // Return empty if table/column doesn't exist yet
      return {};
    }
  }
}
