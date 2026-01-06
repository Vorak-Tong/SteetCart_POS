class PrinterSettings {
  const PrinterSettings({
    required this.deviceName,
    required this.bluetoothMacAddress,
    this.paperWidthMm = 58,
    this.dotsPerLine = 384,
    this.charsPerLine = 32,
  });

  final String? deviceName;
  final String? bluetoothMacAddress;

  final int paperWidthMm;
  final int dotsPerLine;
  final int charsPerLine;

  bool get isConfigured =>
      bluetoothMacAddress != null && bluetoothMacAddress!.trim().isNotEmpty;

  PrinterSettings copyWith({
    String? deviceName,
    String? bluetoothMacAddress,
    int? paperWidthMm,
    int? dotsPerLine,
    int? charsPerLine,
  }) {
    return PrinterSettings(
      deviceName: deviceName ?? this.deviceName,
      bluetoothMacAddress: bluetoothMacAddress ?? this.bluetoothMacAddress,
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
      dotsPerLine: dotsPerLine ?? this.dotsPerLine,
      charsPerLine: charsPerLine ?? this.charsPerLine,
    );
  }
}
