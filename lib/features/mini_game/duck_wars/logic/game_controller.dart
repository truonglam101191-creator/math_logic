import 'dart:math';

import '../data/assets.dart' as assets_map;
import '../logic/duck.dart';

/// A lightweight game controller that holds state and updates ducks.
class GameController {
  final double logicalWidth;
  final double logicalHeight;

  final Random _rng = Random();
  final List<Duck> ducks = [];

  double spawnTimer = 0.0;
  bool running = false;
  int score = 0;
  double timerDuration = 60.0;
  double timeRemaining = 60.0;
  double _time = 0.0;
  String selectedGun = 'gun_plasma';
  bool lastSpawnFromLeft = true;

  GameController({this.logicalWidth = 360, this.logicalHeight = 640});

  void start() {
    running = true;
    score = 0;
    ducks.clear();
    spawnTimer = 0.5;
    timeRemaining = timerDuration;
    _time = 0.0;
  }

  void stop() {
    running = false;
  }

  void update(double dt) {
    if (!running) return;

    _time += dt;
    timeRemaining -= dt;
    if (timeRemaining <= 0) {
      timeRemaining = 0;
      running = false;
    }

    // Spawn logic
    spawnTimer -= dt;
    if (spawnTimer <= 0) {
      spawnDuck();
      spawnTimer = 0.8 + _rng.nextDouble() * 1.0; // next spawn
    }

    // Update ducks
    for (var d in ducks) {
      if (!d.alive) continue;
      d.x += d.vx * dt;
      d.y += d.vy * dt;
      // gently rotate based on vx sign
      d.rotation = d.vx >= 0 ? 0.05 * (1 + (d.phase)) : -0.05 * (1 + (d.phase));
      d.phase += dt * 2.0; // bobbing phase
      // simple bounds kill
      if (d.x < -d.size ||
          d.x > logicalWidth + d.size ||
          d.y < -d.size ||
          d.y > logicalHeight + d.size) {
        d.alive = false;
      }
    }

    // remove dead
    ducks.removeWhere((d) => !d.alive);
  }

  void spawnDuck() {
    // choose random duck asset
    final keys = assets_map.duckAssets.keys
        .where((k) => k.startsWith('cyber_duck'))
        .toList();
    final assetKey = keys[_rng.nextInt(keys.length)];
    final url = assets_map.duckAssets[assetKey]!;

    // spawn at left or right edge
    final fromLeft = _rng.nextBool();
    final y = 40.0 + _rng.nextDouble() * (logicalHeight - 120.0);
    final speed = 60.0 + _rng.nextDouble() * 120.0; // px per second
    final vx = fromLeft ? speed : -speed;
    final x = fromLeft ? -40.0 : logicalWidth + 40.0;
    final size = 36.0 + _rng.nextDouble() * 48.0;

    final d = Duck(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      assetUrl: url,
      x: x,
      y: y,
      vx: vx,
      vy: 0,
      size: size,
      points: 10,
      rotation: fromLeft ? 0.0 : 0.0,
      phase: _rng.nextDouble() * 6.28,
    );

    lastSpawnFromLeft = fromLeft;

    ducks.add(d);
  }

  /// Handle a tap in logical coordinates. Returns the hit [Duck] or null.
  Duck? handleTap(double tx, double ty) {
    // iterate from top (last) to bottom
    for (int i = ducks.length - 1; i >= 0; i--) {
      final d = ducks[i];
      final half = d.size / 2;
      if ((tx >= d.x - half && tx <= d.x + half) &&
          (ty >= d.y - half && ty <= d.y + half)) {
        // hit!
        d.alive = false;
        score += d.points;
        return d;
      }
    }
    return null;
  }

  /// Cycle the selected gun. Direction: -1 for previous, +1 for next.
  void cycleGun(int direction) {
    final guns = ['gun_plasma', 'gun_laser', 'gun_pulse', 'gun_cannon'];
    final idx = guns.indexOf(selectedGun);
    var newIdx = idx + direction;
    if (newIdx < 0) newIdx = guns.length - 1;
    if (newIdx >= guns.length) newIdx = 0;
    selectedGun = guns[newIdx];
  }
}
