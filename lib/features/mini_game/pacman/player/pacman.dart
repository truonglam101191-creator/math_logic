import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/pacman/components/game_pacman.dart';
import '../decoration/dot.dart';
import '../decoration/eat_score.dart';
import '../enemy/ghost.dart';
import 'custom_movement_by_joystick.dart';
import 'pacman_spritesheet.dart';
import '../util/game_state.dart';
import '../util/sounds.dart';
import '../widgets/congratulation_dialog.dart';
import '../widgets/game_over_dialog.dart';
import 'package:provider/provider.dart';

class PacMan extends SimplePlayer
    with BlockMovementCollision, CustomMovementByJoystick {
  static final Vector2 initialPosition = Vector2(
    9 * GamePacman.tileSize,
    15 * GamePacman.tileSize,
  );
  bool firstSoundMunch = false;
  bool youAreWinner = false;
  late GameState _gameState;
  async.Timer? _debounceSound;

  PacMan({required super.position})
    : super(
        size: Vector2.all(GamePacman.tileSize),
        speed: 150,
        animation: SimpleDirectionAnimation(
          idleRight: PacManSpriteSheet.idle,
          runRight: PacManSpriteSheet.runRight,
          runUp: PacManSpriteSheet.runUp,
          enabledFlipY: true,
        ),
      );

  @override
  void update(double dt) {
    _checkIfWinner(dt);
    _checkContactWithDot(dt);
    super.update(dt);
  }

  @override
  void onMount() {
    _gameState = context.read();
    super.onMount();
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (other is Ghost) {
      if (other.state == GhostState.vulnerable) {
        _incrementScore();
        other.bite();
      } else if (other.state == GhostState.normal) {
        if (!isDead) {
          idle();
          removeLife(100);
        }
      }
      return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void onBlockedMovement(PositionComponent other, CollisionData collisionData) {
    super.onBlockedMovement(other, collisionData);
    idle();
  }

  @override
  void onDie() {
    Sounds.stopBackgroundSound();
    Sounds.death();
    _gameState.decrementLife();
    animation?.playOnce(
      PacManSpriteSheet.die,
      onFinish: () {
        if (_gameState.lifes == 0) {
          async.Future.delayed(Duration.zero, () {
            if (context.mounted) {
              GameOverDialog.show(context);
            }

            removeFromParent();
          });
        } else {
          position = initialPosition;
          idle();
          updateLife(maxLife);
        }
      },
      runToTheEnd: true,
    );
    super.onDie();
  }

  void _checkIfWinner(double dt) {
    if (checkInterval('winner', 1000, dt) && !youAreWinner) {
      bool winner = gameRef.query<Dot>().isEmpty;
      if (winner) {
        youAreWinner = true;
        CongratulationsDialog.show(context);
      }
    }
  }

  void eatDot() {
    debounce(() {
      Sounds.munch(first: firstSoundMunch);
      firstSoundMunch = !firstSoundMunch;
    });
    _gameState.incrementScore();
  }

  void debounce(VoidCallback call) {
    if (_debounceSound?.isActive ?? false) {
      return;
    }
    _debounceSound = async.Timer(const Duration(milliseconds: 100), call);
  }

  void _incrementScore() {
    gameRef.add(EatScore(position: position));
    _gameState.incrementScore(value: 200);
  }

  @override
  async.Future<void> onLoad() {
    add(RectangleHitbox(size: size / 1.5, position: size / 6));
    return super.onLoad();
  }

  void _checkContactWithDot(double dt) {
    if (checkInterval('check_dot', 250, dt)) {
      final dots = gameRef.query<Dot>().where((e) {
        return e.rectCollision.overlaps(rectCollision);
      });
      if (dots.isNotEmpty) {
        for (var other in dots) {
          if (!other.eated) {
            other.eated = true;
            eatDot();
            other.removeFromParent();
          }
        }
      }
    }
  }
}
