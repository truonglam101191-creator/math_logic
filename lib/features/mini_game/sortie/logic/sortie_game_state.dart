import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_config.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_item.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_slot.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_theme.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/tray_shape.dart';

/// Game mode
enum GameMode { play, edit }

/// Game state management
class SortieGameState extends ChangeNotifier {
  // Design size (original game canvas)
  static const double designWidth = 720.0;
  static const double designHeight = 1280.0;

  // Current canvas size and scale
  Size _canvasSize = const Size(720, 1280);
  double _scaleX = 1.0;
  double _scaleY = 1.0;
  double _scale = 1.0;

  // Game configuration
  GameConfig? _config;
  GameTheme? _currentTheme;

  // Game mode
  GameMode _gameMode = GameMode.play;

  // Level information
  int _currentLevel = 1;
  int _maxLevels = 10;
  List<int> _unlockedLevels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Game objects
  List<GameItem> _items = [];
  List<GameSlot> _slots = [];
  List<TrayShape> _trayShapes = [];

  // Interaction state
  GameItem? _draggingItem;
  Offset _dragOffset = Offset.zero;
  GameItem? _selectedItem;
  GameSlot? _selectedSlot;

  // Game progress
  bool _gameCompleted = false;
  int _completedCount = 0;

  // Scoring
  int _currentScore = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  double _streakMultiplier = 1.0;
  bool _lastPlacementWasCorrect = true;

  // Timing
  DateTime? _gameStartTime;
  Duration _gameCompletionTime = Duration.zero;
  DateTime? _lastInteractionTime;

  // Hints
  bool _hintActive = false;
  GameItem? _hintItem;
  GameSlot? _hintSlot;

  // Getters
  GameConfig? get config => _config;
  GameTheme? get currentTheme => _currentTheme;
  GameMode get gameMode => _gameMode;
  int get currentLevel => _currentLevel;
  int get maxLevels => _maxLevels;
  List<int> get unlockedLevels => _unlockedLevels;
  List<GameItem> get items => _items;
  List<GameSlot> get slots => _slots;
  List<TrayShape> get trayShapes => _trayShapes;
  GameItem? get draggingItem => _draggingItem;
  GameItem? get selectedItem => _selectedItem;
  GameSlot? get selectedSlot => _selectedSlot;
  bool get gameCompleted => _gameCompleted;
  int get completedCount => _completedCount;
  int get totalItems => _items.length;
  int get currentScore => _currentScore;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  double get streakMultiplier => _streakMultiplier;
  bool get hintActive => _hintActive;
  GameItem? get hintItem => _hintItem;
  GameSlot? get hintSlot => _hintSlot;
  DateTime? get lastInteractionTime => _lastInteractionTime;
  Size get canvasSize => _canvasSize;
  double get scale => _scale;

  /// Update canvas size and recalculate scale
  void updateCanvasSize(Size size) {
    if (_canvasSize == size) return;

    _canvasSize = size;
    _scaleX = size.width / designWidth;
    _scaleY = size.height / designHeight;
    _scale = _scaleX < _scaleY ? _scaleX : _scaleY;

    // Regenerate layout with new scale
    _generateResponsiveLayout();
    notifyListeners();
  }

  /// Initialize game with configuration
  void initialize(GameConfig config) {
    _config = config;
    _currentLevel = config.currentLevel;
    _maxLevels = config.maxLevels;
    _unlockedLevels = config.unlockedLevels;
    _items = List.from(config.items);
    _slots = List.from(config.slots);
    _trayShapes = config.tray.shapes;

    // Set current theme
    final themeName = config.currentTheme;
    _currentTheme = GameTheme.themes[themeName];

    _resetGameState();
    notifyListeners();
  }

  /// Set game mode
  void setGameMode(GameMode mode) {
    _gameMode = mode;
    notifyListeners();
  }

  /// Switch to a specific level
  void switchToLevel(int level) {
    if (level < 1 || level > _maxLevels) return;

    _currentLevel = level;
    final themeName = GameTheme.levelOrder[level - 1];
    _currentTheme = GameTheme.themes[themeName];

    // Load level configuration if available
    _loadLevelConfiguration(themeName, level);

    _resetGameState();
    notifyListeners();
  }

  /// Load level configuration
  void _loadLevelConfiguration(String themeName, int level) {
    final levelKey = '${themeName}_level_$level';
    final levelConfig = _config?.levelConfigurations?[levelKey];

    if (levelConfig != null) {
      // Load saved configuration
      // TODO: Parse and apply level configuration
    } else {
      // Generate default configuration
      _generateDefaultConfiguration();
    }
  }

  /// Generate default configuration for current theme
  void _generateDefaultConfiguration() {
    _generateResponsiveLayout();
  }

  /// Generate responsive layout based on current canvas size
  void _generateResponsiveLayout() {
    final theme = _currentTheme;
    if (theme == null) return;

    final screenWidth = _canvasSize.width;
    final screenHeight = _canvasSize.height;

    // Calculate responsive sizes
    final itemCount = theme.items.length;

    // Header offset (for game header)
    final headerOffset = screenHeight * 0.10;

    // Calculate tray area - square tray in bottom half
    final trayTop = screenHeight * 0.42;
    final traySize = screenWidth * 0.88; // Square tray
    final trayLeft = (screenWidth - traySize) / 2;

    // Generate tray shape with rounded corners (coral/salmon color like reference)
    _trayShapes = [
      TrayShape(
        id: 'main_tray',
        x: trayLeft,
        y: trayTop,
        width: traySize,
        height: traySize,
        type: TrayShapeType.roundedRectangle,
        color: const Color(0xFFE88B6A), // Coral/salmon like reference
        cornerRadius: 24 * _scale,
        assetId: 'large_medical_tray', // Use tray image from CDN
      ),
    ];

    // Slot positions matching the tray image layout (relative to tray)
    // The tray image has specific compartment positions
    final slotConfigs = _getTraySlotConfigurations(trayLeft, trayTop, traySize);

    // Generate slots based on tray image compartments
    _slots = List.generate(itemCount.clamp(0, slotConfigs.length), (index) {
      final themeItem = theme.items[index];
      final config = slotConfigs[index];

      return GameSlot(
        id: 'slot_$index',
        x: config['x']!,
        y: config['y']!,
        width: config['width']!,
        height: config['height']!,
        shape: config['shape'] == 1
            ? SlotShape.oval
            : SlotShape.roundedRectangle,
        itemId: themeItem.id,
        borderColor: Colors.transparent, // Hidden - slots inside tray image
        backgroundColor: Colors.transparent,
        borderRadius: 12 * _scale,
      );
    });

    // Calculate item area (above tray)
    final itemAreaTop = headerOffset;
    final itemAreaHeight = trayTop - headerOffset - screenHeight * 0.03;
    final itemsPerRow = 5;
    final itemHorizontalPadding = screenWidth * 0.04;
    final itemSpacing = screenWidth * 0.02;
    final availableItemWidth =
        screenWidth -
        (itemHorizontalPadding * 2) -
        (itemSpacing * (itemsPerRow - 1));
    final itemSize = (availableItemWidth / itemsPerRow).clamp(
      40.0,
      screenWidth * 0.16,
    );

    final itemRows = (itemCount / itemsPerRow).ceil();
    final itemRowHeight = itemAreaHeight / itemRows;

    // Generate items scattered in top area
    _items = List.generate(itemCount, (index) {
      final themeItem = theme.items[index];
      final row = index ~/ itemsPerRow;
      final col = index % itemsPerRow;

      // Add some randomness to item positions for natural look
      final randomOffsetX = ((index * 7) % 20 - 10) * _scale;
      final randomOffsetY = ((index * 13) % 16 - 8) * _scale;
      final randomRotation = ((index * 11) % 30 - 15) * 0.015;

      final x =
          itemHorizontalPadding +
          col * (itemSize + itemSpacing) +
          randomOffsetX;
      final y =
          itemAreaTop +
          row * itemRowHeight +
          (itemRowHeight - itemSize) / 2 +
          randomOffsetY;

      return GameItem(
        id: themeItem.id,
        assetId: themeItem.assetId,
        name: themeItem.name,
        x: x,
        y: y,
        startX: x,
        startY: y,
        width: itemSize,
        height: itemSize,
        color: themeItem.color,
        rotation: randomRotation,
      );
    });
  }

  /// Get slot configurations matching the tray image compartments
  /// Based on the large_medical_tray image layout (4 cols x 3 rows with varied sizes)
  List<Map<String, double>> _getTraySlotConfigurations(
    double trayLeft,
    double trayTop,
    double traySize,
  ) {
    // Padding and spacing relative to tray size
    final padding = traySize * 0.04;
    final innerWidth = traySize - padding * 2;
    final innerHeight = traySize - padding * 2;

    // Row heights (3 rows)
    final rowHeight = innerHeight / 3;

    // Column widths (4 columns with varied widths)
    final col1Width = innerWidth * 0.22;
    final col2Width = innerWidth * 0.28;
    final col3Width = innerWidth * 0.28;
    final col4Width = innerWidth * 0.22;

    final col1X = trayLeft + padding;
    final col2X = col1X + col1Width;
    final col3X = col2X + col2Width;
    final col4X = col3X + col3Width;

    final row1Y = trayTop + padding;
    final row2Y = row1Y + rowHeight;
    final row3Y = row2Y + rowHeight;

    // 12 slot positions matching tray image (shape: 0=rect, 1=oval)
    return [
      // Row 1: oval, rect, rect, oval
      {
        'x': col1X,
        'y': row1Y,
        'width': col1Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 1,
      },
      {
        'x': col2X,
        'y': row1Y,
        'width': col2Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 0,
      },
      {
        'x': col3X,
        'y': row1Y,
        'width': col3Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 0,
      },
      {
        'x': col4X,
        'y': row1Y,
        'width': col4Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 1,
      },
      // Row 2: rect, oval, oval, rect
      {
        'x': col1X,
        'y': row2Y,
        'width': col1Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 0,
      },
      {
        'x': col2X,
        'y': row2Y,
        'width': col2Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 1,
      },
      {
        'x': col3X,
        'y': row2Y,
        'width': col3Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 1,
      },
      {
        'x': col4X,
        'y': row2Y,
        'width': col4Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 0,
      },
      // Row 3: rect, oval, rect, rect
      {
        'x': col1X,
        'y': row3Y,
        'width': col1Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 0,
      },
      {
        'x': col2X,
        'y': row3Y,
        'width': col2Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 1,
      },
      {
        'x': col3X,
        'y': row3Y,
        'width': col3Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 0,
      },
      {
        'x': col4X,
        'y': row3Y,
        'width': col4Width * 0.9,
        'height': rowHeight * 0.85,
        'shape': 0,
      },
    ];
  }

  /// Reset game state
  void _resetGameState() {
    _gameCompleted = false;
    _completedCount = 0;
    _currentScore = 0;
    _currentStreak = 0;
    _longestStreak = 0;
    _streakMultiplier = 1.0;
    _lastPlacementWasCorrect = true;
    _gameStartTime = DateTime.now();
    _lastInteractionTime = DateTime.now();
    _hintActive = false;
    _draggingItem = null;
  }

  /// Reset game (restart current level)
  void resetGame() {
    // Reset all items to starting positions
    for (final item in _items) {
      item.reset();
    }

    _resetGameState();
    notifyListeners();
  }

  // --- Drag and Drop Logic ---

  /// Start dragging an item
  bool startDragging(Offset position) {
    _lastInteractionTime = DateTime.now();

    // Find item at position
    for (int i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      if (item.containsPoint(position)) {
        // Check if item can be dragged
        if (_gameMode == GameMode.play && item.isPlaced) {
          final slot = _findSlotById(item.slotId);
          final isCorrectSlot = slot != null && slot.itemId == item.id;
          if (isCorrectSlot) {
            // Correctly placed items cannot be dragged
            return false;
          }
        }

        _draggingItem = item;
        item.isDragging = true;
        item.isPlaced = false;
        _dragOffset = Offset(position.dx - item.x, position.dy - item.y);

        // Move item to front
        _items.remove(item);
        _items.add(item);

        clearHint();
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  /// Update dragging position
  void updateDragging(Offset position, Size canvasSize) {
    if (_draggingItem == null) return;

    final item = _draggingItem!;

    // Calculate new position
    double newX = position.dx - _dragOffset.dx;
    double newY = position.dy - _dragOffset.dy;

    // Keep within bounds
    newX = newX.clamp(0, canvasSize.width - item.width);
    newY = newY.clamp(0, canvasSize.height - item.height);

    item.x = newX;
    item.y = newY;

    // Check if item should be removed from slot
    if (item.slotId != null) {
      final slot = _findSlotById(item.slotId);
      if (slot != null) {
        final distance = (item.center - slot.center).distance;
        final threshold =
            (slot.width > slot.height ? slot.width : slot.height) * 0.5;
        if (distance > threshold) {
          _handleItemRemoval(item);
        }
      }
    }

    notifyListeners();
  }

  /// End dragging
  void endDragging() {
    if (_draggingItem == null) return;

    final item = _draggingItem!;
    item.isDragging = false;

    if (_gameMode == GameMode.play) {
      // Check for slot collision
      final targetSlot = _findSlotAtPosition(item.center);
      if (targetSlot != null) {
        _snapToSlot(item, targetSlot);
      } else {
        // Item dropped outside slots
        item.slotId = null;
        item.isPlaced = false;
      }
    }

    _draggingItem = null;
    _updateGameStatus();
    notifyListeners();
  }

  /// Find slot by ID
  GameSlot? _findSlotById(String? slotId) {
    if (slotId == null) return null;
    return _slots.firstWhere((s) => s.id == slotId, orElse: () => _slots.first);
  }

  /// Find slot at position
  GameSlot? _findSlotAtPosition(Offset position) {
    for (final slot in _slots) {
      if (slot.isItemCloseEnough(position)) {
        return slot;
      }
    }
    return null;
  }

  /// Handle item removal from slot
  void _handleItemRemoval(GameItem item) {
    final slot = _findSlotById(item.slotId);
    final isCorrectSlot = slot != null && slot.itemId == item.id;

    if (isCorrectSlot && item.isPlaced && _gameMode == GameMode.play) {
      // Breaking streak for removing correctly placed item
      _updateStreak(false);
    }

    item.isPlaced = false;
    item.slotId = null;
  }

  /// Snap item to slot
  void _snapToSlot(GameItem item, GameSlot slot) {
    final isCorrectItem = slot.itemId == item.id;

    // Calculate stacking offset
    final itemsInSlot = _items
        .where((i) => i.slotId == slot.id && i != item)
        .length;
    final stackOffsetX = itemsInSlot * 10.0;
    final stackOffsetY = itemsInSlot * -15.0;

    // Calculate target position
    final targetX = slot.x + slot.width / 2 - item.width / 2 + stackOffsetX;
    final targetY = slot.y + slot.height / 2 - item.height / 2 + stackOffsetY;

    item.x = targetX;
    item.y = targetY;
    item.slotId = slot.id;

    if (isCorrectItem) {
      item.isPlaced = true;
      _updateStreak(true);
      _addScore(_config?.scoring.basePoints ?? 100);
    } else {
      item.isPlaced = false;
      item.isIncorrectlyPlaced = true;
      _updateStreak(false);
    }
  }

  // --- Scoring Logic ---

  /// Update streak
  void _updateStreak(bool isCorrect) {
    if (isCorrect && _lastPlacementWasCorrect) {
      _currentStreak++;
      _longestStreak = _currentStreak > _longestStreak
          ? _currentStreak
          : _longestStreak;
      _streakMultiplier =
          (_currentStreak - 1) * (_config?.scoring.streakBonus ?? 0.5) + 1;
      if (_streakMultiplier > (_config?.scoring.maxMultiplier ?? 5)) {
        _streakMultiplier = (_config?.scoring.maxMultiplier ?? 5).toDouble();
      }
    } else if (!isCorrect) {
      _currentStreak = 0;
      _streakMultiplier = 1.0;
    }

    _lastPlacementWasCorrect = isCorrect;
  }

  /// Add score
  void _addScore(int points) {
    _currentScore += (points * _streakMultiplier).round();
  }

  /// Update game status
  void _updateGameStatus() {
    _completedCount = _items.where((item) {
      if (!item.isPlaced) return false;
      final slot = _findSlotById(item.slotId);
      return slot != null && slot.itemId == item.id;
    }).length;

    if (_completedCount == _items.length && !_gameCompleted) {
      _gameCompleted = true;
      _gameCompletionTime = DateTime.now().difference(_gameStartTime!);
      _triggerCompletion();
    }
  }

  /// Trigger game completion
  void _triggerCompletion() {
    // Add completion bonus
    final completionBonus =
        ((_config?.scoring.basePoints ?? 100) * 2 * _streakMultiplier).round();
    _currentScore += completionBonus;

    notifyListeners();
  }

  // --- Hints ---

  /// Show hint for next unplaced item
  void showHint() {
    if (_gameCompleted || _hintActive) return;

    final unplacedItem = _items.firstWhere(
      (item) => !item.isPlaced,
      orElse: () => _items.first,
    );

    final targetSlot = _slots.firstWhere(
      (slot) => slot.itemId == unplacedItem.id,
      orElse: () => _slots.first,
    );

    _hintActive = true;
    _hintItem = unplacedItem;
    _hintSlot = targetSlot;

    notifyListeners();

    // Auto-clear hint after 4.5 seconds
    Future.delayed(const Duration(milliseconds: 4500), clearHint);
  }

  /// Clear hint
  void clearHint() {
    _hintActive = false;
    _hintItem = null;
    _hintSlot = null;
    notifyListeners();
  }

  // --- Theme Selection ---

  /// Proceed to next level
  void nextLevel() {
    if (_currentLevel < _maxLevels) {
      switchToLevel(_currentLevel + 1);
    } else {
      // Cycle back to level 1
      switchToLevel(1);
    }
  }

  /// Get formatted completion time
  String get formattedCompletionTime {
    final minutes = _gameCompletionTime.inMinutes;
    final seconds = _gameCompletionTime.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
