import 'package:bonfire/bonfire.dart';
import 'package:logic_mathematics/features/mini_game/pacman/components/game_pacman.dart';
import '../util/util_spritesheet.dart';

class EatScore extends GameDecoration with Movement, HandleForces {
  EatScore({required super.position})
    : super.withSprite(
        size: Vector2.all(GamePacman.tileSize),
        sprite: UtilSpriteSheet.score100,
      ) {
    speed = 140;
    renderAboveComponents = true;
    addForce(ResistanceForce2D(id: 1, value: Vector2(4, 4)));
  }

  @override
  void update(double dt) {
    if (velocity.y.abs() < 5 && !isRemoving) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onMount() {
    super.onMount();
    moveUp();
  }
}
