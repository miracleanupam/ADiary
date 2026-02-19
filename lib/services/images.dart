import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  List<String> imageNames = [];
  List<String> removedNames = [];

  Future<List<String>> pickImages() async {
    ImagePicker imagePicker = ImagePicker();
    List<XFile> images = await imagePicker.pickMultiImage(
      requestFullMetadata: true,
    );

    imageNames =
        await Future.wait(images.map((image) => saveTemporarily(image)));

    return imageNames;
  }

  Future<String> saveTemporarily(XFile file) async {
    final directory = await getTemporaryDirectory();
    var uuid = Uuid();
    String uuidString = uuid.v7();
    final imageName = '$uuidString.jpg';
    final imagePath = '${directory.path}/$imageName';
    await FlutterImageCompress.compressAndGetFile(file.path, imagePath,
        quality: 70);
    return imageName;
  }

  Future<void> removeImage(imageName) async {
    final directory = await getTemporaryDirectory();
    String imagePath = "${directory.path}/$imageName";

    File imageFile = File(imagePath);

    if (await imageFile.exists()) {
      await imageFile.delete();
      imageNames.remove(imageName);
      removedNames.add(imageName);
    }
  }

  Future<void> saveFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    if (removedNames.isNotEmpty) {
      for (final removedName in removedNames) {
        String sourcePath = '${directory.path}/$removedName';
        final sourceFile = File(sourcePath);

        if (await sourceFile.exists()) {
          sourceFile.delete();
        }
      }
      removedNames = [];
    }
    if (imageNames.isEmpty) {
      return;
    }

    final tempDirectory = await getTemporaryDirectory();
    for (final imageName in imageNames) {
      String sourcePath = '${tempDirectory.path}/$imageName';
      final sourceFile =
          File(sourcePath); // imageName is the full path from picker
      if (await sourceFile.exists()) {
        final destinationPath = '${directory.path}/$imageName';
        await sourceFile.copy(destinationPath);
      }
    }
  }
}
