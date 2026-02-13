import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Service for playing game sounds
class SoundService {
  final Map<String, AudioPlayer> _players = {};
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.7;
  double _musicVolume = 0.5;

  // Sound effect types
  static const String pickUp = 'pick_up';
  static const String drop = 'drop';
  static const String correctPlace = 'correct_place';
  static const String incorrectPlace = 'incorrect_place';
  static const String levelComplete = 'level_complete';
  static const String buttonClick = 'button_click';
  static const String hint = 'hint';
  static const String streak = 'streak';

  /// Get or create player for sound
  AudioPlayer _getPlayer(String soundId) {
    return _players.putIfAbsent(soundId, () => AudioPlayer());
  }

  /// Play sound effect
  Future<void> playSound(String soundId, {String? url}) async {
    if (!_soundEnabled) return;

    try {
      final player = _getPlayer(soundId);
      await player.setVolume(_soundVolume);

      if (url != null) {
        await player.play(UrlSource(url));
      } else {
        // Use default sounds based on soundId
        final assetPath = _getDefaultSoundPath(soundId);
        await player.play(AssetSource(assetPath));
      }
    } catch (e) {
      debugPrint('Failed to play sound $soundId: $e');
    }
  }

  /// Get default sound path
  String _getDefaultSoundPath(String soundId) {
    switch (soundId) {
      case pickUp:
        return 'audio/sortie/pick_up.mp3';
      case drop:
        return 'audio/sortie/drop.mp3';
      case correctPlace:
        return 'audio/sortie/correct.mp3';
      case incorrectPlace:
        return 'audio/sortie/incorrect.mp3';
      case levelComplete:
        return 'audio/sortie/complete.mp3';
      case buttonClick:
        return 'audio/sortie/click.mp3';
      case hint:
        return 'audio/sortie/hint.mp3';
      case streak:
        return 'audio/sortie/streak.mp3';
      default:
        return 'audio/sortie/click.mp3';
    }
  }

  /// Play background music
  Future<void> playMusic(String url, {bool loop = true}) async {
    if (!_musicEnabled) return;

    try {
      final player = _getPlayer('bgm');
      await player.setVolume(_musicVolume);
      await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      await player.play(UrlSource(url));
    } catch (e) {
      debugPrint('Failed to play music: $e');
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    try {
      await _players['bgm']?.stop();
    } catch (e) {
      debugPrint('Failed to stop music: $e');
    }
  }

  /// Toggle sound effects
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  /// Toggle music
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      stopMusic();
    }
  }

  /// Set sound volume
  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
  }

  /// Set music volume
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _players['bgm']?.setVolume(_musicVolume);
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Check if music is enabled
  bool get isMusicEnabled => _musicEnabled;

  /// Dispose all players
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
