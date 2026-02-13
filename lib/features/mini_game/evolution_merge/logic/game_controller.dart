import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/data.dart';
import 'physics_controller.dart';

/// Main game controller for Evolution Merge
class EvolutionGameController extends ChangeNotifier {
  late PhysicsController _physics;
  late EvolutionGameState _state;
  Timer? _gameLoop;
  final Random _random = Random();

  // Callbacks
  VoidCallback? onMerge;
  VoidCallback? onDrop;
  VoidCallback? onGameOver;
  VoidCallback? onVictory;
  Function(int)? onScoreUpdate;

  EvolutionGameController() {
    _physics = PhysicsController();
    _state = EvolutionGameState(dropX: GameConstants.canvasWidth / 2);
  }

  EvolutionGameState get state => _state;
  List<EvolutionItem> get items => _state.items;
  int get score => _state.score;
  int get highScore => _state.highScore;
  bool get isPlaying => _state.isPlaying;
  bool get isGameOver => _state.isGameOver;
  bool get isVictory => _state.isVictory;

  /// Initialize the game
  void init({int? savedHighScore}) {
    if (savedHighScore != null) {
      _state.highScore = savedHighScore;
    }
    _state.status = GameStatus.ready;
    notifyListeners();
  }

  /// Start a new game
  void startGame() {
    _physics.reset();
    _state.reset(GameConstants.canvasWidth / 2);
    _state.status = GameStatus.playing;
    _state.nextItemType = _getRandomDropType();

    _startGameLoop();
    notifyListeners();
  }

  /// Restart the game
  void restartGame() {
    _stopGameLoop();
    startGame();
  }

  /// Pause the game
  void pauseGame() {
    if (_state.isPlaying) {
      _state.status = GameStatus.paused;
      _stopGameLoop();
      notifyListeners();
    }
  }

  /// Resume the game
  void resumeGame() {
    if (_state.status == GameStatus.paused) {
      _state.status = GameStatus.playing;
      _startGameLoop();
      notifyListeners();
    }
  }

  /// Update drop position based on input
  void updateDropPosition(double x) {
    if (!_state.isPlaying) return;

    _state.dropX = x.clamp(GameConstants.minDropX, GameConstants.maxDropX);
    notifyListeners();
  }

  /// Drop the current item
  void dropItem() {
    if (!_state.canDrop || _state.nextItemType == null) return;

    _state.isDropping = true;
    notifyListeners();

    // Create the item
    final typeIndex = _state.nextItemType!;
    final type = EvolutionTypes.getType(typeIndex);

    final item = EvolutionItem(
      id: _generateId(),
      typeIndex: typeIndex,
      visualSize: type.size,
    );

    // Create physics body
    item.body = _physics.createBody(
      x: _state.dropX,
      y: GameConstants.dropY,
      radius: type.physicsRadius,
      typeIndex: typeIndex,
      userData: item,
    );

    // Nudge new body sideways so stacked drops do not sit perfectly vertical
    final horizontalKick = (_random.nextDouble() * 2 - 1) * 60; // px/s
    item.body!.velocity.x = horizontalKick;
    item.body!.angularVelocity = (_random.nextDouble() * 2 - 1) * 0.8;

    _state.items.add(item);

    // Generate next item
    _state.nextItemType = _getRandomDropType();

    onDrop?.call();

    // Reset dropping flag after cooldown
    Future.delayed(
      Duration(milliseconds: GameConstants.dropCooldownMs.toInt()),
      () {
        _state.isDropping = false;
        notifyListeners();
      },
    );

    notifyListeners();
  }

  void _startGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 FPS
      (_) => _update(),
    );
  }

  void _stopGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = null;
  }

  void _update() {
    if (!_state.isPlaying) return;

    // Step physics
    _physics.step(1 / 60);

    // Check for merges
    _checkMerges();

    // Check for game over
    _checkGameOver();

    notifyListeners();
  }

  void _checkMerges() {
    final collisions = _physics.getCollisions();
    final processedPairs = <String>{};

    for (final collision in collisions) {
      final itemA = collision.bodyA.userData as EvolutionItem?;
      final itemB = collision.bodyB.userData as EvolutionItem?;

      if (itemA == null || itemB == null) continue;
      if (itemA.markedForDeletion || itemB.markedForDeletion) continue;
      if (itemA.typeIndex != itemB.typeIndex) continue;
      if (itemA.typeIndex >= EvolutionTypes.maxLevel) continue;

      // Create unique pair key to avoid double processing
      final pairKey = [itemA.id, itemB.id]..sort();
      final pairId = pairKey.join('-');
      if (processedPairs.contains(pairId)) continue;
      processedPairs.add(pairId);

      // Mark for deletion
      itemA.markedForDeletion = true;
      itemB.markedForDeletion = true;

      // Calculate merge position
      final midX = collision.contactPoint.x;
      final midY = collision.contactPoint.y;

      // Remove old bodies
      _physics.removeBody(itemA.body!);
      _physics.removeBody(itemB.body!);

      // Remove from list
      _state.items.removeWhere(
        (item) => item.id == itemA.id || item.id == itemB.id,
      );

      // Create new evolved item
      final newTypeIndex = itemA.typeIndex + 1;
      final newType = EvolutionTypes.getType(newTypeIndex);

      final newItem = EvolutionItem(
        id: _generateId(),
        typeIndex: newTypeIndex,
        visualSize: newType.size,
      );

      newItem.body = _physics.createBody(
        x: midX,
        y: midY,
        radius: newType.physicsRadius,
        typeIndex: newTypeIndex,
        userData: newItem,
      );

      _state.items.add(newItem);

      // Update score
      _state.score += newType.points;
      onScoreUpdate?.call(_state.score);
      onMerge?.call();

      // Check for victory
      if (newTypeIndex == EvolutionTypes.maxLevel) {
        _handleVictory();
        return;
      }
    }
  }

  void _checkGameOver() {
    // Check if any item crosses the upper limits
    bool hasOverflow = false;
    bool hardOverflow = false; // True when body crosses the actual top edge

    for (final item in _state.items) {
      if (item.body == null) continue;

      final body = item.body!;
      final itemTop = body.position.y - body.radius;

      // Hard limit: above container top means we should end soon
      final crossesTop = itemTop <= GameConstants.containerY + 4;

      // Softer danger zone: near the dashed line with low speed
      final crossesDanger = itemTop < GameConstants.dangerLineY;
      final velocity = body.velocity;
      final speed = velocity.length;
      final isLingeringNearTop = speed < 120 || velocity.y.abs() < 40;

      if (crossesTop) {
        hasOverflow = true;
        hardOverflow = true;
        break;
      }

      if (crossesDanger && isLingeringNearTop) {
        hasOverflow = true;
      }
    }

    if (hasOverflow) {
      _state.dangerStartTime ??= DateTime.now();
      final elapsed = DateTime.now().difference(_state.dangerStartTime!);

      // Faster timeout when crossing the actual top edge
      final timeoutMs = hardOverflow ? 700 : GameConstants.dangerTimeoutMs;
      if (elapsed.inMilliseconds > timeoutMs) {
        _handleGameOver();
      }
    } else {
      _state.dangerStartTime = null;
    }
  }

  void _handleGameOver() {
    _state.status = GameStatus.gameOver;
    _stopGameLoop();

    // Check for new high score
    if (_state.score > _state.highScore) {
      _state.highScore = _state.score;
      _state.isNewHighScore = true;
    }

    onGameOver?.call();
    notifyListeners();
  }

  void _handleVictory() {
    _state.status = GameStatus.victory;
    _stopGameLoop();

    // Check for new high score
    if (_state.score > _state.highScore) {
      _state.highScore = _state.score;
      _state.isNewHighScore = true;
    }

    onVictory?.call();
    notifyListeners();
  }

  int _getRandomDropType() {
    return _random.nextInt(4); // Only first 4 types for dropping
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }

  /// Check if danger line is active
  bool get isDangerActive => _state.dangerStartTime != null;

  /// Get next item type info
  EvolutionType? get nextItemType {
    if (_state.nextItemType == null) return null;
    return EvolutionTypes.getType(_state.nextItemType!);
  }

  @override
  void dispose() {
    _stopGameLoop();
    _physics.dispose();
    super.dispose();
  }
}
