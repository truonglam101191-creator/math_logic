import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/pikachu_connect_game/util/connect_sounds.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:oziapi/ozi_api.dart';
import 'data/models.dart';
import 'logic/pikachu_board.dart';
import 'widgets/board_widget.dart';

class PikachuConnectGamePage extends StatefulWidget {
  const PikachuConnectGamePage({super.key});

  @override
  State<PikachuConnectGamePage> createState() => _PikachuConnectGamePageState();
}

class _PikachuConnectGamePageState extends State<PikachuConnectGamePage> {
  late PikachuBoardController _controller;
  final valueListenable = ValueNotifier<int>(0);
  final cols = (Device.width ~/ 45) % 2 == 0
      ? (Device.width ~/ 45)
      : (Device.width ~/ 45) + 1;
  Difficulty _currentDifficulty = Difficulty.easy;

  final _scrollController = ScrollController(initialScrollOffset: 20);

  final _scrollControllerVertical = ScrollController(initialScrollOffset: 45);

  BoardConfig _boardConfigForDifficulty(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return BoardConfig(rows: 15, cols: cols, types: 25);
      case Difficulty.medium:
        return BoardConfig(rows: 18, cols: cols, types: 25);
      case Difficulty.hard:
        return BoardConfig(rows: 22, cols: cols, types: 25);
    }
  }

  void _handleGameWon() {
    setState(() {
      if (_currentDifficulty == Difficulty.easy) {
        _currentDifficulty = Difficulty.medium;
      } else if (_currentDifficulty == Difficulty.medium) {
        _currentDifficulty = Difficulty.hard;
      } else {
        _currentDifficulty = Difficulty.easy;
      }
    });

    final newConfig = _boardConfigForDifficulty(_currentDifficulty);
    // Apply new difficulty (this resets the board and counters)
    _controller.applyDifficulty(newConfig);

    // Show simple feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Level up! ${_currentDifficulty.name.toUpperCase()}'),
      ),
    );
    _scrollController.jumpTo(10);
    _scrollControllerVertical.jumpTo(45);
  }

  @override
  void initState() {
    super.initState();

    final config = _boardConfigForDifficulty(_currentDifficulty);
    final style = TileStyle(
      const [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.cyan,
        Colors.teal,
        Colors.pink,
        Colors.indigo,
        Colors.lime,
        Colors.amber,
        Colors.brown,
        Colors.deepOrange,
        Colors.deepPurple,
        Colors.lightBlue,
        Colors.lightGreen,
        Colors.yellow,
        Colors.grey,
        Colors.blueGrey,
        Colors.indigoAccent,
        Colors.redAccent,
        Colors.greenAccent,
        Colors.blueAccent,
        Colors.orangeAccent,
        Colors.purpleAccent,
      ],
      iconBuilder: (context, type) {
        const icons = <IconData>[
          Icons.catching_pokemon,
          Icons.star,
          Icons.favorite,
          Icons.pets,
          Icons.bolt,
          Icons.casino,
          Icons.videogame_asset,
          Icons.face,
          Icons.ac_unit,
          Icons.local_florist,
          Icons.music_note,
          Icons.emoji_events,
          Icons.beach_access,
          Icons.sports_esports,
          Icons.camera_alt,
          Icons.fastfood,
          Icons.local_cafe,
          Icons.cake,
          Icons.flight,
          Icons.landscape,
          Icons.nature_people,
          Icons.directions_bike,
          Icons.movie,
          Icons.palette,
          Icons.lightbulb,
          Icons.icecream,
          Icons.sports_basketball,
          Icons.shopping_cart,
          Icons.lock,
          Icons.wifi,
          Icons.flash_on,
          Icons.thumb_up,
          Icons.school,
          Icons.work,
          Icons.book,
          Icons.headphones,
          Icons.watch,
          Icons.local_bar,
          Icons.emoji_people,
          Icons.landscape,
          Icons.shield,
          Icons.bug_report,
        ];
        final iconData = icons[type % icons.length];
        return Icon(iconData, color: Colors.white, size: 18);
      },
    );
    _controller = PikachuBoardController(
      config: config,
      style: style,
      onConnectionCountChanged: (v) => valueListenable.value = v,
      onGameWon: _handleGameWon,
    );
    ConnectSounds.initialize();
    ConnectSounds.playPowerBackgroundSound();
  }

  @override
  void dispose() {
    _controller.dispose();
    valueListenable.dispose();
    _scrollController.dispose();
    _scrollControllerVertical.dispose();
    ConnectSounds.stopBackgroundSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetsImages.images.backgroundConnect.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white54,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              top: kToolbarHeight,
              child: SafeArea(
                child: Builder(
                  builder: (context) {
                    final mq = MediaQuery.of(context);
                    final availableHeight =
                        mq.size.height - kToolbarHeight - mq.padding.top - 24;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Center(
                        child: SizedBox(
                          height: availableHeight,
                          child: PikachuBoardView(
                            controller: _controller,
                            tileSize: 45,
                            pathConnectionColor: theme.primaryColor,
                            scrollControllerVertical: _scrollControllerVertical,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: SafeArea(
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      //const SizedBox(width: 8),
                      // _DifficultyBar(
                      //   onSelect: (level) {
                      //     switch (level) {
                      //       case Difficulty.easy:
                      //         _controller.applyDifficulty(
                      //           const BoardConfig(rows: 15, cols: 10, types: 6),
                      //         );
                      //         break;
                      //       case Difficulty.medium:
                      //         _controller.applyDifficulty(
                      //           const BoardConfig(
                      //             rows: 18,
                      //             cols: 12,
                      //             types: 10,
                      //           ),
                      //         );
                      //         break;
                      //       case Difficulty.hard:
                      //         _controller.applyDifficulty(
                      //           const BoardConfig(
                      //             rows: 22,
                      //             cols: 14,
                      //             types: 14,
                      //           ),
                      //         );
                      //         break;
                      //     }
                      //   },
                      // ),
                      // const Spacer(),
                      ValueListenableBuilder(
                        valueListenable: valueListenable,
                        builder: (context, value, child) {
                          return Text(
                            'Points: ${_controller.successfulConnections}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _controller.reset,
                        icon: Icon(Icons.refresh, color: theme.primaryColor),
                      ),
                      IconButton(
                        onPressed: _controller.shuffle,
                        icon: Icon(Icons.shuffle, color: theme.primaryColor),
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.more_horiz, color: theme.primaryColor),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum Difficulty { easy, medium, hard }

// class _DifficultyBar extends StatelessWidget {
//   final void Function(Difficulty level) onSelect;
//   const _DifficultyBar({required this.onSelect});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).primaryColor;
//     final style = ElevatedButton.styleFrom(
//       backgroundColor: color,
//       minimumSize: const Size(64, 36),
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//     );
//     return Row(
//       children: [
//         ElevatedButton(
//           style: style,
//           onPressed: () => onSelect(Difficulty.easy),
//           child: const Text('Easy', style: TextStyle(color: Colors.white)),
//         ),
//         const SizedBox(width: 6),
//         ElevatedButton(
//           style: style,
//           onPressed: () => onSelect(Difficulty.medium),
//           child: const Text('Medium', style: TextStyle(color: Colors.white)),
//         ),
//         const SizedBox(width: 6),
//         ElevatedButton(
//           style: style,
//           onPressed: () => onSelect(Difficulty.hard),
//           child: const Text('Hard', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }
// class _StatusBar extends StatelessWidget {
//   final PikachuBoardController controller;
//   const _StatusBar({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final s = controller.state;
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [

//           const SizedBox(width: 16),
//           ElevatedButton.icon(
//             onPressed: controller.reset,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Reset'),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton.icon(
//             onPressed: controller.shuffle,
//             icon: const Icon(Icons.shuffle),
//             label: const Text('Shuffle'),
//           ),
//         ],
//       ),
//     );
//   }
// }
