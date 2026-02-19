import 'package:adiary/compnents/removable_image.dart';
import 'package:adiary/screens/styled_text.dart';
import 'package:flutter/material.dart';

class ImagesInput extends StatelessWidget {
  final Function handleImagesSelection;
  final List<String> pickedImages;
  final String? directory;
  final Function removePickedImage;
  const ImagesInput(
      {super.key,
      required this.handleImagesSelection,
      required this.pickedImages,
      this.directory,
      required this.removePickedImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8.0, 8, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StyledText(value: pickedImages.isEmpty ? "Add Images" : "Images"),
              GestureDetector(
                onTap: () => handleImagesSelection(),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.pink.shade900,
                ),
              )
            ],
          ),
        ),
        if (pickedImages.isNotEmpty)
          Stack(
            children: [
              // Scrollable horizontal list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(pickedImages.length * 2 - 1, (index) {
                    if (index.isEven) {
                      final itemIndex = index ~/ 2;
                      return RemovableImage(
                          imagePath: "$directory/${pickedImages[itemIndex]}",
                          removeImageFn: () => removePickedImage(itemIndex));
                    } else {
                      return const SizedBox(width: 12); // separator
                    }
                  }),
                ),
              ),
            ],
          )
      ],
    );
  }
}
