import 'package:flutter/foundation.dart';
import 'package:street_cart_pos/data/repositories/printer_settings_repository.dart';
import 'package:street_cart_pos/domain/models/printer_settings.dart';
import 'package:street_cart_pos/utils/command.dart';

class PrinterSettingsViewModel extends ChangeNotifier {
  PrinterSettingsViewModel({PrinterSettingsRepository? repository})
    : _repository = repository ?? PrinterSettingsRepositoryImpl() {
    loadPrinterSettingsCommand = CommandWithParam((_) => _load());
    updatePrinterSettingsCommand = CommandWithParam(_update);

    loadPrinterSettingsCommand.addListener(notifyListeners);
    updatePrinterSettingsCommand.addListener(notifyListeners);

    loadPrinterSettingsCommand.execute(null);
  }

  final PrinterSettingsRepository _repository;

  PrinterSettings _settings = const PrinterSettings(
    deviceName: null,
    bluetoothMacAddress: null,
    paperWidthMm: 58,
    dotsPerLine: 384,
    charsPerLine: 32,
  );

  late final CommandWithParam<void, void> loadPrinterSettingsCommand;
  late final CommandWithParam<PrinterSettings, void>
  updatePrinterSettingsCommand;

  PrinterSettings get settings => _settings;

  Future<void> refresh() => loadPrinterSettingsCommand.execute(null);

  Future<void> setSelectedPrinter({
    required String deviceName,
    required String bluetoothMacAddress,
  }) {
    return updatePrinterSettingsCommand.execute(
      _settings.copyWith(
        deviceName: deviceName.trim(),
        bluetoothMacAddress: bluetoothMacAddress.trim(),
      ),
    );
  }

  Future<void> clearPrinter() {
    return updatePrinterSettingsCommand.execute(
      _settings.copyWith(deviceName: null, bluetoothMacAddress: null),
    );
  }

  Future<void> _load() async {
    _settings = await _repository.getPrinterSettings();
    notifyListeners();
  }

  Future<void> _update(PrinterSettings next) async {
    await _repository.updatePrinterSettings(next);
    _settings = next;
    notifyListeners();
  }

  @override
  void dispose() {
    loadPrinterSettingsCommand.removeListener(notifyListeners);
    updatePrinterSettingsCommand.removeListener(notifyListeners);
    super.dispose();
  }
}
