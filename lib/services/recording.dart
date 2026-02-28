import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class RecorderService {
  final _recorder = AudioRecorder();
  final _uuid = const Uuid();

  String? _tempAudioPath;
  String? _audioName;
  bool _hasRemovedAudio = false;

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<bool> hasPermission() => _recorder.hasPermission();

  // ─── Name ─────────────────────────────────────────────────────────────────

  String _getOrCreateAudioName() {
    return _audioName ??= '${_uuid.v7()}.m4a';
  }

  // ─── Record ───────────────────────────────────────────────────────────────

  Future<void> startRecording() async {
    if (!await hasPermission()) return;
    final dir = await getTemporaryDirectory();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: '${dir.path}/${_getOrCreateAudioName()}',
    );
  }

  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) return null;
    _tempAudioPath = await _recorder.stop();
    _hasRemovedAudio = false;
    return _tempAudioPath;
  }

  Future<void> pauseRecording() => _recorder.pause();
  Future<void> resumeRecording() => _recorder.resume();

  // ─── File management ──────────────────────────────────────────────────────

  Future<void> deleteFile() async {
    if (_tempAudioPath == null) return;
    final file = File(_tempAudioPath!);
    if (await file.exists()) await file.delete();
    _tempAudioPath = null;
    _hasRemovedAudio = true;
  }

  Future<String?> saveFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final destPath = '${dir.path}/${_getOrCreateAudioName()}';

    if (_hasRemovedAudio) {
      final file = File(destPath);
      if (await file.exists()) await file.delete();
      _hasRemovedAudio = false;
      return null;
    }

    if (_tempAudioPath == null) return null;

    final source = File(_tempAudioPath!);
    if (await source.exists()) {
      await source.copy(destPath);
      return _getOrCreateAudioName();
    }

    return null;
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  void dispose() => _recorder.dispose();
}