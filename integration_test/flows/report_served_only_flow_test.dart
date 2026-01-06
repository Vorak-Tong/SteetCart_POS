import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:street_cart_pos/data/local/app_database.dart';
import 'package:street_cart_pos/data/local/seed/demo_business_seed.dart';
import 'package:street_cart_pos/domain/models/report_model.dart';
import 'package:street_cart_pos/main.dart' as app;
import 'package:street_cart_pos/ui/report/widgets/report_date_range_card.dart';
import 'package:street_cart_pos/ui/report/widgets/report_kpi_section.dart';

import '../helpers/flow_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    await DemoBusinessSeed.seedLast50Days(resetDatabase: true);
  });

  testWidgets(
    'Flow 4: report aggregates served orders (business seed) + date range picking',
    (WidgetTester tester) async {
      await FlowTestHelpers.pumpApp(tester, mainEntrypoint: app.main);

      Future<DateTime> latestServedOrderDay() async {
        final db = await AppDatabase.instance();
        final result = await db.rawQuery('''
          SELECT MAX(timestamp) as ts
          FROM orders
          WHERE cart_status = 'finalized' AND order_status = 'served'
          ''');
        final ts = (result.first['ts'] as num?)?.toInt();
        if (ts == null) {
          throw StateError('No served orders found in seed data.');
        }
        final dt = DateTime.fromMillisecondsSinceEpoch(ts);
        return DateTime(dt.year, dt.month, dt.day);
      }

      Future<int> countServedOrders(DateTime start, DateTime end) async {
        final db = await AppDatabase.instance();
        final result = await db.rawQuery(
          '''
          SELECT COUNT(*) as count
          FROM orders
          WHERE cart_status = 'finalized'
            AND order_status = 'served'
            AND timestamp BETWEEN ? AND ?
          ''',
          [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
        );
        return (result.first['count'] as num?)?.toInt() ?? 0;
      }

      final seedDay = await latestServedOrderDay();
      final todayStart = seedDay;
      final todayEnd = DateTime(
        seedDay.year,
        seedDay.month,
        seedDay.day,
        23,
        59,
        59,
        999,
      );
      final expectedToday = await countServedOrders(todayStart, todayEnd);
      expect(expectedToday, greaterThan(0));

      // Navigate to Report without using pumpAndSettle (the loading spinner can
      // keep scheduling frames and cause timeouts on slower devices).
      await FlowTestHelpers.openDrawer(tester);
      await tester.tap(
        find
            .descendant(of: find.byType(Drawer), matching: find.text('Report'))
            .first,
      );
      await tester.pump();
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (find.byKey(ReportKpiSection.totalOrdersKey).evaluate().isNotEmpty &&
            find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
      }

      expect(find.byKey(ReportKpiSection.totalOrdersKey), findsOneWidget);
      final actualTodayText = tester
          .widget<Text>(find.byKey(ReportKpiSection.totalOrdersKey))
          .data;
      expect(actualTodayText, isNotNull);
      final actualToday = int.parse(actualTodayText!);
      expect(actualToday, expectedToday);

      String currentRangeLabel() {
        final labelFinder = find.descendant(
          of: find.byType(ReportDateRangeCard),
          matching: find.byType(Text),
        );
        expect(labelFinder, findsAtLeastNWidgets(1));
        final text = tester.widget<Text>(labelFinder.first).data;
        expect(text, isNotNull);
        return text!;
      }

      DateTime parseReportLabelDate(String raw) {
        // Matches ReportViewModel.formatDate: "Jan 5, 2010"
        final parts = raw.trim().split(RegExp(r'\s+'));
        if (parts.length < 3) {
          throw FormatException('Unexpected date label: $raw');
        }
        const months = <String, int>{
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };
        final month = months[parts[0]];
        final day = int.tryParse(parts[1].replaceAll(',', ''));
        final year = int.tryParse(parts[2]);
        if (month == null || day == null || year == null) {
          throw FormatException('Unexpected date label: $raw');
        }
        return DateTime(year, month, day);
      }

      final beforeRangeLabel = currentRangeLabel();

      // Date range picking: widen to include more days, then verify totals match DB.
      final localizations = MaterialLocalizations.of(
        tester.element(find.byKey(ReportKpiSection.totalOrdersKey)),
      );

      // Expand the range forward (safe even if today's date is clamped to the
      // earliest allowed date).
      final startDate = Report.clampDate(todayStart);
      final endDate = Report.clampDate(
        todayStart.add(const Duration(days: 14)),
      );

      await tester.tap(find.byIcon(Icons.calendar_month));
      await tester.pumpAndSettle();

      final dialog = find.byType(DateRangePickerDialog);
      expect(dialog, findsOneWidget);

      // Prefer input mode for stability (avoids tapping ambiguous day numbers).
      final inputMode = find.byTooltip(localizations.inputDateModeButtonLabel);
      if (inputMode.evaluate().isNotEmpty) {
        await tester.tap(inputMode.first);
        await tester.pumpAndSettle();
      }

      final compactStart = localizations.formatCompactDate(startDate);
      final compactEnd = localizations.formatCompactDate(endDate);

      final fields = find.descendant(
        of: dialog,
        matching: find.byType(TextField),
      );
      expect(fields, findsAtLeastNWidgets(2));
      await tester.enterText(fields.at(0), compactStart);
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(1), compactEnd);
      await tester.pumpAndSettle();

      final save = find.text(localizations.saveButtonLabel);
      final ok = find.text(localizations.okButtonLabel);
      if (save.evaluate().isNotEmpty) {
        await tester.tap(save);
      } else {
        expect(ok, findsAtLeastNWidgets(1));
        await tester.tap(ok.first);
      }
      await tester.pump();
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (find.byKey(ReportKpiSection.totalOrdersKey).evaluate().isNotEmpty &&
            find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
      }

      final afterRangeLabel = currentRangeLabel();
      expect(afterRangeLabel, isNot(beforeRangeLabel));

      final rangeParts = afterRangeLabel.split(' - ');
      expect(rangeParts.length, 2);
      final selectedStart = parseReportLabelDate(rangeParts[0]);
      final selectedEnd = parseReportLabelDate(rangeParts[1]);

      final rangeStart = DateTime(
        selectedStart.year,
        selectedStart.month,
        selectedStart.day,
      );
      final rangeEnd = DateTime(
        selectedEnd.year,
        selectedEnd.month,
        selectedEnd.day,
        23,
        59,
        59,
        999,
      );
      final expectedRange = await countServedOrders(rangeStart, rangeEnd);

      final actualRangeText = tester
          .widget<Text>(find.byKey(ReportKpiSection.totalOrdersKey))
          .data;
      expect(actualRangeText, isNotNull);
      final actualRange = int.parse(actualRangeText!);
      expect(actualRange, expectedRange);
    },
  );
}
