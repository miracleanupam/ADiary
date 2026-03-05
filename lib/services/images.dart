import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  List<String> _imageNames = [];
  List<String> _removedNames = [];

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<List<String>> pickImages() async {
    final images = await _picker.pickMultiImage(requestFullMetadata: true);
    _imageNames = await Future.wait(images.map(_saveTemporarily));
    return _imageNames;
  }

  Future<void> removeImage(String imageName) async {
    final file = File(await _tempPath(imageName));
    if (await file.exists()) await file.delete();
    _imageNames.remove(imageName);
    _removedNames.add(imageName);
  }

  Future<void> saveFiles() async {
    await _deletePermanent(_removedNames);
    _removedNames = [];

    if (_imageNames.isEmpty) return;

    final tempDir = await getTemporaryDirectory();
    final docsDir = await getApplicationDocumentsDirectory();

    for (final name in _imageNames) {
      final source = File('${tempDir.path}/$name');
      if (await source.exists()) {
        await source.copy('${docsDir.path}/$name');
      }
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Future<String> _saveTemporarily(XFile file) async {
    final name = '${_uuid.v7()}.jpg';
    await FlutterImageCompress.compressAndGetFile(
      file.path,
      await _tempPath(name),
      quality: 70,
    );
    return name;
  }

  Future<void> _deletePermanent(List<String> names) async {
    final docsDir = await getApplicationDocumentsDirectory();
    for (final name in names) {
      final file = File('${docsDir.path}/$name');
      if (await file.exists()) await file.delete();
    }
  }

  Future<String> _tempPath(String name) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/$name';
  }
}
