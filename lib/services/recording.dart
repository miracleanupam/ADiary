import 'dart:io';

import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class RecorderService {
  final _recorder = AudioRecorder();
  String? tempAudioPath;
  String? audioName;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (!await hasPermission()) return;

    final directory = await getTemporaryDirectory();
    var uuid = Uuid();
    String uuidString = uuid.v7();
    audioName = '$uuidString.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: '${directory.path}/$audioName',
    );
  }

  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) return null;
    tempAudioPath = await _recorder.stop();
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
    audioName = null;
  }

  Future<String?> saveFile() async {
    if (tempAudioPath == null || tempAudioPath == '') {
      return null;
    }

    final File sourceFile = File(tempAudioPath!);

    if (await sourceFile.exists()) {
      final directory = await getApplicationDocumentsDirectory();
      final audioPath = '${directory.path}/$audioName';

      await sourceFile.rename(audioPath);
      return audioName;

    }
    return null;
  }

  void dispose() {
    _recorder.dispose();
  }
}