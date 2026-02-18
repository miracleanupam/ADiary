import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final _player = AudioPlayer();

  Future<void> play(String filePath) async {
    await _player.play(DeviceFileSource(filePath));
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  /// Listen to player state changes
  Stream<PlayerState> get onStateChanged => _player.onPlayerStateChanged;

  /// Listen to position changes (for seek bar)
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  /// Get total duration
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  void dispose() {
    _player.dispose();
  }
}