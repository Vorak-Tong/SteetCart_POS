import 'dart:convert';
import 'dart:typed_data';

import 'package:street_cart_pos/domain/models/enums.dart';
import 'package:street_cart_pos/domain/models/order.dart';
import 'package:street_cart_pos/domain/models/printer_settings.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';

class ReceiptEscPosBuilder {
  const ReceiptEscPosBuilder();

  Uint8List build({
    required StoreProfile storeProfile,
    required Order order,
    required PrinterSettings printerSettings,
    int? displayNumber,
    required int vatPercent,
    required int exchangeRateKhrPerUsd,
    required RoundingMode roundingMode,
    String? formattedDate,
    String? formattedTime,
  }) {
    final headerCharsPerLine = printerSettings.charsPerLine;
    final bodyCharsPerLine = printerSettings.paperWidthMm <= 58 ? 42 : 64;

    final subtotal = _roundUsd(order.getTotal());
    final vatRate = (vatPercent.clamp(0, 100)) / 100.0;
    final vat = _roundUsd(subtotal * vatRate);
    final totalUsd = _roundUsd(subtotal + vat);
    final totalKhr = _toKhr(
      totalUsd,
      exchangeRateKhrPerUsd: exchangeRateKhrPerUsd,
      roundingMode: roundingMode,
    );

    final b = _EscPosBuffer(charsPerLine: headerCharsPerLine);

    b.init();
    b.fontA();

    b.alignCenter();
    b.boldOn();
    b.textLine(storeProfile.name);
    b.boldOff();
    b.textLine(storeProfile.phone);
    b.textLine(storeProfile.address);
    b.feed(1);

    b.boldOn();
    b.textLine(displayNumber == null ? 'Order' : 'Order $displayNumber');
    b.boldOff();

    // Everything below "ORDER" should be in smaller text.
    b.fontB();
    b.setCharsPerLine(bodyCharsPerLine);

    b.alignLeft();
    b.textLine('ID: ${order.id}');
    final dateLine = (formattedDate == null || formattedDate.trim().isEmpty)
        ? _formatDate(order.timeStamp)
        : formattedDate.trim();
    final timeLine = (formattedTime == null || formattedTime.trim().isEmpty)
        ? _formatTime(order.timeStamp)
        : formattedTime.trim();
    b.textLine('$dateLine - $timeLine');
    b.feed(1);

    b.hr();

    for (final item in order.orderProducts) {
      final name = item.product?.name ?? 'Unknown item';
      final lineTotal = _roundUsd(item.getLineTotal());
      b.textLine(
        b.leftRight('${item.quantity}x ${name.trim()}', formatUsd(lineTotal)),
      );

      final modifierLines = <String>[];
      for (final selection in item.modifierSelections) {
        if (selection.optionNames.isEmpty) continue;
        modifierLines.add(
          '${selection.groupName}: ${selection.optionNames.join(', ')}',
        );
      }
      final note = item.note?.trim();

      if (modifierLines.isEmpty) {
        b.textLine('  no modifiers');
      } else {
        for (final line in modifierLines) {
          b.textLine('  ${_truncate(line, b.charsPerLine - 2)}');
        }
      }

      if (note != null && note.isNotEmpty) {
        b.textLine('  Note: ${_truncate(note, b.charsPerLine - 8)}');
      }

      b.feed(1);
    }

    b.hr();

    b.textLine(b.leftRight('Subtotal', formatUsd(subtotal)));
    b.textLine(b.leftRight('VAT ($vatPercent%)', formatUsd(vat)));
    b.textLine(
      'Rate (1 USD = ${formatIntWithThousandsSeparator(exchangeRateKhrPerUsd)} KHR)',
    );
    b.hr(ch: '=');
    b.boldOn();
    b.textLine(b.leftRight('Total', formatUsd(totalUsd)));
    b.boldOff();
    b.textLine(b.leftRight('', '(${formatKhr(totalKhr)})'));

    final payment = order.payment;
    if (payment != null) {
      b.feed(1);
      b.hr();
      b.boldOn();
      b.textLine('Payment');
      b.boldOff();
      b.textLine('Method: ${payment.type.name}');
      b.textLine('Receive USD: ${formatUsd(payment.recieveAmountUSD)}');
      b.textLine('Receive KHR: ${formatKhr(payment.recieveAmountKHR)}');
      b.textLine('Change KHR: ${formatKhr(payment.changeKhr)}');
    }

    b.feed(3);
    b.cut();

    return b.toBytes();
  }
}

class _EscPosBuffer {
  _EscPosBuffer({required int charsPerLine})
    : _charsPerLine = charsPerLine,
      _bytes = <int>[];

  int _charsPerLine;
  int get charsPerLine => _charsPerLine;
  final List<int> _bytes;

  Uint8List toBytes() => Uint8List.fromList(_bytes);

  void init() => _bytes.addAll(const [0x1B, 0x40]);

  void setCharsPerLine(int value) {
    _charsPerLine = value.clamp(1, 200);
  }

  void fontA() => _bytes.addAll(const [0x1B, 0x4D, 0x00]);
  void fontB() => _bytes.addAll(const [0x1B, 0x4D, 0x01]);

  void cut() => _bytes.addAll(const [0x1D, 0x56, 0x00]);

  void feed(int lines) {
    for (var i = 0; i < lines; i++) {
      _bytes.add(0x0A);
    }
  }

  void boldOn() => _bytes.addAll(const [0x1B, 0x45, 0x01]);
  void boldOff() => _bytes.addAll(const [0x1B, 0x45, 0x00]);

  void alignLeft() => _bytes.addAll(const [0x1B, 0x61, 0x00]);
  void alignCenter() => _bytes.addAll(const [0x1B, 0x61, 0x01]);
  void alignRight() => _bytes.addAll(const [0x1B, 0x61, 0x02]);

  void hr({String ch = '-'}) {
    textLine(ch * charsPerLine);
  }

  String leftRight(String left, String right) {
    final cleanLeft = left.trimRight();
    final cleanRight = right.trimLeft();

    final availableLeft = (charsPerLine - cleanRight.length - 1).clamp(
      0,
      charsPerLine,
    );
    final truncatedLeft = _truncate(cleanLeft, availableLeft);
    final spaces = charsPerLine - truncatedLeft.length - cleanRight.length;
    if (spaces <= 0) {
      return _truncate('$truncatedLeft $cleanRight', charsPerLine);
    }
    return '$truncatedLeft${' ' * spaces}$cleanRight';
  }

  void textLine(String text) {
    _bytes.addAll(_encode(text));
    _bytes.add(0x0A);
  }

  List<int> _encode(String text) {
    // Most thermal printers default to an 8-bit codepage. For v1 we keep
    // receipts ASCII-friendly. If we need Khmer later, switch to bitmap printing.
    final normalized = text.replaceAll('\n', ' ').replaceAll('\r', ' ');
    return const AsciiCodec(allowInvalid: true).encode(normalized);
  }
}

String _truncate(String input, int max) {
  if (max <= 0) return '';
  if (input.length <= max) return input;
  return input.substring(0, max);
}

double _roundUsd(double value) => (value * 100).roundToDouble() / 100;

int _toKhr(
  double usdAmount, {
  required int exchangeRateKhrPerUsd,
  required RoundingMode roundingMode,
}) {
  final value = _roundUsd(usdAmount) * exchangeRateKhrPerUsd;
  return switch (roundingMode) {
    RoundingMode.roundUp => value.ceil(),
    RoundingMode.roundDown => value.floor(),
  };
}

String _formatTime(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatDate(DateTime dt) {
  final yyyy = dt.year.toString().padLeft(4, '0');
  final mm = dt.month.toString().padLeft(2, '0');
  final dd = dt.day.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd';
}
