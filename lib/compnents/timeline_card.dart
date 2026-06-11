import 'dart:io';

import 'package:adiary/compnents/audio_player.dart';
import 'package:adiary/compnents/mood_picker.dart';
import 'package:adiary/constants.dart';
import 'package:adiary/constants.dart' as constants;
import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/full_screen_gallery.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TimelineCard extends StatelessWidget {
  final Entry entry;
  const TimelineCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TimelineDecor(),
          Expanded(child: TimelineCardInfo(entry: entry))
        ],
      ),
    );
  }
}

class TimelineDecor extends StatelessWidget {
  const TimelineDecor({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 40,
        child: CustomPaint(
          painter: TimelineDecorPainter(),
          child: const SizedBox.expand(),
        ));
  }
}

class TimelineDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dotRadius = 4.0;
    final centerX = size.width / 2;
    final dotCenter = Offset(centerX, 0);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Line with linear gradient
    final linePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          PinkColors.shade400,
          PinkColors.shade300,
        ],
      ).createShader(fullRect)
      ..strokeWidth = 8.0;

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      linePaint,
    );

    // Circle with radial gradient on top
    final dotRect = Rect.fromCircle(center: dotCenter, radius: dotRadius);
    final circlePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          PinkColors.shade600, // bright center
          PinkColors.shade600, // dark edge
        ],
      ).createShader(dotRect);

    canvas.drawCircle(dotCenter, dotRadius, circlePaint);
    canvas.drawCircle(Offset(centerX, size.height), dotRadius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TimelineCardInfo extends StatelessWidget {
  final Entry entry;
  const TimelineCardInfo({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? findMood(String? label) {
      if (label == null) return null;
      try {
        return constants.MOOD_OPTIONS.firstWhere((m) => m['label'] == label);
      } catch (_) {
        return null;
      }
    }

    final mood = findMood(entry.mood);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 4.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            if (mood != null)
              Transform.scale(
                  scale: 0.8,
                  alignment: Alignment.centerLeft,
                  child: MoodPill(fn: () {}, mood: mood)),
            Text(
              entry.content ?? 'Hi there',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (entry.images != null)
              StackedPhotos(
                images: entry.images!,
              ),
            if (entry.audio != null) AudioSection(audioName: entry.audio!)
          ],
        ),
      ),
    );
  }
}

class AudioSection extends StatelessWidget {
  final String audioName;
  const AudioSection({super.key, required this.audioName});

  Future<String?> _resolveAudioPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$audioName');
    return await file.exists() ? file.path : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _resolveAudioPath(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          return SizedBox(
              width: double.infinity,
              child: AudioPlayerWidget(filePath: snapshot.data!));
        });
  }
}

class StackedPhotos extends StatefulWidget {
  final List<String> images;

  const StackedPhotos({
    super.key,
    required this.images,
  });

  // Rotations indexed by how many images are shown
  static const _rotations = {
    1: [0.03],
    2: [-0.06, 0.03],
    3: [0.09, -0.06, 0.03],
  };

  @override
  State<StackedPhotos> createState() => _StackedPhotosState();
}

class _StackedPhotosState extends State<StackedPhotos> {
  late final Future<Directory> _dirFuture;
  @override
  void initState() {
    super.initState();
    _dirFuture = getApplicationDocumentsDirectory();
  }

  Widget _photoCard(Widget child, double rotation, double cardSize) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: cardSize,
        height: cardSize,
        decoration: BoxDecoration(
          color: PinkColors.shade100,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    final count = widget.images.length.clamp(1, 3);
    final angles = StackedPhotos._rotations[count]!;

    final availableWidth =
        MediaQuery.of(context).size.width - 40 - 16 - 16 - 16;

    return FutureBuilder<Directory>(
      future: _dirFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final basePath = snapshot.data!.path;
        final items = widget.images
            .take(count)
            .map((p) => Image.file(File('$basePath/$p'), fit: BoxFit.cover))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenGallery(
                  imagePaths: widget.images,
                  initialIndex: 0,
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < items.length; i++)
                  _photoCard(items[i], angles[i], availableWidth),
              ],
            ),
          ),
        );
      },
    );
  }
}
