import 'dart:io' show File;

import 'package:flutter/painting.dart';

ImageProvider<Object> localFileImageProvider(String path) {
  return FileImage(File(path));
}

