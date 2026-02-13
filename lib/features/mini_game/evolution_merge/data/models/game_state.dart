import 'evolution_item.dart';

/// Enum for game status
enum GameStatus { loading, ready, playing, paused, gameOver, victory }

/// Holds the current state of the game
class EvolutionGameState {
  int score;
  int highScore;
  List<EvolutionItem> items;
  int? nextItemType;
  double dropX;
  bool isDropping;
  GameStatus status;
  DateTime? dangerStartTime;
  bool isNewHighScore;

  EvolutionGameState({
    this.score = 0,
    this.highScore = 0,
    List<EvolutionItem>? items,
    this.nextItemType,
    required this.dropX,
    this.isDropping = false,
    this.status = GameStatus.loading,
    this.dangerStartTime,
    this.isNewHighScore = false,
  }) : items = items ?? [];

  bool get isGameOver => status == GameStatus.gameOver;
  bool get isVictory => status == GameStatus.victory;
  bool get isPlaying => status == GameStatus.playing;
  bool get canDrop => !isDropping && isPlaying;

  EvolutionGameState copyWith({
    int? score,
    int? highScore,
    List<EvolutionItem>? items,
    int? nextItemType,
    double? dropX,
    bool? isDropping,
    GameStatus? status,
    DateTime? dangerStartTime,
    bool? isNewHighScore,
  }) {
    return EvolutionGameState(
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      items: items ?? this.items,
      nextItemType: nextItemType ?? this.nextItemType,
      dropX: dropX ?? this.dropX,
      isDropping: isDropping ?? this.isDropping,
      status: status ?? this.status,
      dangerStartTime: dangerStartTime ?? this.dangerStartTime,
      isNewHighScore: isNewHighScore ?? this.isNewHighScore,
    );
  }

  void reset(double initialDropX) {
    score = 0;
    items.clear();
    nextItemType = null;
    dropX = initialDropX;
    isDropping = false;
    status = GameStatus.ready;
    dangerStartTime = null;
    isNewHighScore = false;
  }
}
