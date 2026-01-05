import 'dart:io' show Directory, File;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

Future<String> persistImagePath(String sourcePath) async {
  final directory = await getApplicationSupportDirectory();
  final imagesDir = Directory(p.join(directory.path, 'images'));
  await imagesDir.create(recursive: true);

  final ext = p.extension(sourcePath);
  final fileName = 'product_${_uuid.v4()}${ext.isEmpty ? '.jpg' : ext}';
  final targetPath = p.join(imagesDir.path, fileName);
  await File(sourcePath).copy(targetPath);
  return targetPath;
}
