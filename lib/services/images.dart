import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  Future<List<String>> pickImages() async {
    ImagePicker imagePicker = ImagePicker();
    List<XFile> images = await imagePicker.pickMultiImage(
      requestFullMetadata: true,
    );

    List<String> imagePaths =
        await Future.wait(images.map((image) => saveFile(image)));

    return imagePaths;
  }

  Future<String> saveFile(XFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    var uuid = Uuid();
    String uuidString = uuid.v7();
    final imageName = '$uuidString.jpg';
    final imagePath = '${directory.path}/$imageName';
    await FlutterImageCompress.compressAndGetFile(
      file.path,
      imagePath,
      quality: 70, // 0–100
    );
    return imageName;
  }
}
