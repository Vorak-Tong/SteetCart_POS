import 'package:street_cart_pos/data/local/dao/printer_settings_dao.dart';
import 'package:street_cart_pos/domain/models/printer_settings.dart';

abstract class PrinterSettingsRepository {
  Future<PrinterSettings> getPrinterSettings();
  Future<void> updatePrinterSettings(PrinterSettings settings);
}

class PrinterSettingsRepositoryImpl implements PrinterSettingsRepository {
  final PrinterSettingsDao _dao = PrinterSettingsDao();

  @override
  Future<PrinterSettings> getPrinterSettings() async {
    final row = await _dao.get();
    if (row != null) {
      return PrinterSettings(
        deviceName: row[PrinterSettingsDao.colDeviceName] as String?,
        bluetoothMacAddress: row[PrinterSettingsDao.colBluetoothMac] as String?,
        paperWidthMm: (row[PrinterSettingsDao.colPaperWidthMm] as int? ?? 58)
            .clamp(48, 80),
        dotsPerLine: (row[PrinterSettingsDao.colDotsPerLine] as int? ?? 384)
            .clamp(1, 10000),
        charsPerLine: (row[PrinterSettingsDao.colCharsPerLine] as int? ?? 32)
            .clamp(1, 200),
      );
    }

    const fallback = PrinterSettings(
      deviceName: null,
      bluetoothMacAddress: null,
      paperWidthMm: 58,
      dotsPerLine: 384,
      charsPerLine: 32,
    );
    await _dao.insertOrUpdate({
      PrinterSettingsDao.colDeviceName: fallback.deviceName,
      PrinterSettingsDao.colBluetoothMac: fallback.bluetoothMacAddress,
      PrinterSettingsDao.colPaperWidthMm: fallback.paperWidthMm,
      PrinterSettingsDao.colDotsPerLine: fallback.dotsPerLine,
      PrinterSettingsDao.colCharsPerLine: fallback.charsPerLine,
    });
    return fallback;
  }

  @override
  Future<void> updatePrinterSettings(PrinterSettings settings) async {
    await _dao.insertOrUpdate({
      PrinterSettingsDao.colDeviceName: settings.deviceName?.trim(),
      PrinterSettingsDao.colBluetoothMac: settings.bluetoothMacAddress?.trim(),
      PrinterSettingsDao.colPaperWidthMm: settings.paperWidthMm,
      PrinterSettingsDao.colDotsPerLine: settings.dotsPerLine,
      PrinterSettingsDao.colCharsPerLine: settings.charsPerLine,
    });
  }
}
