import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static const String keySfxEnabled = 'key_sfx_enabled';
  static const String keyBgmEnabled = 'key_bgm_enabled';

  bool _isSfxEnabled = true;
  bool _isBgmEnabled = true;

  bool get isSfxEnabled => _isSfxEnabled;
  bool get isBgmEnabled => _isBgmEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSfxEnabled = prefs.getBool(keySfxEnabled) ?? true;
    _isBgmEnabled = prefs.getBool(keyBgmEnabled) ?? true;

    // Load common audio files if needed
    // Example: await FlameAudio.audioCache.loadAll(['click.mp3', 'win.mp3']);
  }

  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySfxEnabled, _isSfxEnabled);
  }

  Future<void> toggleBgm() async {
    _isBgmEnabled = !_isBgmEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyBgmEnabled, _isBgmEnabled);
    if (!_isBgmEnabled) {
      stopBgm();
    } else {
      // Re-play current BGM if we store it
    }
  }

  void playClick() {
    if (!_isSfxEnabled) return;
    try {
      // Create a click.mp3 in assets/audio/ or comment this out until asset is provided
      // FlameAudio.play('click.mp3');
      debugPrint('Playing click sound');
    } catch (e) {
      debugPrint('Error playing click sound: $e');
    }
  }

  void playWin() {
    if (!_isSfxEnabled) return;
    try {
      // FlameAudio.play('win.mp3');
      debugPrint('Playing win sound');
    } catch (e) {
      debugPrint('Error playing win sound: $e');
    }
  }

  void playBgm(String path) {
    if (!_isBgmEnabled) return;
    try {
      // FlameAudio.bgm.play(path);
      debugPrint('Playing BGM: $path');
    } catch (e) {
      debugPrint('Error playing bgm: $e');
    }
  }

  void stopBgm() {
    try {
      // FlameAudio.bgm.stop();
      debugPrint('Stopping BGM');
    } catch (e) {
      debugPrint('Error stopping bgm: $e');
    }
  }
}
