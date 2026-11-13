import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Stores finished artwork as PNG files inside the app's own folder.
class ArtStore {
  static Future<Directory> _dir() async {
    Directory base;
    try {
      base = await getApplicationDocumentsDirectory();
    } catch (_) {
      base = Directory.systemTemp;
    }
    final dir = Directory('${base.path}/coloria_art');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> save(Uint8List pngBytes) async {
    final dir = await _dir();
    final file =
        File('${dir.path}/art_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return file;
  }

  static Future<List<File>> list() async {
    final dir = await _dir();
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.png'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  static Future<void> delete(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
