import 'dart:io';

import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class RecorderService {
  final _recorder = AudioRecorder();
  String? tempAudioPath;
  String? audioName;
  bool hasAudio = false;
  bool hasRemovedAudio = false;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  String getAudioName() {
    if (audioName != null) {
      return audioName!;
    }

    var uuid = Uuid();
    String uuidString = uuid.v7();
    audioName = '$uuidString.m4a';
    return audioName!;
  }

  Future<void> startRecording() async {
    if (!await hasPermission()) return;

    final directory = await getTemporaryDirectory();

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: '${directory.path}/${getAudioName()}',
    );
  }

  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) return null;
    tempAudioPath = await _recorder.stop();
    hasRemovedAudio = false;
    return tempAudioPath;
  }

  Future<void> pauseRecording() async {
    await _recorder.pause();
  }

  Future<void> resumeRecording() async {
    await _recorder.resume();
  }

  Future<void> deleteFile() async {
    if (tempAudioPath == null || tempAudioPath == '') {
      return;
    }
    final File targetFile = File(tempAudioPath!);
    if (await targetFile.exists()) {
      targetFile.delete();
    }
    tempAudioPath = null;
    hasRemovedAudio = true;
  }

  Future<String?> saveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final audioPath = '${directory.path}/${getAudioName()}';
    final File audioToRemove = File(audioPath);

    if (hasRemovedAudio && await audioToRemove.exists()) {
      audioToRemove.delete();
      hasRemovedAudio = false;
      return null;
    }

    if (tempAudioPath == null || tempAudioPath == '') {
      return null;
    }

    final File sourceFile = File(tempAudioPath!);
    if (await sourceFile.exists()) {
      await sourceFile.copy(audioPath);
      return getAudioName();
    }
    return null;
  }

  void dispose() {
    _recorder.dispose();
  }
}
