import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:logic_mathematics/cores/adsmob/ads_mob.dart';
import 'package:logic_mathematics/features/mini_game/data_2024/components/empy_board.dart';
import 'package:logic_mathematics/features/mini_game/data_2024/components/tile_board.dart';
import 'package:logic_mathematics/features/mini_game/data_2024/managers/board.dart';
import 'package:logic_mathematics/main.dart';
import 'package:logic_mathematics/l10n/l10n.dart';

class Game extends ConsumerStatefulWidget {
  const Game({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameState();
}

class _GameState extends ConsumerState<Game>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //The contoller used to move the the tiles
  late final AnimationController _moveController =
      AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      )..addStatusListener((status) {
        //When the movement finishes merge the tiles and start the scale animation which gives the pop effect.
        if (status == AnimationStatus.completed) {
          ref.read(boardManager.notifier).merge();
          _scaleController.forward(from: 0.0);
        }
      });

  //The curve animation for the move animation controller.
  late final CurvedAnimation _moveAnimation = CurvedAnimation(
    parent: _moveController,
    curve: Curves.easeInOut,
  );

  //The contoller used to show a popup effect when the tiles get merged
  late final AnimationController _scaleController =
      AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      )..addStatusListener((status) {
        //When the scale animation finishes end the round and if there is a queued movement start the move controller again for the next direction.
        if (status == AnimationStatus.completed) {
          if (ref.read(boardManager.notifier).endRound()) {
            _moveController.forward(from: 0.0);
          }
        }
      });

  //The curve animation for the scale animation controller.
  late final CurvedAnimation _scaleAnimation = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    //Add an Observer for the Lifecycles of the App
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2B8CEE);
    const bg = Color(0xFFF6F7F8);
    const scoreBg = Color(0xFFEAF3FF);
    const bestBg = Color(0xFFFFE8D3);

    final score = ref.watch(boardManager.select((state) => state.score));
    final best = ref.watch(boardManager.select((state) => state.best));
    final l10n = context.l10n;

    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        //Move the tile with the arrows on the keyboard on Desktop
        if (ref.read(boardManager.notifier).onKey(event)) {
          _moveController.forward(from: 0.0);
        }
      },
      child: SwipeDetector(
        onSwipe: (direction, offset) {
          if (ref.read(boardManager.notifier).move(direction)) {
            _moveController.forward(from: 0.0);
          }
        },
        child: Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_ios_new,
                        background: primary.withOpacity(0.12),
                        color: primary,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Center(
                          child: Text(
                            l10n.game2048Header,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: Color(0xFF0D141B),
                            ),
                          ),
                        ),
                      ),
                      _CircleButton(
                        icon: Icons.lock,
                        background: const Color(0xFFFFF1C7),
                        color: const Color(0xFFDAA700),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.featureLockedMessage)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: l10n.scoreCardLabel,
                          value: '$score',
                          background: scoreBg,
                          textColor: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: l10n.bestCardLabel,
                          value: '$best',
                          background: bestBg,
                          textColor: const Color(0xFFD46A1E),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF2B8CEE),
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.aiHintBubble,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF5),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                children: [
                                  const EmptyBoardWidget(),
                                  TileBoardWidget(
                                    moveAnimation: _moveAnimation,
                                    scaleAnimation: _scaleAnimation,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.undo,
                          label: l10n.undo,
                          background: const Color(0xFFEFF1F5),
                          foreground: const Color(0xFF0D141B),
                          onTap: () {
                            serviceLocator
                                .get<AdmobController>()
                                .showInterstitialAd(
                                  callback: (isSuccess) {
                                    ref.read(boardManager.notifier).undo();
                                  },
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.refresh,
                          label: l10n.reset,
                          background: const Color(0xFFE3E7ED),
                          foreground: const Color(0xFF0D141B),
                          onTap: () {
                            serviceLocator
                                .get<AdmobController>()
                                .showInterstitialAd(
                                  callback: (isSuccess) {
                                    ref.read(boardManager.notifier).newGame();
                                  },
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.lightbulb,
                          label: l10n.aiHint,
                          background: primary,
                          foreground: Colors.white,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.featureLockedMessage),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7DBE3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Save current state when the app becomes inactive
    if (state == AppLifecycleState.inactive) {
      ref.read(boardManager.notifier).save();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    //Remove the Observer for the Lifecycles of the App
    WidgetsBinding.instance.removeObserver(this);

    //Dispose the animations.
    _moveAnimation.dispose();
    _scaleAnimation.dispose();
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.background,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.background,
    required this.textColor,
  });

  final String title;
  final String value;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0D141B),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
