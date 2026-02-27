import 'dart:async';
import 'package:adiary/services/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  const AudioPlayerWidget({super.key, required this.filePath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayerService();

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  late final List<StreamSubscription> _subs;
  late final AnimationController _playPauseController;

  static const List<double> _waveHeights = [
    6,
    14,
    10,
    18,
    8,
    20,
    12,
    16,
    6,
    22,
    10,
    18,
    14,
    8,
    20,
    12,
    16,
    10,
    14,
    8,
    18,
    6,
    20,
    12,
    10,
    16,
    8,
    14,
    18,
    10,
    6,
    14,
    10,
    18,
    8,
    20,
    12,
    16,
    6,
    22,
    10,
    18,
    14,
    8,
    20,
    12,
    16,
    10,
    14,
    8,
    18,
    6,
    20,
    12,
    10,
    16,
    8,
    14,
    18,
    10,
  ];

  @override
  void initState() {
    super.initState();

    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _subs = [
      _player.onStateChanged.listen((state) {
        final playing = state == PlayerState.playing;
        setState(() => _isPlaying = playing);
        playing
            ? _playPauseController.forward()
            : _playPauseController.reverse();
      }),
      _player.onPositionChanged.listen((pos) {
        setState(() => _position = pos);
      }),
      _player.onDurationChanged.listen((dur) {
        setState(() => _duration = dur);
      }),
    ];
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _playPauseController.dispose();
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  double get _progress {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  void _togglePlay() {
    if (widget.filePath == '') {
      return;
    }
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play(widget.filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.pink.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink.shade900, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Play / Pause button ──────────────────────────────
          GestureDetector(
            onTap: _togglePlay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.pink.shade300, Colors.pink.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade300.withOpacity(0.5),
                    blurRadius: _isPlaying ? 14 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _playPauseController,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Waveform + scrubber + timestamps ────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Decorative waveform bars
                SizedBox(
                  height: 24,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final count = _waveHeights.length;
                      final barW =
                          ((constraints.maxWidth - (count - 1) * 2) / count)
                              .clamp(2.0, 8.0);
                      return widget.filePath == ''
                          ? Placeholder()
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(count, (i) {
                                final filled = i / count < _progress;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      right: i < count - 1 ? 2 : 0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 80),
                                    width: barW,
                                    height: _waveHeights[i],
                                    decoration: BoxDecoration(
                                      color: filled
                                          ? Colors.pink.shade700
                                          : Colors.pink.shade50,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }),
                            );
                    },
                  ),
                ),

                // Slim slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: Colors.pink.shade700,
                    inactiveTrackColor: Colors.pink.shade100,
                    thumbColor: Colors.pink.shade700,
                    overlayColor: Colors.pink.shade200.withOpacity(0.4),
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inMilliseconds.toDouble(),
                    value: _position.inMilliseconds
                        .toDouble()
                        .clamp(0, _duration.inMilliseconds.toDouble()),
                    onChanged: (val) {
                      _player.seek(val.toInt());
                    },
                  ),
                ),

                // Timestamps
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.filePath == '' ? "--" : _format(_position),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.pink.shade900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.filePath == '' ? "--" : _format(_duration),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.pink.shade900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
