import 'dart:io';

import 'package:flutter/material.dart';

class RemovableImage extends StatelessWidget {
  final String imagePath;
  final Function removeImageFn;
  const RemovableImage(
      {super.key, required this.imagePath, required this.removeImageFn});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(6),
          child: Image.file(
            File(imagePath),
            height: 100,
          )),
      Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => removeImageFn(),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close,
                    size: 16,
                  ),
                )),
          )),
    ]);
  }
}
