import 'package:blue_thermal_printer_plus/blue_thermal_printer_plus.dart';
import 'package:blue_thermal_printer_plus/bluetooth_device.dart';
import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/policy/viewmodel/printer_settings_viewmodel.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final PrinterSettingsViewModel _viewModel = PrinterSettingsViewModel();
  final BlueThermalPrinterPlus _printer = BlueThermalPrinterPlus();

  List<BluetoothDevice> _bondedDevices = const [];
  bool _loadingDevices = false;
  bool _printingTest = false;

  @override
  void initState() {
    super.initState();
    _loadBondedDevices();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadBondedDevices() async {
    if (_loadingDevices) return;
    setState(() => _loadingDevices = true);
    try {
      final devices = await _printer.getBondedDevices();
      if (!mounted) return;
      devices.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      setState(() => _bondedDevices = devices);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load paired devices: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingDevices = false);
    }
  }

  BluetoothDevice? _findSelectedDevice() {
    final address = _viewModel.settings.bluetoothMacAddress;
    if (address == null || address.trim().isEmpty) return null;

    for (final device in _bondedDevices) {
      if ((device.address ?? '').toLowerCase() == address.toLowerCase()) {
        return device;
      }
    }

    return BluetoothDevice(_viewModel.settings.deviceName, address);
  }

  Future<void> _testPrint() async {
    if (_printingTest) return;

    final selected = _findSelectedDevice();
    if (selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No printer selected')));
      return;
    }

    setState(() => _printingTest = true);
    try {
      final isOn = await _printer.isOn;
      if (isOn != true) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Bluetooth is off')));
        }
        return;
      }

      if ((await _printer.isConnected) == true) {
        await _printer.disconnect();
      }

      await _printer.connect(selected);
      final connected = await _printer.isConnected;
      if (connected != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to printer')),
          );
        }
        return;
      }

      await _printer.printCustom('Street Cart POS', 3, 1);
      await _printer.printCustom('Test print', 1, 1);
      await _printer.printNewLine();
      await _printer.printCustom(
        'Printer: ${selected.name ?? 'Unknown'}',
        0,
        0,
      );
      await _printer.printCustom('MAC: ${selected.address ?? ''}', 0, 0);
      await _printer.printCustom('Paper: 58mm • 384 dots/line', 0, 0);
      await _printer.printNewLine();
      await _printer.printCustom('-' * 32, 0, 0);
      await _printer.printNewLine();
      await _printer.printCustom('If you can read this, printing works.', 0, 0);
      await _printer.printNewLine();
      await _printer.printNewLine();
      await _printer.disconnect();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Test print sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test print failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _printingTest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final selectedAddress = _viewModel.settings.bluetoothMacAddress;
        final loading =
            _viewModel.loadPrinterSettingsCommand.running || _loadingDevices;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Printer'),
            actions: [
              IconButton(
                tooltip: 'Bluetooth settings',
                onPressed: () async {
                  await _printer.openSettings;
                },
                icon: const Icon(Icons.settings_bluetooth_outlined),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _loadingDevices ? null : _loadBondedDevices,
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Selected printer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _viewModel.settings.isConfigured
                                ? (_viewModel.settings.deviceName ?? 'Printer')
                                : 'Not configured',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _viewModel.settings.isConfigured
                                ? 'MAC: ${_viewModel.settings.bluetoothMacAddress}'
                                : 'Choose a paired Bluetooth printer below.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed:
                                    _viewModel.settings.isConfigured &&
                                        !_printingTest
                                    ? _testPrint
                                    : null,
                                icon: const Icon(Icons.print_outlined),
                                label: Text(
                                  _printingTest ? 'Printing...' : 'Test print',
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: _viewModel.settings.isConfigured
                                    ? () => _viewModel.clearPrinter()
                                    : null,
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Paired devices',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_bondedDevices.isEmpty && !loading)
                    Text(
                      'No paired devices found. Pair your printer in Android Bluetooth settings, then return and refresh.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ..._bondedDevices.map((device) {
                      final address = device.address ?? '';
                      final selected =
                          selectedAddress != null &&
                          selectedAddress.toLowerCase() ==
                              address.toLowerCase();

                      return Card(
                        elevation: 0,
                        color: selected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: ListTile(
                          title: Text(device.name ?? 'Unknown device'),
                          subtitle: Text(address),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: address.trim().isEmpty
                              ? null
                              : () async {
                                  await _viewModel.setSelectedPrinter(
                                    deviceName: device.name ?? 'Printer',
                                    bluetoothMacAddress: address,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Printer selected'),
                                      ),
                                    );
                                  }
                                },
                        ),
                      );
                    }),
                ],
              ),
              if (loading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.04),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
