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
  late Animation<double> _micAnimation;

  int _secondsElapsed = 0;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true)..addListener(() => setState(() {}));

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

  void _startRecordingUI() {
    _stopwatch.reset();
    _stopwatch.start();
    _tickTimer();
  }

  void _stopRecordingUI() {
    _stopwatch.stop();
    _pulseController.stop();
    _pulseController.reset();
    _pulseController.repeat(reverse: true);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Use the button below to start/stop or redo the recording.",
                    style: TextStyle(
                      color: Colors.pink.shade900,
                    ),
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  ScaleTransition(
                    scale: widget.isRecording
                        ? _pulseAnimation
                        : _micAnimation,
                    child: IconButton.filled(
                      iconSize: 48,
                      icon: Icon(
                        widget.isRecording ? Icons.stop_circle : Icons.mic,
                        color: widget.isRecording ? Colors.red : null,
                      ),
                      onPressed: () => widget.toggleRecordingState(),
                    ),
                  ),
                ],
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
                if (!widget.isRecording)
                  Text(
                    widget.recordingPath == ''
                        ? "You can preview the audio here after you record something."
                        : "Preview:",
                    style: TextStyle(
                      color: Colors.pink.shade900,
                    ),
                  ),
                if (!widget.isRecording)
                  Stack(
                    children: [
                      AudioPlayerWidget(filePath: widget.recordingPath),
                      if (widget.recordingPath != '')
                        RemoveAudioButton(widget: widget)
                    ],
                  ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          )),
          // Recording indicator row
        ],
      ),
    );
  }
}

class RemoveAudioButton extends StatefulWidget {
  const RemoveAudioButton({
    super.key,
    required this.widget,
  });

  final AudioInput widget;

  @override
  State<RemoveAudioButton> createState() => _RemoveAudioButtonState();
}

class _RemoveAudioButtonState extends State<RemoveAudioButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )
      ..repeat(reverse: true)
      ..addListener(() {});
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        right: 5,
        child: GestureDetector(
          onTap: () => widget.widget.removeAudio(),
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pink.shade600),
                color: Colors.pink.shade200,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.pink.shade600,
                  ),
                ),
              )),
        ));
  }
}
