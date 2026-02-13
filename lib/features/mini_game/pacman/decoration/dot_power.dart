import 'package:bonfire/bonfire.dart';
import '../player/pacman.dart';
import '../util/game_state.dart';
import '../util/util_spritesheet.dart';
import 'package:provider/provider.dart';

class DotPower extends GameDecoration with Sensor {
  bool givePower = false;
  late GameState _gameState;
  DotPower({required super.position})
    : super.withAnimation(
        animation: UtilSpriteSheet.dotPower,
        size: Vector2.all(18),
      );

  @override
  void onContact(GameComponent component) {
    if (component is PacMan) {
      if (!givePower) {
        givePower = true;
        removeFromParent();
        _gameState.startPacManPower();
      }
    }
  }

  @override
  void onMount() {
    _gameState = context.read();
    super.onMount();
  }
}
