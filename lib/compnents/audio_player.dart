import 'dart:async';

import 'package:adiary/services/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  const AudioPlayerWidget({required this.filePath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _player = AudioPlayerService();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late final List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();

    _subs = [
      _player.onStateChanged.listen((state) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }),
      _player.onPositionChanged.listen((pos) {
        setState(() => _position = pos);
      }),
      _player.onDurationChanged.listen((dur) {
        setState(() => _duration = dur);
      })
    ];
  }

  String _format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            if (_isPlaying) {
              _player.pause();
            } else {
              _player.play(widget.filePath);
            }
          },
        ),
        Text(_format(_position)),
        Expanded(
          child: Slider(
            min: 0,
            max: _duration.inMilliseconds.toDouble(),
            value: _position.inMilliseconds.toDouble().clamp(
                  0,
                  _duration.inMilliseconds.toDouble(),
                ),
            onChanged: (val) {
              // _player.seek(Duration(milliseconds: val.toInt()));
            },
          ),
        ),
        Text(_format(_duration)),
      ],
    );
  }
}
