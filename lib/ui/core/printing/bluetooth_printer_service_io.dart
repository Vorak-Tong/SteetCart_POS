import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:blue_thermal_printer_plus/blue_thermal_printer_plus.dart';
import 'package:blue_thermal_printer_plus/bluetooth_device.dart';
import 'package:street_cart_pos/data/repositories/printer_settings_repository.dart';
import 'package:street_cart_pos/domain/models/printer_settings.dart';

class BluetoothPrinterService {
  BluetoothPrinterService({
    BlueThermalPrinterPlus? printer,
    PrinterSettingsRepository? printerSettingsRepository,
  }) : _printer = printer ?? BlueThermalPrinterPlus(),
       _printerSettingsRepository =
           printerSettingsRepository ?? PrinterSettingsRepositoryImpl();

  final BlueThermalPrinterPlus _printer;
  final PrinterSettingsRepository _printerSettingsRepository;

  Future<PrinterSettings> getSettings() =>
      _printerSettingsRepository.getPrinterSettings();

  Future<List<BluetoothDevice>> getBondedDevices() async {
    final devices = await _printer.getBondedDevices();
    devices.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return devices;
  }

  Future<void> updateSelectedPrinter({
    required String deviceName,
    required String bluetoothMacAddress,
  }) async {
    final current = await _printerSettingsRepository.getPrinterSettings();
    await _printerSettingsRepository.updatePrinterSettings(
      current.copyWith(
        deviceName: deviceName.trim(),
        bluetoothMacAddress: bluetoothMacAddress.trim(),
      ),
    );
  }

  Uint8List buildTestPrintPayload({
    required String deviceName,
    required String bluetoothMacAddress,
    int charsPerLine = 32,
  }) {
    final hr = '-' * charsPerLine;
    final text = StringBuffer()
      ..writeln('Street Cart POS')
      ..writeln('Test print')
      ..writeln(hr)
      ..writeln('Printer: $deviceName')
      ..writeln('MAC: $bluetoothMacAddress')
      ..writeln('Paper: 58mm / 384 dots/line')
      ..writeln(hr)
      ..writeln('If you can read this, printing works.')
      ..writeln();

    final encoded = const AsciiCodec(
      allowInvalid: true,
    ).encode(text.toString().replaceAll('\n', '\n'));
    final bytes = <int>[
      0x1B, 0x40, // init
      0x1B, 0x61, 0x01, // center
      ...encoded,
      0x0A,
      0x0A,
    ];
    return Uint8List.fromList(bytes);
  }

  Future<void> testPrint() async {
    final settings = await _printerSettingsRepository.getPrinterSettings();
    final address = settings.bluetoothMacAddress?.trim();
    if (address == null || address.isEmpty) {
      throw StateError('No printer configured.');
    }
    final name = settings.deviceName ?? 'Printer';
    final payload = buildTestPrintPayload(
      deviceName: name,
      bluetoothMacAddress: address,
      charsPerLine: settings.charsPerLine,
    );
    await printBytes(payload, bluetoothMacAddress: address);
  }

  Future<void> printBytes(
    Uint8List bytes, {
    String? bluetoothMacAddress,
    int chunkSize = 512,
    Duration chunkDelay = const Duration(milliseconds: 15),
  }) async {
    final isOn = await _printer.isOn;
    if (isOn != true) {
      throw StateError('Bluetooth is off.');
    }

    final settings = await _printerSettingsRepository.getPrinterSettings();
    final address = (bluetoothMacAddress ?? settings.bluetoothMacAddress)
        ?.trim();
    if (address == null || address.isEmpty) {
      throw StateError('No printer configured.');
    }

    if ((await _printer.isConnected) == true) {
      await _printer.disconnect();
    }

    final device = await _resolveDevice(
      address,
      fallbackName: settings.deviceName,
    );
    await _printer.connect(device);

    final connected = await _printer.isConnected;
    if (connected != true) {
      throw StateError('Failed to connect to printer.');
    }

    try {
      if (bytes.isEmpty) {
        return;
      }

      if (chunkSize <= 0 || bytes.length <= chunkSize) {
        await _printer.writeBytes(bytes);
        return;
      }

      for (var start = 0; start < bytes.length; start += chunkSize) {
        final end = (start + chunkSize).clamp(0, bytes.length);
        final chunk = Uint8List.sublistView(bytes, start, end);
        await _printer.writeBytes(chunk);
        await Future<void>.delayed(chunkDelay);
      }
    } finally {
      await _printer.disconnect();
    }
  }

  Future<BluetoothDevice> _resolveDevice(
    String address, {
    String? fallbackName,
  }) async {
    try {
      final devices = await getBondedDevices();
      for (final device in devices) {
        final deviceAddress = device.address;
        if (deviceAddress == null) continue;
        if (deviceAddress.toLowerCase() == address.toLowerCase()) {
          return device;
        }
      }
    } catch (_) {
      // Ignore and fall back to address-only device creation.
    }

    return BluetoothDevice(fallbackName ?? 'Printer', address);
  }
}
