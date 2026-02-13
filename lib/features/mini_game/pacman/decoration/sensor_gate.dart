import 'package:bonfire/bonfire.dart';
import 'package:logic_mathematics/features/mini_game/pacman/components/game_pacman.dart';

enum DiractionGate { left, right }

class SensorGate extends GameDecoration with Sensor {
  bool canMove = true;
  final DiractionGate direction;
  SensorGate({required super.position, this.direction = DiractionGate.left})
    : super(size: Vector2.all(GamePacman.tileSize));

  @override
  void onContact(GameComponent component) {
    if (canMove) {
      canMove = false;
      switch (direction) {
        case DiractionGate.left:
          component.position = component.position.copyWith(
            x: 18 * GamePacman.tileSize,
          );
          break;
        case DiractionGate.right:
          component.position = component.position.copyWith(x: 0);
          break;
      }
    }
  }

  @override
  void onContactExit(GameComponent component) {
    canMove = true;
  }
}
