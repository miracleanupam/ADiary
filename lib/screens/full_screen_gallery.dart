import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late final PageController _pageController;
  late int _currentIndex;
  String? _directory;

  static const int _multiplier = 10000;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final initialPage = (_multiplier ~/ 2) * widget.imagePaths.length + widget.initialIndex;
    _pageController = PageController(initialPage: initialPage);
    _loadDirectory();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) setState(() => _directory = dir.path);
  }

  void _changeCurrentImage(int index) {
    setState(() => _currentIndex = index % widget.imagePaths.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _directory == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PhotoViewGallery.builder(
                  pageController: _pageController,
                  itemCount: widget.imagePaths.length * _multiplier,
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                  onPageChanged: _changeCurrentImage,
                  builder: (context, index) {
                    final realIndex = index % widget.imagePaths.length;
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(
                        File('$_directory/${widget.imagePaths[realIndex]}'),
                      ),
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: widget.imagePaths[realIndex],
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3,
                    );
                  },
                ),
                Positioned(
                  bottom: 30,
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imagePaths.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }

}
