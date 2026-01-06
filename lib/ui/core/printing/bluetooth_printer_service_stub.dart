import 'dart:typed_data';

import 'package:street_cart_pos/domain/models/printer_settings.dart';

class BluetoothPrinterService {
  BluetoothPrinterService({Object? printer, Object? printerSettingsRepository});

  Future<PrinterSettings> getSettings() async => const PrinterSettings(
    deviceName: null,
    bluetoothMacAddress: null,
    paperWidthMm: 58,
    dotsPerLine: 384,
    charsPerLine: 32,
  );

  Future<List<Object>> getBondedDevices() async => const [];

  Future<void> updateSelectedPrinter({
    required String deviceName,
    required String bluetoothMacAddress,
  }) async {
    throw UnsupportedError(
      'Bluetooth printing is not supported on this platform.',
    );
  }

  Uint8List buildTestPrintPayload({
    required String deviceName,
    required String bluetoothMacAddress,
    int charsPerLine = 32,
  }) {
    throw UnsupportedError(
      'Bluetooth printing is not supported on this platform.',
    );
  }

  Future<void> testPrint() async {
    throw UnsupportedError(
      'Bluetooth printing is not supported on this platform.',
    );
  }

  Future<void> printBytes(
    Uint8List bytes, {
    String? bluetoothMacAddress,
    int chunkSize = 512,
    Duration chunkDelay = const Duration(milliseconds: 15),
  }) async {
    throw UnsupportedError(
      'Bluetooth printing is not supported on this platform.',
    );
  }
}
