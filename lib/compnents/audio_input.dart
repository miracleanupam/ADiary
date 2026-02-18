import 'package:adiary/compnents/audio_player.dart';
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _secondsElapsed = 0;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() => setState(() {}));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
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

  void _startRecordingUI() {
    _stopwatch.reset();
    _stopwatch.start();
    _pulseController.repeat(reverse: true);
    _tickTimer();
  }

  void _stopRecordingUI() {
    _stopwatch.stop();
    _pulseController.stop();
    _pulseController.reset();
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
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink.shade900, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Pulsing mic / stop button
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: ScaleTransition(
                scale: widget.isRecording
                    ? _pulseAnimation
                    : const AlwaysStoppedAnimation(1.0),
                child: IconButton.filled(
                  iconSize: 48,
                  icon: Icon(
                    widget.isRecording ? Icons.stop_circle : Icons.mic,
                    color: widget.isRecording ? Colors.red : null,
                  ),
                  onPressed: () => widget.toggleRecordingState(),
                ),
              ),
            ),
          ),

          Expanded(
              child: Container(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 48,
                      ),
                      // Blinking red dot
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
                          color: Colors.pink.shade900,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                Spacer(),
                if (widget.recordingPath != '' && !widget.isRecording)
                  Stack(
                    children: [
                      AudioPlayerWidget(filePath: widget.recordingPath),
                      Positioned(
                          top: 0,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => widget.removeAudio(),
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.pink.shade900),
                                  color:
                                      Colors.pink.shade200.withValues(alpha: 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.pink.shade900,
                                  ),
                                )),
                          ))
                    ],
                  ),
                  SizedBox(height: 24,)
              ],
            ),
          )),
          // Recording indicator row
        ],
      ),
    );
  }
}
