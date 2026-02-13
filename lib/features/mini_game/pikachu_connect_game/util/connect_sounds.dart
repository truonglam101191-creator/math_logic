// ignore_for_file: empty_catches

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class ConnectSounds {
  static Future initialize() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'connect_background.wav',
      'tap_connect.wav',
      'connect_yay.wav',
    ]);
  }

  static String _currentBackground = '';

  static stopBackgroundSound() {
    _currentBackground = '';
    return FlameAudio.bgm.stop();
  }

  static void playPowerBackgroundSound() async {
    String name = 'connect_background.wav';
    if (_currentBackground == name) {
      return;
    }
    await FlameAudio.bgm.stop();
    _currentBackground = name;
    FlameAudio.bgm.play(name);
  }

  static void playTapSound() {
    try {
      FlameAudio.play('tap_connect.wav');
    } catch (e) {
      debugPrint(e.toString());
      FlameAudio.play('tap_connect.wav');
    }
  }

  static void connectSuccessSound() {
    try {
      FlameAudio.play('connect_yay.wav');
    } catch (e) {
      debugPrint(e.toString());
      FlameAudio.play('tap_connect.wav');
    }
  }

  // static void playRetreatingBackgroundSound() async {
  //   String name = 'retreating.wav';
  //   if (_currentBackground == name) {
  //     return;
  //   }
  //   await FlameAudio.bgm.stop();
  //   _currentBackground = name;
  //   FlameAudio.bgm.play(name);
  // }

  static void pauseBackgroundSound() {
    FlameAudio.bgm.pause();
  }

  static void resumeBackgroundSound() {
    FlameAudio.bgm.resume();
  }

  static void dispose() {
    FlameAudio.bgm.dispose();
  }
}
