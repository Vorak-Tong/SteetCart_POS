import 'package:flutter_test/flutter_test.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setupDatabaseTests();

  test('AppDatabase singleton returns same instance', () async {
    final db1 = await AppDatabase.instance();
    final db2 = await AppDatabase.instance();
    expect(db1, equals(db2));
  });
}
