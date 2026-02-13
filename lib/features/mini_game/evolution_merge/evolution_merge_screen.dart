import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'data/data.dart';
import 'logic/logic.dart';
import 'widgets/widgets.dart';

/// Main screen for the Evolution Merge game
class EvolutionMergeScreen extends StatefulWidget {
  const EvolutionMergeScreen({super.key});

  @override
  State<EvolutionMergeScreen> createState() => _EvolutionMergeScreenState();
}

class _EvolutionMergeScreenState extends State<EvolutionMergeScreen> {
  late EvolutionGameController _controller;
  late AssetLoaderService _assetLoader;
  bool _isLoading = true;
  double _loadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = EvolutionGameController();
    _assetLoader = AssetLoaderService();

    // Setup callbacks
    _controller.onMerge = _onMerge;
    _controller.onDrop = _onDrop;
    _controller.onGameOver = _onGameOver;
    _controller.onVictory = _onVictory;
    _controller.onScoreUpdate = _onScoreUpdate;

    // Load assets after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssets();
    });
  }

  Future<void> _loadAssets() async {
    // Preload assets with progress tracking
    try {
      await _assetLoader.preloadAssets(context);

      // Update progress from asset loader
      if (mounted) {
        setState(() => _loadProgress = _assetLoader.loadProgress);
      }
    } catch (e) {
      debugPrint('Asset loading error: $e');
    }

    if (mounted) {
      // Load saved high score
      // TODO: Implement SharedPreferences or other storage
      _controller.init(savedHighScore: 0);

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMerge() {
    // TODO: Play merge sound
    debugPrint('Merge!');
  }

  void _onDrop() {
    // TODO: Play drop sound
    debugPrint('Drop!');
  }

  void _onGameOver() {
    // TODO: Play game over sound
    // TODO: Save high score
    debugPrint('Game Over! Score: ${_controller.score}');
  }

  void _onVictory() {
    // TODO: Play victory sound
    debugPrint('Victory! Score: ${_controller.score}');
  }

  void _onScoreUpdate(int score) {
    debugPrint('Score: $score');
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final scale = constraints.maxWidth / GameConstants.canvasWidth;
    final x = details.localPosition.dx / scale;
    _controller.updateDropPosition(x);
  }

  void _handleTap() {
    _controller.dropItem();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: _isLoading
            ? LoadingScreen(progress: _loadProgress)
            : _buildGameContent(),
      ),
    );
  }

  Widget _buildGameContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background
            _buildBackground(),

            // Game area
            Column(
              children: [
                const SizedBox(height: 16),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return GameHeader(
                        score: _controller.score,
                        highScore: _controller.highScore,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Evolution legend
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: EvolutionLegend(),
                ),

                const SizedBox(height: 8),

                // Game canvas
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: (details) =>
                        _handlePanUpdate(details, constraints),
                    onTapUp: (_) => _handleTap(),
                    child: GameCanvas(
                      controller: _controller,
                      backgroundWidget: _buildGameBackground(),
                    ),
                  ),
                ),
              ],
            ),

            // Overlay screens
            _buildOverlayScreens(),
          ],
        );
      },
    );
  }

  Widget _buildBackground() {
    final bgUrl = EvolutionAssetUrls.getImageUrl('background_primordial');
    if (bgUrl == null) {
      return Container(color: const Color(0xFF2d1b4e));
    }

    return Positioned.fill(
      child: CachedNetworkImage(
        imageUrl: bgUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFF2d1b4e)),
        errorWidget: (_, __, ___) => Container(color: const Color(0xFF2d1b4e)),
      ),
    );
  }

  Widget _buildGameBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade900.withOpacity(0.3),
            Colors.indigo.shade900.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayScreens() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        switch (_controller.state.status) {
          case GameStatus.ready:
            return StartScreen(onPlay: _controller.startGame);

          case GameStatus.gameOver:
            return GameOverScreen(
              score: _controller.score,
              isNewHighScore: _controller.state.isNewHighScore,
              onRestart: _controller.restartGame,
            );

          case GameStatus.victory:
            return VictoryScreen(
              score: _controller.score,
              onRestart: _controller.restartGame,
            );

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
