import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProfileImageStorage {
  /// Save a picked image file into app documents/profile_images and return saved path
  static Future<String> saveFile(File pickedFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'profile_images'));
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final fileName = p.basename(pickedFile.path);
    final saved = await pickedFile.copy(p.join(imagesDir.path, fileName));
    return saved.path;
  }

  /// Optionally remove a saved image file
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(
        path.startsWith('file:') ? Uri.parse(path).toFilePath() : path,
      );
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
