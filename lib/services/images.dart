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

  /// Returns display paths (from temp dir) for showing images in the UI
  List<String> get imagePaths => List.unmodifiable(_imageNames);

  Future<String> get tempDirPath async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage(requestFullMetadata: true);
    final newNames = await Future.wait(images.map(_saveTemporarily));
    _imageNames = [..._imageNames, ...newNames];
  }

  Future<void> removeImage(int index) async {
    final name = _imageNames[index];
    final file = File(await _tempPath(name));
    if (await file.exists()) await file.delete();
    _imageNames.removeAt(index);
    _removedNames.add(name);
  }

  /// Returns the final saved image names, or throws if any temp file is missing
  Future<List<String>> saveFiles() async {
    final tempDir = await getTemporaryDirectory();

    // Verify all temp files exist before making any changes
    for (final name in _imageNames) {
      final source = File('${tempDir.path}/$name');
      if (!await source.exists()) {
        throw Exception(
            'Image "$name" was lost from temporary storage. Please re-select your images.');
      }
    }

    // All files verified — now safe to make changes
    await _deletePermanent(_removedNames);
    _removedNames = [];

    if (_imageNames.isEmpty) return [];

    final docsDir = await getApplicationDocumentsDirectory();
    for (final name in _imageNames) {
      final source = File('${tempDir.path}/$name');
      await source.copy('${docsDir.path}/$name');
    }

    return List.unmodifiable(_imageNames);
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