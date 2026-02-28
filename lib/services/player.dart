import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final _player = AudioPlayer();

  Future<void> play(String filePath) => _player.play(DeviceFileSource(filePath));
  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.resume();
  Future<void> stop() => _player.stop();
  Future<void> seek(int ms) => _player.seek(Duration(milliseconds: ms));

  Stream<PlayerState> get onStateChanged => _player.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  void dispose() => _player.dispose();
}