import 'package:bonfire/bonfire.dart';
import 'package:logic_mathematics/features/mini_game/pacman/components/game_pacman.dart';

class UtilSpriteSheet {
  static Future<Sprite> dot = Sprite.load('dot.png');

  static Future<SpriteAnimation> get dotPower => SpriteAnimation.load(
    'dot_power.png',
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: 0.4,
      textureSize: Vector2.all(18),
    ),
  );

  static Future<Sprite> get score100 => Sprite.load(
    'pacman-sprites.png',
    srcSize: Vector2.all(48),
    srcPosition: Vector2(4 * GamePacman.tileSize, 7 * GamePacman.tileSize),
  );

  static Future<Sprite> get pacman => Sprite.load(
    'pacman-sprites.png',
    srcSize: Vector2.all(48),
    srcPosition: Vector2(1 * GamePacman.tileSize, 0),
  );
}
