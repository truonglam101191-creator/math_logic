import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/adsmob/ads_mob.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/in_app/in_app_product_page.dart';
import 'package:logic_mathematics/features/mini_game/data/database_helper.dart';
import 'package:logic_mathematics/main.dart';

class SelectWidget extends StatefulWidget {
  const SelectWidget({super.key});
  @override
  _SelectWidgetState createState() => _SelectWidgetState();
}

double deviceWidth = 0.0;
double deviceLogicalWidth = 0.0;
double devicePixelRatio = 0.0;

class _SelectWidgetState extends State<SelectWidget> {
  List<ACategory> categories = [];
  List<List<AWord>> allWords = [];
  List<Color?> colorList = [];

  getHeightWidth(context) {
    // Get the logical width
    deviceLogicalWidth = MediaQuery.of(context).size.width;
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    deviceWidth = deviceLogicalWidth * devicePixelRatio;

    print("DeviceWidth : $deviceWidth, devicePixelRati : $devicePixelRatio");
  }

  _navigateAndDisplaySelection(BuildContext context, int index) async {
    final bestTime = await serviceLocator<DataBaseFuntion>()
        .getWordPuzzleBestTime(categories[index].category);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameWidget(
          category: categories[index].category,
          words: allWords[index],
          bestTime: bestTime,
        ),
      ),
    );

    // Reload best times after returning from game
    await _loadBestTimes();
    setState(() {});
  }

  Future<void> _loadBestTimes() async {
    final times = await serviceLocator<DataBaseFuntion>()
        .getAllWordPuzzleBestTimes();
    for (int i = 0; i < categories.length; i++) {
      categories[i].time = times[categories[i].category] ?? '00:00';
    }
  }

  Future _initializeDatabase() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.initializeDatabase();
    int ccount = await helper.getCategoryCount();
    int wcount = await helper.getAllWordsCount();
    categories = await helper.getAllCategories();

    // Load best times from DataBaseFuntion
    await _loadBestTimes();

    colorList.add(Colors.deepOrange[400]);
    colorList.add(Colors.orangeAccent[400]);
    colorList.add(Colors.purpleAccent[400]);
    colorList.add(Colors.redAccent[400]);
    colorList.add(Colors.lightGreen[900]);
    colorList.add(Colors.indigoAccent);
    colorList.add(Colors.redAccent[400]);

    for (int i = 0; i < categories.length; i++) {
      allWords.add(await helper.getWords(categories[i].category));
    }
    print("Database Loaded..  CCount : [$ccount]  WCount[$wcount]");
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    getHeightWidth(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Text(
                          'Word Puzzle',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose a category to play',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              // Categories List
              Expanded(
                child: categories.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _navigateAndDisplaySelection(context, index);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        colorList[index % colorList.length]!,
                                        colorList[index % colorList.length]!
                                            .withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Category Name
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                categories[index].category,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        // Stats Row
                                        Row(
                                          children: [
                                            // Best Time
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      categories[index].time,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            // Word Count
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .format_list_bulleted,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      '${allWords[index].length} words',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentDark,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<List<String>> gridMap = [];
double gridSize = 20.0;
double gridLogicalSize = 20.0;
List<Point> touchItems = [];

List<List<Point>> foundMap = [];
List<Color> foundColor = [];
List<String> foundWords = [];

class GameWidget extends StatefulWidget {
  final String category;
  final List<AWord> words;
  final String bestTime;

  const GameWidget({
    Key? key,
    required this.category,
    required this.words,
    required this.bestTime,
  }) : super(key: key);
  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  int gridW = 15;
  int gridH = 15;
  List<String> wordsList = [];

  Size? panSize;

  double x = 0.0;
  double y = 0.0;
  int timeElapsed = 10;

  final _keyRed = GlobalKey();
  bool? validTouchFlag;

  final List<String> textSuggetsed = [];

  int secondsPassed = 0;
  bool isActive = false;
  Timer? timer;
  List<Point> hintCells = [];
  Timer? hintTimer;

  void handleTick() {
    setState(() {
      secondsPassed = secondsPassed + 1;
    });
  }

  void showHint({bool isMinus = true}) async {
    if (foundWords.length == wordsList.length) return;

    //if (textSuggetsed.contains(foundWords)) {}

    // Find first unfound word
    String? targetWord;
    for (String word in wordsList) {
      if (!foundWords.contains(word)) {
        targetWord = word;
        break;
      }
    }

    if (targetWord == null) return;

    if (!textSuggetsed.contains(targetWord)) {
      textSuggetsed.add(targetWord);
      if (isMinus) {
        serviceLocator<DataBaseFuntion>().getStar().then((value) {
          if (value > 0) {
            serviceLocator<DataBaseFuntion>().saveStar(value - 1).then((value) {
              serviceLocator.get<MessagingService>().send(
                channel: MessageChannel.startUserChanged,
                parameter: '',
              );
            });
          }
        });
      }
    }

    // Find the word's position in grid
    List<Point> wordPositions = [];

    // Search in all 8 directions
    for (int i = 0; i < gridH; i++) {
      for (int j = 0; j < gridW; j++) {
        // Try all 8 directions
        for (int dir = 0; dir < 8; dir++) {
          List<Point> tempPositions = [];
          bool found = true;

          for (int k = 0; k < targetWord.length; k++) {
            int newI = i, newJ = j;

            // Calculate position based on direction
            if (dir == 0)
              newJ = j + k; // Right
            else if (dir == 1) {
              newI = i + k;
              newJ = j + k;
            } // Diagonal down-right
            else if (dir == 2)
              newI = i + k; // Down
            else if (dir == 3) {
              newI = i + k;
              newJ = j - k;
            } // Diagonal down-left
            else if (dir == 4)
              newJ = j - k; // Left
            else if (dir == 5) {
              newI = i - k;
              newJ = j - k;
            } // Diagonal up-left
            else if (dir == 6)
              newI = i - k; // Up
            else if (dir == 7) {
              newI = i - k;
              newJ = j + k;
            } // Diagonal up-right

            if (newI < 0 ||
                newI >= gridH ||
                newJ < 0 ||
                newJ >= gridW ||
                gridMap[newI][newJ] != targetWord[k]) {
              found = false;
              break;
            }

            tempPositions.add(Point(newJ, newI));
          }

          if (found && tempPositions.length == targetWord.length) {
            wordPositions = tempPositions;
            break;
          }
        }
        if (wordPositions.isNotEmpty) break;
      }
      if (wordPositions.isNotEmpty) break;
    }

    if (wordPositions.isNotEmpty) {
      setState(() {
        hintCells = wordPositions;
      });

      hintTimer?.cancel();
      hintTimer = Timer(Duration(seconds: 5), () {
        setState(() {
          hintCells.clear();
        });
      });
    }
  }

  void finishGame() async {
    timer?.cancel();

    if (!mounted) return;

    // Parse current best time
    final bestTimeParts = widget.bestTime.split(':');
    int bestTimeSeconds = 0;
    if (bestTimeParts.length == 2) {
      bestTimeSeconds =
          int.parse(bestTimeParts[0]) * 60 + int.parse(bestTimeParts[1]);
    }

    // Check if current time is better (lower) than best time or if no best time exists
    bool isNewRecord = bestTimeSeconds == 0 || secondsPassed < bestTimeSeconds;

    // Save best time if it's a new record
    if (isNewRecord) {
      await serviceLocator<DataBaseFuntion>().saveWordPuzzleBestTime(
        widget.category,
        secondsPassed,
      );
    }

    Navigator.pop(context);

    showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: isNewRecord ? Colors.amber : Colors.green,
              size: 32,
            ),
            SizedBox(width: 12),
            Text(
              isNewRecord ? "New Record!" : "Congratulations!",
              style: TextStyle(
                color: Color(0xFF6A11CB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You completed the puzzle!", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF6A11CB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, color: Color(0xFF6A11CB)),
                      SizedBox(width: 8),
                      Text(
                        "${secondsPassed ~/ 60}:${(secondsPassed % 60).toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A11CB),
                        ),
                      ),
                    ],
                  ),
                  if (isNewRecord && bestTimeSeconds > 0) ...[
                    SizedBox(height: 8),
                    Text(
                      "Previous best: ${widget.bestTime}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "OK",
              style: TextStyle(
                color: Color(0xFF6A11CB),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      context: context,
    );
  }

  void _incrementDown(PointerEvent details) {
    _updateLocation(details);
    print("Press Event: $details");
    //    finishGame();

    setState(() {
      touchItems.clear();
      validTouchFlag = true;
    });
  }

  void _incrementUp(PointerEvent details) {
    _updateLocation(details);
    print("Release Event: $details");
    String selectedStr = "";
    touchItems.forEach((element) {
      int xIndex = element.x.toInt(); // Convert to int
      int yIndex = element.y.toInt(); // Convert to int
      selectedStr = selectedStr + gridMap[yIndex][xIndex];
    });
    if (wordsList.contains(selectedStr) && !foundWords.contains(selectedStr)) {
      foundMap.add(
        List<Point>.generate(touchItems.length, (index) => touchItems[index]),
      );
      foundColor.add(
        Color.fromARGB(
          100,
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
        ),
      );
      foundWords.add(selectedStr);

      if (foundWords.length == wordsList.length) finishGame();
    }
    touchItems.clear();
  }

  void _updateLocation(PointerEvent details) {
    if (validTouchFlag == true) {
      setState(() {
        x = details.position.dx - _getPositions().dx - 10;
        y = details.position.dy - _getPositions().dy - 5;

        int itemX = x ~/ gridLogicalSize;
        int itemY = y ~/ gridLogicalSize;

        // Check if user is backtracking (moving back to previous cells)
        if (touchItems.length > 1) {
          // Check if current position matches a previous cell (backtracking)
          for (int i = touchItems.length - 2; i >= 0; i--) {
            if (touchItems[i].x == itemX && touchItems[i].y == itemY) {
              // Remove all cells after this point (backtrack)
              touchItems.removeRange(i + 1, touchItems.length);
              return;
            }
          }
        }

        // Add new cell if not already in the list
        if (!touchItems.contains(Point(itemX, itemY)) &&
            itemX >= 0 &&
            itemX < gridW &&
            itemY >= 0 &&
            itemY < gridH) {
          Offset itemPos = Offset(
            itemX * gridLogicalSize + gridLogicalSize / 2,
            itemY * gridLogicalSize + gridLogicalSize / 2,
          );
          Offset touchPos = Offset(x, y);
          // Increased touch radius from 2.5 to 1.8 for better sensitivity
          if ((itemPos - touchPos).distance < gridLogicalSize / 1.8)
            // ignore: curly_braces_in_flow_control_structures
            if (touchItems.length < 2) {
              touchItems.add(Point(itemX, itemY));
            } else if (itemX + touchItems[touchItems.length - 2].x ==
                    touchItems[touchItems.length - 1].x * 2 &&
                itemY + touchItems[touchItems.length - 2].y ==
                    touchItems[touchItems.length - 1].y * 2) {
              touchItems.add(Point(itemX, itemY));
            }
        }
      });
    }
  }

  Offset _getPositions() {
    final RenderBox? renderBox =
        _keyRed.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      // Handle the scenario when renderBox is null
      return Offset
          .zero; // or throw an exception, or any fallback value you prefer
    }

    Offset position = renderBox.localToGlobal(Offset.zero);
    return position;
  }

  @override
  void initState() {
    super.initState();
    foundMap.clear();
    foundColor.clear();
    foundWords.clear();
    touchItems.clear();
    _initializeGame();
    _startTimer();
  }

  void _startTimer() {
    secondsPassed = 0;
    isActive = true;
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (isActive) {
        handleTick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int seconds = secondsPassed % 60;
    int minutes = secondsPassed ~/ 60;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF6A11CB),
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (foundWords.isEmpty) {
              Navigator.of(context).pop();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Exit Game"),
                  content: Text("Are you sure you want to exit the game?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Exit game
                      },
                      child: Text("Exit"),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        title: Text(
          widget.category,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb_outline, color: Colors.white),
            onPressed: () async {
              if (hintCells.isNotEmpty) return;
              final getCoin = await serviceLocator<DataBaseFuntion>().getStar();
              if (getCoin < 1) {
                serviceLocator<AdmobController>().showInterstitialAd(
                  callback: (isSucess) => {
                    if (isSucess)
                      {showHint(isMinus: false)}
                    else
                      {
                        Navigator.push(
                          context,
                          createRouter(InAppProductPage()),
                        ),
                      },
                  },
                );
              } else {
                showHint();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (foundWords.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Restart Game"),
                    content: Text("Are you sure you want to restart the game?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          setState(() {
                            secondsPassed = 0;
                            foundMap.clear();
                            foundColor.clear();
                            foundWords.clear();
                            touchItems.clear();
                            hintCells.clear();
                            _initializeGame();
                          });
                        },
                        child: Text("Restart"),
                      ),
                    ],
                  ),
                );
                return;
              }
              setState(() {
                secondsPassed = 0;
                foundMap.clear();
                foundColor.clear();
                foundWords.clear();
                touchItems.clear();
                hintCells.clear();
                _initializeGame();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Stats Section
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      icon: Icons.timer,
                      label: 'Time',
                      value: "$minutes:${seconds.toString().padLeft(2, '0')}",
                      color: Colors.orange,
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildStatCard(
                      icon: Icons.emoji_events,
                      label: 'Best',
                      value: widget.bestTime,
                      color: Colors.amber,
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle,
                      label: 'Found',
                      value: '${foundWords.length}/${wordsList.length}',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              // Game Grid Section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Listener(
                    onPointerDown: _incrementDown,
                    onPointerMove: _updateLocation,
                    onPointerUp: _incrementUp,
                    child: CustomPaint(
                      painter: CharacterMapPainter(hintCells: hintCells),
                      key: _keyRed,
                    ),
                  ),
                ),
              ),

              // Words List Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        'Words to Find',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: GridView.count(
                        primary: false,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        children: wordsList
                            .map(
                              (data) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: foundWords.contains(data)
                                      ? Colors.green.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (foundWords.contains(data))
                                        Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      if (foundWords.contains(data))
                                        SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          data,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: foundWords.contains(data)
                                                ? Colors.white
                                                : Color(0xFF6A11CB),
                                            decoration:
                                                foundWords.contains(data)
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _initializeGame() {
    gridW = 15;
    gridH = 15;
    gridSize =
        (deviceWidth - 60) / gridW; // Giảm từ 20 xuống 60 (trừ 30px mỗi bên)
    gridLogicalSize = gridSize / devicePixelRatio;

    print(
      "DeviceWidth : $deviceWidth, DeviceLogicalWidth : $deviceLogicalWidth, GridSize : $gridSize",
    );

    // Generate the gridMap with the correct dimensions
    gridMap = List<List<String>>.generate(
      gridH,
      (i) => List<String>.generate(gridW, (j) => ""),
    );

    // Calculate panSize
    panSize = Size(
      gridW.toDouble() * gridSize / 1.5,
      gridH.toDouble() * gridSize / 1.5,
    );

    // If you want to print something for debugging.
    print("Grid Size: $gridSize, Pan Size: $panSize");

    wordsList = List<String>.generate(
      widget.words.length,
      (index) => widget.words[index].word,
    );
    wordsList.sort((b, a) => a.length.compareTo(b.length));
    var random = new Random();
    if (wordsList.length == 0) return;
    var first = generate(random.nextInt(8), wordsList[0]);
    Point pt = Point(
      random.nextInt(gridW - first.first.length + 1),
      random.nextInt(gridH - first.length + 1),
    );
    putOnGrid(first, pt);
    for (int wi = 1; wi < wordsList.length; wi++) {
      int dir;
      checkFound:
      for (dir = 0; dir < 8; dir++) {
        //find if words match exist
        var piece = generate(dir, wordsList[wi]);
        for (int i = 0; i < gridH - piece.length; i++)
          // ignore: curly_braces_in_flow_control_structures
          for (int j = 0; j < gridW - piece.first.length; j++) {
            int matchCharCount = 0, dismatchCharCount = 0;
            for (int ii = 0; ii < piece.length; ii++)
              // ignore: curly_braces_in_flow_control_structures
              for (int jj = 0; jj < piece.first.length; jj++) {
                if (piece[ii][jj] == gridMap[i + ii][j + jj] &&
                    piece[ii][jj] != "") {
                  matchCharCount++;
                } else if (piece[ii][jj] != gridMap[i + ii][j + jj] &&
                    gridMap[i + ii][j + jj] != "")
                  // ignore: curly_braces_in_flow_control_structures
                  dismatchCharCount++;
              }
            if (matchCharCount > 0 && dismatchCharCount == 0) {
              putOnGrid(piece, Point(j, i));
              break checkFound;
            }
          }
      }
      if (dir == 8) {
        putAsAnother:
        while (true) {
          var piece = generate(random.nextInt(8), wordsList[wi]);
          int i = random.nextInt(gridH - piece.length);
          int j = random.nextInt(gridW - piece.first.length);
          int matchCharCount = 0;
          for (int ii = 0; ii < piece.length; ii++)
            // ignore: curly_braces_in_flow_control_structures
            for (int jj = 0; jj < piece.first.length; jj++) {
              if (gridMap[i + ii][j + jj] != "") matchCharCount++;
            }
          if (matchCharCount == 0) {
            putOnGrid(piece, Point(j, i));
            break putAsAnother;
          }
        }
      }
    }

    String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i = 0; i < gridMap.length; i++)
      // ignore: curly_braces_in_flow_control_structures
      for (int j = 0; j < gridMap[i].length; j++) {
        if (gridMap[i][j] == "") gridMap[i][j] = chars[random.nextInt(26)];
      }
  }

  void putOnGrid(List<List<String>> piece, Point pt) {
    for (int i = 0; i < piece.length; i++)
      // ignore: curly_braces_in_flow_control_structures
      for (int j = 0; j < piece[i].length; j++) {
        gridMap[(pt.y + i).toInt()][(pt.x + j).toInt()] = piece[i][j];
      }
  }

  List<List<String>> generate(int direction, String aword) {
    List<List<String>> grid;
    if (direction == 0) {
      grid = List<List<String>>.generate(
        1,
        (i) => List<String>.generate(aword.length, (j) => aword[j]),
      );
    } else if (direction == 1) {
      grid = List<List<String>>.generate(
        aword.length,
        (i) =>
            List<String>.generate(aword.length, (j) => i == j ? aword[i] : ""),
      );
    } else if (direction == 2) {
      grid = List<List<String>>.generate(
        aword.length,
        (i) => List<String>.generate(1, (j) => aword[i]),
      );
    } else if (direction == 3) {
      grid = List<List<String>>.generate(
        aword.length,
        (i) => List<String>.generate(
          aword.length,
          (j) => i + j + 1 == aword.length ? aword[i] : "",
        ),
      );
    } else if (direction == 4) {
      grid = List<List<String>>.generate(
        1,
        (i) => List<String>.generate(
          aword.length,
          (j) => aword[aword.length - 1 - j],
        ),
      );
    } else if (direction == 5) {
      grid = List<List<String>>.generate(
        aword.length,
        (i) => List<String>.generate(
          aword.length,
          (j) => i == j ? aword[aword.length - i - 1] : "",
        ),
      );
    } else if (direction == 6) {
      grid = List<List<String>>.generate(
        aword.length,
        (i) => List<String>.generate(1, (j) => aword[aword.length - i - 1]),
      );
    } else if (direction == 7) {
      grid = List<List<String>>.generate(
        aword.length,
        (i) => List<String>.generate(
          aword.length,
          (j) => i + j + 1 == aword.length ? aword[j] : "",
        ),
      );
    } else {
      // Handle invalid direction
      grid = [];
    }
    return grid;
  }

  @override
  void dispose() {
    timer?.cancel();
    hintTimer?.cancel();
    super.dispose();
  }
}

class CharacterMapPainter extends CustomPainter {
  final List<Point> hintCells;

  CharacterMapPainter({this.hintCells = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Calculate actual grid size based on available canvas size with padding
    final double paddingHorizontal = 10.0;
    final double paddingVertical = 10.0;
    final double availableWidth = size.width - (paddingHorizontal * 2);
    final double availableHeight = size.height - (paddingVertical * 2);

    // Calculate cell size to fit the grid perfectly
    final double cellWidth = availableWidth / gridMap[0].length;
    final double cellHeight = availableHeight / gridMap.length;
    final double cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

    // Draw background rounded rectangle
    paint.strokeWidth = 1.0;
    paint.color = Colors.grey.withOpacity(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(10),
      ),
      paint,
    );

    // Draw grid letters
    for (int i = 0; i < gridMap.length; i++) {
      for (int j = 0; j < gridMap[i].length; j++) {
        // Check if this cell is in hint
        bool isHintCell = hintCells.any((p) => p.x == j && p.y == i);

        // Draw cell background circle (larger for better touch)
        final cellPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = isHintCell
              ? Colors.amber.withOpacity(0.4)
              : Colors.grey.withOpacity(0.08);

        final cellCenter = Offset(
          paddingHorizontal + (j + 0.5) * cellSize,
          paddingVertical + (i + 0.5) * cellSize,
        );

        canvas.drawCircle(cellCenter, cellSize * 0.42, cellPaint);

        // Draw pulsing ring for hint cells
        if (isHintCell) {
          final hintRingPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.amber.withOpacity(0.8)
            ..strokeWidth = 2.0;
          canvas.drawCircle(cellCenter, cellSize * 0.45, hintRingPaint);
        }

        // Draw text with larger size for better readability
        final textStyle = TextStyle(
          color: isHintCell ? Colors.orange.shade900 : Color(0xFF6A11CB),
          fontSize: cellSize * 0.65, // Increased from 0.5 to 0.65
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        );
        final textSpan = TextSpan(text: gridMap[i][j], style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final textOffset = Offset(
          paddingHorizontal + j * cellSize + (cellSize - textPainter.width) / 2,
          paddingVertical + i * cellSize + (cellSize - textPainter.height) / 2,
        );

        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw found words with highlight
    List<Offset> offset = [];
    Path path = Path();
    paint.strokeWidth = cellSize * 0.7;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;

    for (int i = 0; i < foundWords.length; i++) {
      offset.clear();
      path.reset();
      paint.color = foundColor[i];

      for (int j = 0; j < foundMap[i].length; j++) {
        offset.add(
          Offset(
            paddingHorizontal + (foundMap[i][j].x + 0.5) * cellSize,
            paddingVertical + (foundMap[i][j].y + 0.5) * cellSize,
          ),
        );
      }

      path.addPolygon(offset, false);
      canvas.drawPath(path, paint);
    }

    // Draw current selection
    List<Offset> offsets = [];
    for (int i = 0; i < touchItems.length; i++) {
      offsets.add(
        Offset(
          paddingHorizontal + (touchItems[i].x + 0.5) * cellSize,
          paddingVertical + (touchItems[i].y + 0.5) * cellSize,
        ),
      );
    }

    if (offsets.isNotEmpty) {
      path.reset();
      path.addPolygon(offsets, false);
      paint.color = Color(0xFF6A11CB).withOpacity(0.5);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CharacterMapPainter oldDelegate) => true;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
