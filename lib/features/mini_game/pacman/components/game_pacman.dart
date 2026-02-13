import 'dart:math';

import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/camera/camera_config.dart';
import 'package:bonfire/input/keyboard/keyboard.dart';
import 'package:bonfire/map/tiled/world_map_by_tiled.dart';
import 'package:bonfire/map/util/world_map_reader.dart';
import 'package:bonfire/widgets/bonfire_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../decoration/dot.dart';
import '../decoration/dot_power.dart';
import '../decoration/sensor_gate.dart';
import '../enemy/ghost.dart';
import '../player/pacman.dart';
import '../util/game_state.dart';
import '../widgets/interface_game.dart';
import '../widgets/virtual_controls.dart';
import 'package:provider/provider.dart';

class GamePacman extends StatefulWidget {
  static const double heightMap = 1004.0;
  static const double tileSize = 48.0;
  const GamePacman({Key? key}) : super(key: key);

  @override
  State<GamePacman> createState() => _GameState();
}

class _GameState extends State<GamePacman> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  BonfireGameInterface? _gameRef;
  bool _gameReady = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
    _setLandscapeOrientation();
  }

  @override
  void dispose() {
    _resetOrientation();
    super.dispose();
  }

  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitGame() {
    _resetOrientation();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeScreen = MediaQuery.of(context).size;
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Tính toán kích thước game phù hợp với orientation
    double gameSize;
    if (isLandscape) {
      // Landscape: sử dụng chiều cao màn hình làm kích thước game
      gameSize = sizeScreen.height * 0.9;
    } else {
      // Portrait: sử dụng kích thước nhỏ hơn
      gameSize = min(sizeScreen.width, sizeScreen.height);
    }

    return Container(
      color: Colors.black,
      child: FadeTransition(
        opacity: _controller,
        child: ListenableProvider(
          create: (context) => GameState(),
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: gameSize,
                  height: gameSize,
                  child: BonfireWidget(
                    map: WorldMapByTiled(
                      WorldMapReader.fromAsset('map.tmj'),
                      objectsBuilder: {
                        'sensor_left': (properties) => SensorGate(
                          position: properties.position,
                          direction: DiractionGate.left,
                        ),
                        'sensor_right': (properties) => SensorGate(
                          position: properties.position,
                          direction: DiractionGate.right,
                        ),
                        'dot': (properties) =>
                            Dot(position: properties.position),
                        'dot_power': (properties) =>
                            DotPower(position: properties.position),
                        'ghost_red': (properties) => Ghost(
                          position: properties.position,
                          type: GhostType.red,
                        ),
                        'ghost_pink': (properties) => Ghost(
                          position: properties.position,
                          type: GhostType.pink,
                        ),
                        'ghost_orange': (properties) => Ghost(
                          position: properties.position,
                          type: GhostType.orange,
                        ),
                        'ghost_blue': (properties) => Ghost(
                          position: properties.position,
                          type: GhostType.blue,
                        ),
                      },
                    ),
                    playerControllers: [Keyboard()],
                    overlayBuilderMap: {
                      'score': ((context, game) => const InterfaceGame()),
                    },
                    initialActiveOverlays: const ['score'],
                    cameraConfig: CameraConfig(
                      initialMapZoomFit: InitialMapZoomFitEnum.fit,
                      startFollowPlayer: false,
                      moveOnlyMapArea: true,
                    ),
                    player: PacMan(position: PacMan.initialPosition),
                    onReady: (game) {
                      _gameRef = game;
                      // Đợi thêm một chút để đảm bảo tất cả components đã được mount
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() {
                            _gameReady = true;
                          });
                          _controller.forward();
                        }
                      });
                    },
                  ),
                ),
              ),
              // Virtual controls cho mobile - chỉ hiển thị khi game đã sẵn sàng
              if (_gameReady && _gameRef != null)
                VirtualControls(gameRef: _gameRef!, onExit: _exitGame),
            ],
          ),
        ),
      ),
    );
  }
}
