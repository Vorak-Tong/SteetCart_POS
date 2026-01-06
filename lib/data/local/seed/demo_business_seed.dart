import 'dart:convert';
import 'dart:math' as math;

import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/data/local/dao/category_dao.dart';
import 'package:street_cart_pos/data/local/dao/modifier_dao.dart';
import 'package:street_cart_pos/data/local/dao/order_dao.dart';
import 'package:street_cart_pos/data/local/dao/order_item_dao.dart';
import 'package:street_cart_pos/data/local/dao/payment_dao.dart';
import 'package:street_cart_pos/data/local/dao/product_dao.dart';
import 'package:street_cart_pos/data/local/dao/product_modifier_group_dao.dart';
import 'package:street_cart_pos/domain/models/report_model.dart';
import 'package:uuid/uuid.dart';

class DemoBusinessSeed {
  static const _uuid = Uuid();

  static Future<void> seedLast50Days({bool resetDatabase = true}) async {
    if (resetDatabase) {
      await AppDatabase.reset();
    }

    final db = await AppDatabase.instance();

    // Deterministic seed so the dataset is stable across runs.
    final rng = math.Random(50);

    await db.transaction((txn) async {
      final batch = txn.batch();

      // -----------------------------------------------------------------------
      // Menu: categories
      // -----------------------------------------------------------------------
      final categories = <_SeedCategory>[
        _SeedCategory(id: _uuid.v4(), name: 'Tea'),
        _SeedCategory(id: _uuid.v4(), name: 'Coffee'),
        _SeedCategory(id: _uuid.v4(), name: 'Food'),
      ];

      for (final c in categories) {
        batch.insert(CategoryDao.tableName, {
          CategoryDao.colId: c.id,
          CategoryDao.colName: c.name,
          CategoryDao.colIsActive: 1,
        });
      }

      // -----------------------------------------------------------------------
      // Menu: modifier groups (global)
      // selection_type: 0=single, 1=multi
      // price_behavior: 0=fixed(price change), 1=none
      // -----------------------------------------------------------------------
      final sugarGroupId = _uuid.v4();
      batch.insert(ModifierDao.tableGroups, {
        ModifierDao.colGroupId: sugarGroupId,
        ModifierDao.colGroupName: 'Sugar Level',
        ModifierDao.colSelectionType: 0,
        ModifierDao.colPriceBehavior: 1,
        ModifierDao.colMinSelection: 0,
        ModifierDao.colMaxSelection: 1,
      });

      final sugarOptions = const [
        'No sugar',
        'Less sugar',
        'Normal sugar',
        'More sugar',
      ];
      for (final name in sugarOptions) {
        batch.insert(ModifierDao.tableOptions, {
          ModifierDao.colOptionId: _uuid.v4(),
          ModifierDao.colOptionName: name,
          ModifierDao.colOptionPrice: null,
          ModifierDao.colOptionIsDefault: name == 'Normal sugar' ? 1 : 0,
          ModifierDao.colOptionGroupId: sugarGroupId,
        });
      }

      final sizeGroupId = _uuid.v4();
      batch.insert(ModifierDao.tableGroups, {
        ModifierDao.colGroupId: sizeGroupId,
        ModifierDao.colGroupName: 'Size',
        ModifierDao.colSelectionType: 0,
        ModifierDao.colPriceBehavior: 0,
        ModifierDao.colMinSelection: 0,
        ModifierDao.colMaxSelection: 1,
      });

      final sizeOptions = <({String name, double price, bool isDefault})>[
        (name: 'Small', price: 0.0, isDefault: true),
        (name: 'Medium', price: 0.5, isDefault: false),
        (name: 'Large', price: 0.75, isDefault: false),
      ];
      for (final opt in sizeOptions) {
        batch.insert(ModifierDao.tableOptions, {
          ModifierDao.colOptionId: _uuid.v4(),
          ModifierDao.colOptionName: opt.name,
          ModifierDao.colOptionPrice: opt.price,
          ModifierDao.colOptionIsDefault: opt.isDefault ? 1 : 0,
          ModifierDao.colOptionGroupId: sizeGroupId,
        });
      }

      final toppingsGroupId = _uuid.v4();
      batch.insert(ModifierDao.tableGroups, {
        ModifierDao.colGroupId: toppingsGroupId,
        ModifierDao.colGroupName: 'Toppings',
        ModifierDao.colSelectionType: 1,
        ModifierDao.colPriceBehavior: 0,
        ModifierDao.colMinSelection: 0,
        ModifierDao.colMaxSelection: 3,
      });

      final toppingOptions = <({String name, double price})>[
        (name: 'Pearls', price: 0.5),
        (name: 'Pudding', price: 0.75),
        (name: 'Grass jelly', price: 0.5),
        (name: 'Cheese foam', price: 1.0),
      ];
      for (final opt in toppingOptions) {
        batch.insert(ModifierDao.tableOptions, {
          ModifierDao.colOptionId: _uuid.v4(),
          ModifierDao.colOptionName: opt.name,
          ModifierDao.colOptionPrice: opt.price,
          ModifierDao.colOptionIsDefault: 0,
          ModifierDao.colOptionGroupId: toppingsGroupId,
        });
      }

      // -----------------------------------------------------------------------
      // Menu: products + product_modifier_groups
      // -----------------------------------------------------------------------
      final teaId = categories.firstWhere((c) => c.name == 'Tea').id;
      final coffeeId = categories.firstWhere((c) => c.name == 'Coffee').id;
      final foodId = categories.firstWhere((c) => c.name == 'Food').id;

      final products = <_SeedProduct>[
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Iced Latte',
          description: 'Classic iced latte',
          basePrice: 2.0,
          categoryId: coffeeId,
          modifierGroupIds: const [],
        ),
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Iced Matcha Latte',
          description: 'Matcha latte served cold',
          basePrice: 2.5,
          categoryId: teaId,
          modifierGroupIds: [sugarGroupId, sizeGroupId],
        ),
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Iced Tea',
          description: 'Refreshing iced tea',
          basePrice: 1.5,
          categoryId: teaId,
          modifierGroupIds: [sugarGroupId, sizeGroupId, toppingsGroupId],
        ),
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Hot Coffee',
          description: 'Freshly brewed hot coffee',
          basePrice: 1.75,
          categoryId: coffeeId,
          modifierGroupIds: const [],
        ),
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Americano',
          description: 'Espresso with hot water',
          basePrice: 2.25,
          categoryId: coffeeId,
          modifierGroupIds: [sizeGroupId],
        ),
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Fries',
          description: 'Crispy fries',
          basePrice: 1.25,
          categoryId: foodId,
          modifierGroupIds: [sizeGroupId],
        ),
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Chicken Over Rice',
          description: 'Chicken served over rice',
          basePrice: 4.5,
          categoryId: foodId,
          modifierGroupIds: const [],
        ),
        _SeedProduct(
          id: _uuid.v4(),
          name: 'Soda Can',
          description: 'Chilled soda can',
          basePrice: 1.0,
          categoryId: foodId,
          modifierGroupIds: const [],
        ),
      ];

      for (final p in products) {
        batch.insert(ProductDao.tableName, {
          ProductDao.colId: p.id,
          ProductDao.colName: p.name,
          ProductDao.colDescription: p.description,
          ProductDao.colBasePrice: p.basePrice,
          ProductDao.colImage: null,
          ProductDao.colIsActive: 1,
          ProductDao.colCategoryId: p.categoryId,
        });

        for (final groupId in p.modifierGroupIds) {
          batch.insert(ProductModifierGroupDao.tableName, {
            ProductModifierGroupDao.colProductId: p.id,
            ProductModifierGroupDao.colGroupId: groupId,
          });
        }
      }

      // -----------------------------------------------------------------------
      // Orders: 50 days worth of served orders (report uses served only)
      // -----------------------------------------------------------------------
      final now = Report.clampDate(DateTime.now());
      final startDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 49));

      for (int dayOffset = 0; dayOffset < 50; dayOffset++) {
        final dayStart = startDay.add(Duration(days: dayOffset));

        final ordersToday = _randInt(rng, 6, 18);
        for (int orderIndex = 0; orderIndex < ordersToday; orderIndex++) {
          final orderId = _uuid.v4();

          final timestamp = dayStart
              .add(Duration(seconds: rng.nextInt(24 * 60 * 60)))
              .millisecondsSinceEpoch;

          final orderType = _weightedChoice<String>(rng, const [
            ('dineIn', 0.55),
            ('takeAway', 0.35),
            ('delivery', 0.10),
          ]);
          final paymentType = _weightedChoice<String>(rng, const [
            ('cash', 0.75),
            ('KHQR', 0.25),
          ]);

          batch.insert(OrderDao.tableName, {
            OrderDao.colId: orderId,
            OrderDao.colTimeStamp: timestamp,
            OrderDao.colOrderType: orderType,
            OrderDao.colPaymentType: paymentType,
            OrderDao.colCartStatus: 'finalized',
            OrderDao.colOrderStatus: 'served',
          });

          final lineCount = _randInt(rng, 1, 5);
          double orderTotalUsd = 0.0;

          for (int line = 0; line < lineCount; line++) {
            final product = _weightedChoice<_SeedProduct>(rng, [
              (products[1], 0.18), // Iced Matcha Latte
              (products[0], 0.20), // Iced Latte
              (products[2], 0.16), // Iced Tea
              (products[4], 0.10), // Americano
              (products[3], 0.08), // Hot Coffee
              (products[5], 0.10), // Fries
              (products[6], 0.10), // Chicken Over Rice
              (products[7], 0.08), // Soda Can
            ]);

            final qty = _randInt(rng, 1, 4);

            final modifierSelections = <Map<String, Object?>>[];
            var unitPrice = product.basePrice;

            if (product.modifierGroupIds.contains(sizeGroupId) &&
                rng.nextBool()) {
              final sizeOpt = _weightedChoice<(String, double)>(rng, const [
                (('Small', 0.0), 0.55),
                (('Medium', 0.5), 0.30),
                (('Large', 0.75), 0.15),
              ]);
              modifierSelections.add({
                'groupName': 'Size',
                'optionNames': [sizeOpt.$1],
              });
              unitPrice += sizeOpt.$2;
            }

            if (product.modifierGroupIds.contains(sugarGroupId) &&
                rng.nextBool()) {
              final sugar = sugarOptions[rng.nextInt(sugarOptions.length)];
              modifierSelections.add({
                'groupName': 'Sugar Level',
                'optionNames': [sugar],
              });
            }

            if (product.modifierGroupIds.contains(toppingsGroupId) &&
                rng.nextInt(100) < 25) {
              final picks = <String>[];
              final max = _randInt(rng, 1, 3);
              for (int i = 0; i < max; i++) {
                picks.add(
                  toppingOptions[rng.nextInt(toppingOptions.length)].name,
                );
              }
              modifierSelections.add({
                'groupName': 'Toppings',
                'optionNames': picks,
              });

              // Add a small (approx) price change for toppings.
              unitPrice += 0.5 * picks.length;
            }

            final selectionsJson = modifierSelections.isEmpty
                ? null
                : jsonEncode(modifierSelections);

            orderTotalUsd += unitPrice * qty;

            batch.insert(OrderItemDao.tableName, {
              OrderItemDao.colId: _uuid.v4(),
              OrderItemDao.colOrderId: orderId,
              OrderItemDao.colProductId: product.id,
              OrderItemDao.colProductName: product.name,
              OrderItemDao.colUnitPrice: unitPrice,
              OrderItemDao.colProductImage: null,
              OrderItemDao.colProductDescription: product.description,
              OrderItemDao.colModifierSelections: selectionsJson,
              OrderItemDao.colNote: null,
              OrderItemDao.colQuantity: qty,
            });
          }

          // Payment (not required by report, but helps keep the dataset realistic)
          final receiveUsd = _roundToCents(
            orderTotalUsd + rng.nextDouble() * 3.0,
          );
          final receiveKhr = (receiveUsd * 4000).ceil() + rng.nextInt(2000);

          batch.insert(PaymentDao.tableName, {
            PaymentDao.colId: _uuid.v4(),
            PaymentDao.colOrderId: orderId,
            PaymentDao.colPaymentMethod: paymentType == 'cash' ? 0 : 1,
            PaymentDao.colReceiveAmountKhr: paymentType == 'KHQR'
                ? receiveKhr
                : 0,
            PaymentDao.colReceiveAmountUsd: paymentType == 'cash'
                ? receiveUsd
                : 0.0,
            PaymentDao.colChangeKhr: 0,
            PaymentDao.colChangeUsd: 0.0,
          });
        }
      }

      await batch.commit(noResult: true);
    });
  }

  static int _randInt(math.Random rng, int minInclusive, int maxInclusive) {
    if (maxInclusive < minInclusive) return minInclusive;
    return minInclusive + rng.nextInt(maxInclusive - minInclusive + 1);
  }

  static double _roundToCents(double value) =>
      (value * 100).roundToDouble() / 100;

  static T _weightedChoice<T>(
    math.Random rng,
    List<(T value, double weight)> options,
  ) {
    final total = options.fold<double>(0, (sum, e) => sum + e.$2);
    if (total <= 0) {
      return options.first.$1;
    }
    var roll = rng.nextDouble() * total;
    for (final option in options) {
      roll -= option.$2;
      if (roll <= 0) {
        return option.$1;
      }
    }
    return options.last.$1;
  }
}

class _SeedCategory {
  const _SeedCategory({required this.id, required this.name});

  final String id;
  final String name;
}

class _SeedProduct {
  const _SeedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.categoryId,
    required this.modifierGroupIds,
  });

  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String categoryId;
  final List<String> modifierGroupIds;
}
