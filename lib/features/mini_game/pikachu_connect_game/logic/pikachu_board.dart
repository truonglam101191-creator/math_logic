import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/pikachu_connect_game/util/connect_sounds.dart';
import '../data/models.dart';

/// Core board logic implementing LianLianKan (Pikachu connect) rules:
/// - Grid padded by empty outer border to allow paths to exit edges
/// - A pair can be connected if a path exists with <= 2 bends (<= 3 straight segments)
class PikachuBoardController extends ChangeNotifier {
  final BoardConfig config;
  final TileStyle style;
  late BoardConfig _activeConfig;

  /// Callback to notify when the successful connection count changes.
  final ValueChanged<int>? onConnectionCountChanged;

  /// Callback when a hint is shown (optional) so UI can react (e.g., sound/effect).
  final VoidCallback? onHintShown;

  /// Callback when the game is won (no remaining pairs).
  final VoidCallback? onGameWon;

  late List<List<PikachuTile>> _grid; // [row][col]
  PikachuTile? _selectedA;
  PikachuTile? _selectedB;
  List<Offset> _path = [];
  int _remainingPairs = 0;
  int _successfulConnections = 0; // number of successful link matches
  int _wrongSelections = 0; // count wrong selections (failed connect)
  bool _hintUsedForThisGame = false; // only once per game

  PikachuBoardController({
    required this.config,
    required this.style,
    this.onConnectionCountChanged,
    this.onHintShown,
    this.onGameWon,
  }) {
    _activeConfig = config;
    _initBoard();
  }

  GameState get state => GameState(
    grid: _grid,
    selectedA: _selectedA,
    selectedB: _selectedB,
    pathPoints: _path,
    remainingPairs: _remainingPairs,
  );

  /// Current number of successful connections (pairs removed).
  int get successfulConnections => _successfulConnections;

  /// Manually set connection count (e.g., for reset or external control).
  void setConnectionCount(int value) {
    _successfulConnections = value;
    onConnectionCountChanged?.call(_successfulConnections);
    notifyListeners();
  }

  void reset() {
    _initBoard();
    // Reset successful connections on new game
    _successfulConnections = 0;
    onConnectionCountChanged?.call(_successfulConnections);
    _wrongSelections = 0;
    _hintUsedForThisGame = false;
    notifyListeners();
  }

  /// Change difficulty by updating board configuration (rows, cols, types).
  /// This will rebuild the board and reset progress counters.
  void applyDifficulty(BoardConfig newConfig) {
    // Basic sanity to avoid odd sizes
    assert(newConfig.rows >= 6 && newConfig.cols >= 6 && newConfig.types >= 2);
    // Update config via a new instance (immutable)
    // ignore: invalid_use_of_visible_for_testing_member
    // Note: BoardConfig is immutable, we replace reference here
    // Create a new controller state with new config
    // We cannot replace 'config' field since it's final, so we rebuild grid using newConfig
    // Workaround: create a temp controller-like rebuild using local newConfig
    // We'll reuse style and internal logic but regenerate _grid accordingly.
    //
    // Re-init using new config
    // remember the new active config so subsequent resets/shuffles respect it
    _activeConfig = newConfig;
    _initBoardWithConfig(newConfig);
    _successfulConnections = 0;
    onConnectionCountChanged?.call(_successfulConnections);
    _wrongSelections = 0;
    _hintUsedForThisGame = false;
    notifyListeners();
  }

  void _initBoardWithConfig(BoardConfig cfg) {
    // Create grid with outer empty border
    _grid = List.generate(cfg.rows, (r) {
      return List.generate(cfg.cols, (c) {
        return PikachuTile(id: r * cfg.cols + c, type: -1, isEmpty: true);
      });
    });

    final innerRows = cfg.rows - 2;
    final innerCols = cfg.cols - 2;
    final totalInner = innerRows * innerCols;
    final ids = List<int>.generate(totalInner, (i) => i + 2000);
    final rnd = Random();

    final tiles = <PikachuTile>[];
    for (var i = 0; i < totalInner ~/ 2; i++) {
      final type = rnd.nextInt(cfg.types);
      tiles.add(PikachuTile(id: ids[i * 2], type: type, isEmpty: false));
      tiles.add(PikachuTile(id: ids[i * 2 + 1], type: type, isEmpty: false));
    }
    tiles.shuffle(rnd);

    int k = 0;
    for (var r = 1; r <= innerRows; r++) {
      for (var c = 1; c <= innerCols; c++) {
        if (k < tiles.length) {
          _grid[r][c] = tiles[k++];
        } else {
          // leave as empty if we have odd inner cell count (one cell remains empty)
          _grid[r][c] = PikachuTile(
            id: r * cfg.cols + c,
            type: -1,
            isEmpty: true,
          );
        }
      }
    }
    _selectedA = null;
    _selectedB = null;
    _path = [];
    _remainingPairs = tiles.length ~/ 2;
  }

  void shuffle() {
    // Flatten non-empty tiles
    final tiles = <PikachuTile>[];
    for (var r = 0; r < _activeConfig.rows; r++) {
      for (var c = 0; c < _activeConfig.cols; c++) {
        final t = _grid[r][c];
        if (!t.isEmpty) tiles.add(t);
      }
    }
    tiles.shuffle(Random());
    int idx = 0;
    for (var r = 0; r < _activeConfig.rows; r++) {
      for (var c = 0; c < _activeConfig.cols; c++) {
        if (_grid[r][c].isEmpty) continue;
        _grid[r][c] = tiles[idx++];
      }
    }
    _selectedA = null;
    _selectedB = null;
    _path = [];
    notifyListeners();
  }

  void tap(int row, int col) {
    final t = _grid[row][col];
    ConnectSounds.playTapSound();
    if (t.isEmpty) return;
    if (_selectedA == null) {
      _selectedA = t;
      notifyListeners();
      return;
    }
    if (_selectedA!.id == t.id) {
      // deselect
      _selectedA = null;
      _path = [];
      notifyListeners();
      return;
    }
    // select B and try connect
    _selectedB = t;
    final p = _findPath(_selectedA!, _selectedB!);
    if (p != null) {
      // Show path briefly before removing to ensure user can see the connection line
      _path = p;
      notifyListeners();
      ConnectSounds.connectSuccessSound();
      Future.delayed(const Duration(milliseconds: 300), () {
        _removePair(_selectedA!, _selectedB!);
        _selectedA = null;
        _selectedB = null;
        _path = [];
        notifyListeners();
      });
    } else {
      // if not match or no path, set A to B to continue
      _selectedA = t;
      _selectedB = null;
      _path = [];
      _wrongSelections += 1;
      _maybeTriggerHint();
      notifyListeners();
    }
  }

  // Internal
  void _initBoard() {
    // Create grid with outer empty border
    _grid = List.generate(_activeConfig.rows, (r) {
      return List.generate(_activeConfig.cols, (c) {
        return PikachuTile(
          id: r * _activeConfig.cols + c,
          type: -1,
          isEmpty: true,
        );
      });
    });

    final innerRows = _activeConfig.rows - 2;
    final innerCols = _activeConfig.cols - 2;
    final totalInner = innerRows * innerCols;
    final ids = List<int>.generate(totalInner, (i) => i + 1000);
    final rnd = Random();

    // Generate pairs evenly across types
    final tiles = <PikachuTile>[];
    for (var i = 0; i < totalInner ~/ 2; i++) {
      final type = rnd.nextInt(_activeConfig.types);
      tiles.add(PikachuTile(id: ids[i * 2], type: type, isEmpty: false));
      tiles.add(PikachuTile(id: ids[i * 2 + 1], type: type, isEmpty: false));
    }
    tiles.shuffle(rnd);

    int k = 0;
    for (var r = 1; r <= innerRows; r++) {
      for (var c = 1; c <= innerCols; c++) {
        if (k < tiles.length) {
          _grid[r][c] = tiles[k++];
        } else {
          _grid[r][c] = PikachuTile(
            id: r * _activeConfig.cols + c,
            type: -1,
            isEmpty: true,
          );
        }
      }
    }
    _selectedA = null;
    _selectedB = null;
    _path = [];
    _remainingPairs = tiles.length ~/ 2;
  }

  void _removePair(PikachuTile a, PikachuTile b) {
    // set tiles to empty by locating them
    for (var r = 0; r < _activeConfig.rows; r++) {
      for (var c = 0; c < _activeConfig.cols; c++) {
        if (_grid[r][c].id == a.id || _grid[r][c].id == b.id) {
          _grid[r][c] = PikachuTile(
            id: _grid[r][c].id,
            type: -1,
            isEmpty: true,
          );
        }
      }
    }
    _remainingPairs -= 1;
    // increment successful connections and notify
    _successfulConnections += 1;
    onConnectionCountChanged?.call(_successfulConnections);
    // If no remaining pairs, notify game won event
    if (_remainingPairs <= 0) {
      onGameWon?.call();
    }
  }

  void _maybeTriggerHint() {
    if (_hintUsedForThisGame) return;
    if (_wrongSelections < 3) return;
    // Find any available pair and show its path once
    final hint = _findAnyHintPath();
    if (hint != null) {
      _path = hint;
      _hintUsedForThisGame = true; // only once per game
      onHintShown?.call();
      notifyListeners();
      // clear hint path after short delay (do not remove tiles)
      Future.delayed(const Duration(milliseconds: 700), () {
        _path = [];
        notifyListeners();
      });
    }
  }

  List<Offset>? _findAnyHintPath() {
    // Iterate over all non-empty pairs and return the first connectable path
    final tiles = <PikachuTile>[];
    for (var r = 0; r < _activeConfig.rows; r++) {
      for (var c = 0; c < _activeConfig.cols; c++) {
        final t = _grid[r][c];
        if (!t.isEmpty) tiles.add(t);
      }
    }
    for (var i = 0; i < tiles.length; i++) {
      for (var j = i + 1; j < tiles.length; j++) {
        final a = tiles[i];
        final b = tiles[j];
        if (!a.matches(b)) continue;
        final path = _findPath(a, b);
        if (path != null) {
          return path;
        }
      }
    }
    return null;
  }

  bool _isClearLine(Point<int> a, Point<int> b) {
    // Straight line with no obstacles (excluding endpoints)
    if (a.x == b.x) {
      final x = a.x;
      final yStart = min(a.y, b.y);
      final yEnd = max(a.y, b.y);
      for (var y = yStart + 1; y < yEnd; y++) {
        if (!_grid[y][x].isEmpty) return false;
      }
      return true;
    }
    if (a.y == b.y) {
      final y = a.y;
      final xStart = min(a.x, b.x);
      final xEnd = max(a.x, b.x);
      for (var x = xStart + 1; x < xEnd; x++) {
        if (!_grid[y][x].isEmpty) return false;
      }
      return true;
    }
    return false;
  }

  List<Offset>? _findPath(PikachuTile a, PikachuTile b) {
    if (!a.matches(b)) return null;

    final pa = _locate(a);
    final pb = _locate(b);
    if (pa == null || pb == null) return null;

    // 1. Straight line
    if (_isClearLine(pa, pb)) {
      return [
        Offset(pa.x.toDouble(), pa.y.toDouble()),
        Offset(pb.x.toDouble(), pb.y.toDouble()),
      ];
    }

    // 2. One turn: try corner points (pa.x, pb.y) and (pb.x, pa.y)
    final corner1 = Point<int>(pa.x, pb.y);
    final corner2 = Point<int>(pb.x, pa.y);
    if (_grid[corner1.y][corner1.x].isEmpty &&
        _isClearLine(pa, corner1) &&
        _isClearLine(corner1, pb)) {
      return [
        Offset(pa.x.toDouble(), pa.y.toDouble()),
        Offset(corner1.x.toDouble(), corner1.y.toDouble()),
        Offset(pb.x.toDouble(), pb.y.toDouble()),
      ];
    }
    if (_grid[corner2.y][corner2.x].isEmpty &&
        _isClearLine(pa, corner2) &&
        _isClearLine(corner2, pb)) {
      return [
        Offset(pa.x.toDouble(), pa.y.toDouble()),
        Offset(corner2.x.toDouble(), corner2.y.toDouble()),
        Offset(pb.x.toDouble(), pb.y.toDouble()),
      ];
    }

    // 3. Two turns: expand along rows and cols from pa and pb to empty points and check one-turn
    // Explore along X from pa
    for (var x = pa.x - 1; x >= 0; x--) {
      final p = Point<int>(x, pa.y);
      if (!_grid[p.y][p.x].isEmpty) break;
      // try connect to pb via p
      final candidate = _oneTurn(p, pb);
      if (candidate != null && _isClearLine(p, pa)) {
        return [Offset(pa.x.toDouble(), pa.y.toDouble()), ...candidate];
      }
    }
    for (var x = pa.x + 1; x < config.cols; x++) {
      final p = Point<int>(x, pa.y);
      if (!_grid[p.y][p.x].isEmpty) break;
      final candidate = _oneTurn(p, pb);
      if (candidate != null && _isClearLine(p, pa)) {
        return [Offset(pa.x.toDouble(), pa.y.toDouble()), ...candidate];
      }
    }
    // Explore along Y from pa
    for (var y = pa.y - 1; y >= 0; y--) {
      final p = Point<int>(pa.x, y);
      if (!_grid[p.y][p.x].isEmpty) break;
      final candidate = _oneTurn(p, pb);
      if (candidate != null && _isClearLine(p, pa)) {
        return [Offset(pa.x.toDouble(), pa.y.toDouble()), ...candidate];
      }
    }
    for (var y = pa.y + 1; y < config.rows; y++) {
      final p = Point<int>(pa.x, y);
      if (!_grid[p.y][p.x].isEmpty) break;
      final candidate = _oneTurn(p, pb);
      if (candidate != null && _isClearLine(p, pa)) {
        return [Offset(pa.x.toDouble(), pa.y.toDouble()), ...candidate];
      }
    }

    return null;
  }

  List<Offset>? _oneTurn(Point<int> p, Point<int> q) {
    // Return path p -> corner -> q if exists
    if (_isClearLine(p, q)) {
      return [
        Offset(p.x.toDouble(), p.y.toDouble()),
        Offset(q.x.toDouble(), q.y.toDouble()),
      ];
    }
    final c1 = Point<int>(p.x, q.y);
    final c2 = Point<int>(q.x, p.y);
    if (_grid[c1.y][c1.x].isEmpty &&
        _isClearLine(p, c1) &&
        _isClearLine(c1, q)) {
      return [
        Offset(p.x.toDouble(), p.y.toDouble()),
        Offset(c1.x.toDouble(), c1.y.toDouble()),
        Offset(q.x.toDouble(), q.y.toDouble()),
      ];
    }
    if (_grid[c2.y][c2.x].isEmpty &&
        _isClearLine(p, c2) &&
        _isClearLine(c2, q)) {
      return [
        Offset(p.x.toDouble(), p.y.toDouble()),
        Offset(c2.x.toDouble(), c2.y.toDouble()),
        Offset(q.x.toDouble(), q.y.toDouble()),
      ];
    }
    return null;
  }

  Point<int>? _locate(PikachuTile t) {
    for (var r = 0; r < _activeConfig.rows; r++) {
      for (var c = 0; c < _activeConfig.cols; c++) {
        if (_grid[r][c].id == t.id) return Point<int>(c, r);
      }
    }
    return null;
  }
}
