import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider((ref) => AudioService());

class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  Future<void> playMusic() async {
    if (!_musicEnabled) return;
    // Assuming assets/audio/game_music.mp3 exists
    // await _musicPlayer.play(AssetSource('audio/game_music.mp3'));
    // _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (!_musicEnabled) return;
    await _musicPlayer.resume();
  }

  Future<void> playSfx(String soundName) async {
    if (!_sfxEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/$soundName.wav'));
  }

  void toggleMusic(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) stopMusic();
  }

  void toggleSfx(bool enabled) {
    _sfxEnabled = enabled;
  }
}
