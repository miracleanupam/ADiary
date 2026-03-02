import 'package:adiary/compnents/animated_close_button.dart';
import 'package:adiary/compnents/audio_player.dart';
import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class AudioInput extends StatefulWidget {
  final bool isRecording;
  final Function toggleRecordingState;
  final Function removeAudio;
  final String recordingPath;

  const AudioInput({
    super.key,
    required this.isRecording,
    required this.toggleRecordingState,
    required this.recordingPath,
    required this.removeAudio,
  });

  @override
  State<AudioInput> createState() => _AudioInputState();
}

class _AudioInputState extends State<AudioInput>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _micAnimation;
  late final Stopwatch _stopwatch;

  int _secondsElapsed = 0;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )
      ..repeat(reverse: true)
      ..addListener(() => setState(() {}));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _micAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AudioInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startRecordingUI();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopRecordingUI();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  // ─── Recording UI ─────────────────────────────────────────────────────────

  void _startRecordingUI() {
    _stopwatch
      ..reset()
      ..start();
    _tickTimer();
  }

  void _stopRecordingUI() {
    _stopwatch.stop();
    _pulseController
      ..stop()
      ..reset()
      ..repeat(reverse: true);
    setState(() => _secondsElapsed = 0);
  }

  void _tickTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !widget.isRecording) return;
      setState(() => _secondsElapsed = _stopwatch.elapsed.inSeconds);
      _tickTimer();
    });
  }

  String get _formattedTime {
    final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: PinkColors.shade900),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Column(
        children: [
          Expanded(child: _buildMicSection()),
          Expanded(child: _buildPreviewSection()),
        ],
      ),
    );
  }

  Widget _buildMicSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Use the button below to start/stop or redo the recording.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PinkColors.shade900),
        ),
        const SizedBox(height: 48),
        ScaleTransition(
          scale: widget.isRecording ? _pulseAnimation : _micAnimation,
          child: IconButton.filled(
            iconSize: 48,
            icon: Icon(
              widget.isRecording ? Icons.stop_circle : Icons.mic,
              color: widget.isRecording ? Colors.red : null,
            ),
            onPressed: () => widget.toggleRecordingState(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.isRecording) _buildRecordingIndicator(),
        const Spacer(),
        if (!widget.isRecording) ...[
          Text(
            widget.recordingPath.isEmpty
                ? 'You can preview the audio here after you record something.'
                : 'Preview:',
            textAlign: TextAlign.center,
            style: TextStyle(color: PinkColors.shade900),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                AudioPlayerWidget(filePath: widget.recordingPath),
                if (widget.recordingPath.isNotEmpty)
                  AnimatedCloseButton(
                    top: 0,
                    right: 0,
                    fn: widget.removeAudio,
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        AnimatedOpacity(
          opacity: _pulseController.value > 0.5 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formattedTime,
          style: TextStyle(
            color: PinkColors.shade900,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}