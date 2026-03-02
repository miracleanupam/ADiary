import 'dart:async';

import 'package:adiary/constants.dart';
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

  bool get _hasFile => widget.filePath.isNotEmpty;

  static const _waveHeights = <double>[
    6, 14, 10, 18, 8,  20, 12, 16, 6,  22,
    10, 18, 14, 8,  20, 12, 16, 10, 14, 8,
    18, 6,  20, 12, 10, 16, 8,  14, 18, 10,
    6,  14, 10, 18, 8,  20, 12, 16, 6,  22,
    10, 18, 14, 8,  20, 12, 16, 10, 14, 8,
    18, 6,  20, 12, 10, 16, 8,  14, 18, 10,
  ];

  // ─── Lifecycle ────────────────────────────────────────────────────────────

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
        playing ? _playPauseController.forward() : _playPauseController.reverse();
      }),
      _player.onPositionChanged.listen((pos) => setState(() => _position = pos)),
      _player.onDurationChanged.listen((dur) => setState(() => _duration = dur)),
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  double get _progress {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void _togglePlay() {
    if (!_hasFile) return;
    _isPlaying ? _player.pause() : _player.play(widget.filePath);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      decoration: BoxDecoration(
        color: PinkColors.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PinkColors.shade900),
        boxShadow: [
          BoxShadow(
            color: PinkColors.shade100.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPlayButton(),
          const SizedBox(width: 12),
          Expanded(child: _buildWaveformSection(context)),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [PinkColors.shade300, PinkColors.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: PinkColors.shade300.withValues(alpha: 0.5),
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
    );
  }

  Widget _buildWaveformSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWaveform(),
        _buildScrubber(context),
        _buildTimestamps(),
      ],
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!_hasFile) return const Placeholder(color: Colors.transparent,);
          final count = _waveHeights.length;
          final barW = ((constraints.maxWidth - (count - 1) * 2) / count)
              .clamp(2.0, 8.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(count, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i < count - 1 ? 2 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: barW,
                  height: _waveHeights[i],
                  decoration: BoxDecoration(
                    color: i / count < _progress
                        ? PinkColors.shade700
                        : PinkColors.shade50,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildScrubber(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: PinkColors.shade700,
        inactiveTrackColor: PinkColors.shade100,
        thumbColor: PinkColors.shade700,
        overlayColor: PinkColors.shade200.withValues(alpha: 0.4),
      ),
      child: Slider(
        min: 0,
        max: _duration.inMilliseconds.toDouble(),
        value: _position.inMilliseconds
            .toDouble()
            .clamp(0, _duration.inMilliseconds.toDouble()),
        onChanged: (val) => _player.seek(val.toInt()),
      ),
    );
  }

  Widget _buildTimestamps() {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: PinkColors.shade900,
      letterSpacing: 0.5,
    );
    final placeholder = Text('--', style: style);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _hasFile ? Text(_format(_position), style: style) : placeholder,
          _hasFile ? Text(_format(_duration), style: style) : placeholder,
        ],
      ),
    );
  }
}