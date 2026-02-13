import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_theme.dart';
import 'data/repositories/game_config_repository.dart';
import 'logic/sortie_game_state.dart';
import 'services/services.dart';
import 'widgets/widgets.dart';

/// Main page for the Sortie (Tidy Tinker) game
class SortiePage extends StatefulWidget {
  const SortiePage({super.key});

  @override
  State<SortiePage> createState() => _SortiePageState();
}

class _SortiePageState extends State<SortiePage> with TickerProviderStateMixin {
  // Services
  late final GameConfigRepository _configRepository;
  late final AssetLoaderService _assetLoader;
  late final SoundService _soundService;

  // Game state
  late final SortieGameState _gameState;

  // Animation controllers
  late final AnimationController _sparkleController;
  late final AnimationController _bounceController;

  // Loading state
  bool _isLoading = true;
  String _loadingMessage = 'Loading game...';
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _configRepository = GameConfigRepository();
    _assetLoader = AssetLoaderService(repository: _configRepository);
    _soundService = SoundService();
    _gameState = SortieGameState();

    // Animation controllers
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Listen to asset loading progress
    _assetLoader.loadingProgress.addListener(_onLoadingProgress);

    // Initialize game
    _initializeGame();
  }

  void _onLoadingProgress() {
    setState(() {
      _loadingProgress = _assetLoader.loadingProgress.value;
    });
  }

  Future<void> _initializeGame() async {
    try {
      setState(() {
        _loadingMessage = 'Loading configuration...';
      });

      // Load game configuration
      final config = await _configRepository.loadConfig();

      setState(() {
        _loadingMessage = 'Loading assets...';
      });

      // Preload assets for current theme
      await _assetLoader.preloadThemeAssets(config.currentTheme);

      // Initialize game state
      _gameState.initialize(config);
      _gameState.addListener(_onGameStateChanged);

      // Start background music
      final backgroundMusicUrl = await _assetLoader.getAssetUrl(
        _gameState.currentTheme?.backgroundMusic ?? 'ambient_music',
      );
      if (backgroundMusicUrl != null) {
        _soundService.playMusic(backgroundMusicUrl);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to initialize game: $e');
      setState(() {
        _loadingMessage = 'Failed to load game: $e';
      });
    }
  }

  void _onGameStateChanged() {
    setState(() {});

    // Play sounds based on state changes
    if (_gameState.gameCompleted) {
      _soundService.playSound(SoundService.levelComplete);
      _sparkleController.repeat();
    }
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    _assetLoader.loadingProgress.removeListener(_onLoadingProgress);
    _sparkleController.dispose();
    _bounceController.dispose();
    _assetLoader.dispose();
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Game canvas
          _buildGameCanvas(),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GameHeader(
              gameState: _gameState,
              onMenuPressed: _showMenu,
              onHintPressed: _showHint,
              onResetPressed: _resetGame,
            ),
          ),

          // Celebration overlay
          if (_gameState.gameCompleted)
            CelebrationOverlay(
              score: _gameState.currentScore,
              completedCount: _gameState.completedCount,
              streak: _gameState.longestStreak,
              completionTime: _gameState.formattedCompletionTime,
              onNextLevel: _nextLevel,
              onReplay: _resetGame,
              onMenu: _showMenu,
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game icon/logo
              const Icon(Icons.sort, size: 80, color: Colors.white),
              const SizedBox(height: 24),

              // Game title
              const Text(
                'Tidy Tinker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Loading progress
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMessage,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCanvas() {
    return Container(
      color:
          _gameState.currentTheme?.backgroundColor ?? const Color(0xFFF5F5DC),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Update canvas size for responsive layout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _gameState.updateCanvasSize(constraints.biggest);
          });

          return GestureDetector(
            onPanStart: (details) =>
                _handlePanStart(details, constraints.biggest),
            onPanUpdate: (details) =>
                _handlePanUpdate(details, constraints.biggest),
            onPanEnd: (_) => _handlePanEnd(),
            child: CustomPaint(
              size: constraints.biggest,
              painter: SortieGamePainter(
                gameState: _gameState,
                imageCache: _assetLoader.imageCache,
                animation: _sparkleController,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handlePanStart(DragStartDetails details, Size canvasSize) {
    final position = details.localPosition;
    if (_gameState.startDragging(position)) {
      _soundService.playSound(SoundService.pickUp);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size canvasSize) {
    _gameState.updateDragging(details.localPosition, canvasSize);
  }

  void _handlePanEnd() {
    final item = _gameState.draggingItem;
    _gameState.endDragging();

    if (item != null) {
      if (item.isPlaced) {
        _soundService.playSound(SoundService.correctPlace);
        _bounceController.forward().then((_) => _bounceController.reset());
      } else {
        _soundService.playSound(SoundService.drop);
      }
    }
  }

  void _showMenu() {
    showLevelSelector(
      context,
      currentLevel: _gameState.currentLevel,
      maxLevels: _gameState.maxLevels,
      unlockedLevels: _gameState.unlockedLevels,
      onLevelSelected: (level) async {
        _gameState.switchToLevel(level);
        final themeName = GameTheme.levelOrder[level - 1];
        await _assetLoader.preloadThemeAssets(themeName);
      },
    );
  }

  void _showHint() {
    _soundService.playSound(SoundService.hint);
    _gameState.showHint();
  }

  void _resetGame() {
    _soundService.playSound(SoundService.buttonClick);
    _gameState.resetGame();
    _sparkleController.reset();
  }

  void _nextLevel() {
    _sparkleController.reset();
    _gameState.nextLevel();

    // Preload next theme assets
    final themeName = GameTheme.levelOrder[_gameState.currentLevel - 1];
    _assetLoader.preloadThemeAssets(themeName);
  }
}
