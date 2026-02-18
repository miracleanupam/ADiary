import 'package:adiary/compnents/audio_player.dart';
import 'package:flutter/material.dart';

class AudioInput extends StatelessWidget {
  final bool isRecording;
  final Function toggleRecordingState;
  final Function removeAudio;
  final String recordingPath;
  const AudioInput(
      {super.key,
      required this.isRecording,
      required this.toggleRecordingState,
      required this.recordingPath,
      required this.removeAudio});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          iconSize: 48,
          icon: Icon(
            isRecording ? Icons.stop_circle : Icons.mic,
            color: isRecording ? Colors.red : null,
          ),
          onPressed: () => toggleRecordingState(),
        ),
        if (recordingPath != '')
          IconButton(onPressed: () => removeAudio(), icon: Icon(Icons.cut)),
        if (recordingPath != '') AudioPlayerWidget(filePath: recordingPath),
      ],
    );
  }
}
