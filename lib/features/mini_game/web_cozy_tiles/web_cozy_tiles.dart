import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebCozyTiles extends StatefulWidget {
  const WebCozyTiles({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebCozyTiles> createState() => _WebPackPalStubState();
}

class _WebPackPalStubState extends State<WebCozyTiles> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

  late final perferen = Shared.instance.sharedPreferences;

  final _kSavedGameStateKey = 'web_cozy_tiles_saved_game_state_v1';

  //late Map<String, dynamic>? persisted = null;

  @override
  void initState() {
    super.initState();
  }

  // setup file game
  Future<void> setupGame() async {
    try {
      // register multiple possible handler names
      final handlerNames = [
        'GameChannel',
        'FlutterWebViewChannel',
        'onBack',
        'onCloseWindow',
        'exitGame',
        'onGameEvent',
      ];
      for (final name in handlerNames) {
        try {
          _controller.addJavaScriptHandler(
            handlerName: name,
            callback: (args) {
              _handleJsMessage(args.isNotEmpty ? args[0] : args);
              return null;
            },
          );
        } catch (e) {
          debugPrint('Failed to add handler $name: $e');
        }
      }

      // load local asset
      try {
        String html = await rootBundle.loadString(
          'assets/cozy_tiles/cozy_tiles.html',
        );

        final config = await rootBundle.loadString(
          'assets/cozy_tiles/config.json',
        );

        if (config.isNotEmpty) {
          html = html.replaceAll(
            '<script id="gameConfig"></script>',
            '<script id="gameConfig"> window.gameConfig = $config;</script>',
          );
        }

        final assets = await rootBundle.loadString(
          'assets/cozy_tiles/assetMap.json',
        );

        if (assets.isNotEmpty) {
          html = html.replaceAll(
            '<script id="assetsMap" type="application/json"></script>',
            '<script id="assetsMap" type="application/json">$assets</script>',
          );
        }

        html = html.replaceAll('<script id="logic"></script>', loadLogicGame);

        html = html.replaceFirst(
          '<script id="LoadGame"></script>',
          morefunctionLoadAniamtion,
        );

        final savedState = perferen.getString(_kSavedGameStateKey);
        if (savedState != null && savedState.isNotEmpty) {
          html = html
              .replaceAll(
                'let currentLevel = 0;',
                'let currentLevel = $savedState;',
              )
              .replaceAll('"currentLevel": 0', '"currentLevel": $savedState')
              .replaceAll('startLevel(0)', 'startLevel($savedState)');
        }

        await _controller.loadData(
          data: html,
          mimeType: 'text/html',
          encoding: 'utf-8',
          baseUrl: WebUri('about:blank'),
        );
      } catch (e) {
        debugPrint('Failed to load local asset: $e');
        setState(() => _error = true);
      }
    } catch (e) {
      debugPrint('setupGame error: $e');
    }
  }

  // unified JS payload handler
  Future<void> _handleJsMessage(dynamic payload) async {
    try {
      dynamic raw = payload;
      if (raw is List && raw.isNotEmpty) raw = raw[0];

      Map parsed = {};
      if (raw is String && raw.startsWith('{')) {
        try {
          parsed = Map<String, dynamic>.from(jsonDecode(raw));
        } catch (_) {
          parsed = {};
        }
      } else if (raw is Map) {
        parsed = Map<String, dynamic>.from(raw);
      } else {
        parsed = {};
      }

      // --- persist when embedding asks to exit ---
      if (parsed.isNotEmpty &&
          (parsed['type'] == 'exitGame' || parsed['type'] == 'back')) {
        // Prefer explicit gameState/payload, fallback to whole object
        final stateObj = (parsed['gameState'] ?? parsed['payload'] ?? parsed);

        try {
          perferen.setString(
            _kSavedGameStateKey,
            stateObj['currentLevel'] != null
                ? stateObj['currentLevel'].toString()
                : '',
          );
        } catch (e) {
          debugPrint('Failed to save game state: $e');
        }

        // close host UI
        Navigator.of(context).pop();
        return;
      }

      if (parsed.isNotEmpty && parsed.containsKey('score')) {
        final s = parsed['score'];
        final int? score = s is int ? s : int.tryParse(s?.toString() ?? '');
        if (score != null) widget.onGameEnd?.call(score);
        return;
      }
      final asStr = raw?.toString() ?? '';
      if (asStr.startsWith('score:')) {
        final val = int.tryParse(asStr.split(':').last);
        if (val != null) widget.onGameEnd?.call(val);
        return;
      }
      final lone = int.tryParse(asStr);
      if (lone != null) {
        widget.onGameEnd?.call(lone);
        return;
      }
    } catch (e) {
      debugPrint('Failed to handle JS message: $e');
    }
  }

  // helper: load persisted state (or null)
  // Future<Map<String, dynamic>?> _loadPersistedState() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final raw = prefs.getString(_kSavedGameStateKey);
  //     if (raw == null || raw.isEmpty) return null;
  //     final decoded = jsonDecode(raw);
  //     if (decoded is Map<String, dynamic>) return decoded;
  //     return null;
  //   } catch (e) {
  //     debugPrint('Failed to load persisted state: $e');
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Text('Use web implementation'));
    }

    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            SizedBox(height: 8),
            Text('Unable to load mini-game', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cozy_tiles/background_cute.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useShouldOverrideUrlLoading: true,
                ),
                onWebViewCreated: (controller) async {
                  _controller = controller;
                  setupGame();
                },
                onLoadStop: (controller, url) async {
                  // set dark background to avoid white flash and inject bridge if needed
                  try {
                    await controller.evaluateJavascript(
                      source:
                          "try{document.documentElement.style.backgroundColor='#0a1128';document.body.style.backgroundColor='#0a1128';}catch(e){}",
                    );
                  } catch (_) {}
                  // small bridge to forward legacy calls to Flutter handler (debounced)
                  final bridge = r'''
                  (function(){
                    try{
                      if(!window.__flutter_bridge_sendOnce){
                        window.__flutter_bridge_lastTime = 0;
                        window.__flutter_bridge_sendOnce = function(payload){
                          try{
                            var now = Date.now();
                            if(now - (window.__flutter_bridge_lastTime || 0) < 500) return;
                            window.__flutter_bridge_lastTime = now;
                            if(window.flutter_inappwebview && window.flutter_inappwebview.callHandler){
                              window.flutter_inappwebview.callHandler('GameChannel', payload);
                            }
                          }catch(e){}
                        };
                      }
                      if(!window.GameChannel){
                        window.GameChannel = { postMessage: function(msg){ try{ window.__flutter_bridge_sendOnce(msg);}catch(e){} } };
                      }
                      window.exitGame = window.exitGame || function(arg){ try{ window.__flutter_bridge_sendOnce(JSON.stringify({type:'exitGame', payload: arg})); }catch(e){} };
                      window.onCloseWindow = window.onCloseWindow || function(){ try{ window.__flutter_bridge_sendOnce(JSON.stringify({type:'lose_app'})); }catch(e){} };
                      window.onBack = window.onBack || function(arg){ try{ window.__flutter_bridge_sendOnce(JSON.stringify(arg||{type:'back'})); }catch(e){} };
                      if(!window.__flutter_bridge_postmsg_installed){
                        window.__flutter_bridge_postmsg_installed = true;
                        window.addEventListener('message', function(e){ try{ window.__flutter_bridge_sendOnce(e.data);}catch(e){} }, false);
                      }
                    }catch(e){}
                  })();
                ''';
                  try {
                    await controller.evaluateJavascript(source: bridge);
                  } catch (e) {
                    debugPrint('Bridge injection failed: $e');
                  }

                  // if (persisted != null) {
                  //   Future.delayed(const Duration(milliseconds: 100), () async {
                  //     await _controller.evaluateJavascript(
                  //       source: 'playBackgroundMusic();',
                  //     );
                  //   });
                  // }

                  setState(() => _ready = true);
                },
                onLoadError: (controller, url, code, message) {
                  debugPrint('WebView error: $code $message');
                  setState(() => _error = true);
                },
              ),
              if (!_ready)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0xff0a1128),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff33f5ff),
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

  String get morefunctionLoadAniamtion => '''
     <script>
        // Lightweight runtime bridge so the game can run standalone in a browser without the host app.
        (function initLibBridge() {
            // Toggle saving/resume prompts. Set to true if you want persistence.
            window.ENABLE_SAVES = false;

            let assetsCache = {};

            try {
                const assetsEl = document.getElementById('assetsMap');
                if (assetsEl) {
                    assetsCache = JSON.parse(assetsEl.textContent || '{}');
                }
            } catch (err) {
                console.warn('[CozyTiles] Failed to parse assets map', err);
            }

            const lib = {
                log: (...args) => console.log('[CozyTiles]', ...args),
                getAsset: (id) => assetsCache[id],
                async getUserGameState() {
               
                },
                
                showGameParameters() {
                    // No-op in browser; the host app can override to display controls.
                }
            };

            window.lib = lib;

        })();
    </script>
  ''';

  String get loadLogicGame => r'''
       <script>


        /* ==================================================
         * GAME OVERVIEW: Digit Shift - Fast-paced sliding number puzzle game
         * Players arrange numbered tiles in ascending order against the clock.
         * 12 levels with increasing difficulty (3×3 to 8×8 grids).
         * Each level unlocks a unique visual skin.
         * Edit mode allows customization of skins, timer, and audio settings.
         * 
         * GAME STATE SHAPE: window.gameConfig = {
         *   selectedSkin: 'tile_classic',
         *   customTimer: null,
         *   customGridSize: null,
         *   customShuffleComplexity: 'medium',
         *   audio: {
         *     musicVolume: 0.7,
         *     sfxVolume: 0.8,
         *     musicEnabled: true,
         *     sfxEnabled: true
         *   }
         * }
         * 
         * User Game State (persisted via lib APIs): {
         *   unlockedLevels: [1, 2, ...],
         *   unlockedSkins: ['tile_classic', 'tile_neon_glow', ...],
         *   bestTimes: { 1: 45, 2: 52, ... },
         *   currentGameState: { // Only present when game in progress
         *     currentLevel: 3,
         *     moveCount: 15,
         *     gridState: [[1, 2, 3], ...],
         *     emptyPos: { row: 2, col: 2 },
         *     timestamp: 1234567890
         *   }
         * }
         * 
         * SAVE SYSTEM:
         * - Auto-saves every 3 seconds during active gameplay
         * - Auto-saves on page unload, visibility change, level completion
         * - Resume functionality: Shows prompt on load if saved game exists
         * - Manual save available in settings
         * - Progress (levels, skins, times) always persisted
         * ==================================================
         */

        // ===== GLOBAL STATE =====
        let canvas, ctx;
        let currentMode = 'play';
        let currentScreen = 'levelSelect'; // 'levelSelect', 'game', 'results'
        let assetCache = {};
        let audioContext, audioBuffers = {};
        let musicSource = null;
        let musicGainNode, sfxGainNode;
        
        // User progress (loaded from lib.getUserGameState())
        let userProgress = {
            unlockedLevels: [1],
            unlockedSkins: ['tile_classic'],
            bestTimes: {}
        };
        
        // Level definitions
        const LEVELS = [
            { level: 1, gridSize: 3, time: 90, skin: 'tile_classic', isBoss: false },
            { level: 2, gridSize: 3, time: 90, skin: 'tile_christmas', isBoss: false },
            { level: 3, gridSize: 3, time: 90, skin: 'tile_wooden_blocks', isBoss: false },
            { level: 4, gridSize: 4, time: 120, skin: 'tile_ocean_waves', isBoss: false },
            { level: 5, gridSize: 4, time: 120, skin: 'tile_sunset_gradient', isBoss: false },
            { level: 6, gridSize: 4, time: 120, skin: 'tile_retro_pixel', isBoss: false },
            { level: 7, gridSize: 5, time: 180, skin: 'tile_galaxy_space', isBoss: false },
            { level: 8, gridSize: 5, time: 180, skin: 'tile_candy_pop', isBoss: false },
            { level: 9, gridSize: 5, time: 180, skin: 'tile_minimalist_mono', isBoss: false },
            { level: 10, gridSize: 5, time: 180, skin: 'tile_golden_luxury', isBoss: false },
            { level: 11, gridSize: 5, time: 120, skin: 'tile_pumpkin_scary', isBoss: true },
            { level: 12, gridSize: 8, time: 300, skin: 'tile_crown_gems', isBoss: true }
        ];
        
        const SKIN_NAMES = {
            'tile_classic': 'Classic',
            'tile_neon_glow': 'Neon Glow',
            'tile_wooden_blocks': 'Wooden Blocks',
            'tile_ocean_waves': 'Ocean Waves',
            'tile_sunset_gradient': 'Sunset Gradient',
            'tile_retro_pixel': 'Retro Pixel',
            'tile_galaxy_space': 'Galaxy Space',
            'tile_candy_pop': 'Candy Pop',
            'tile_minimalist_mono': 'Minimalist Mono',
            'tile_golden_luxury': 'Golden Luxury',
            'tile_christmas': 'Christmas',
            'tile_pumpkin_scary': 'Scary Pumpkin',
            'tile_crown_gems': 'Crown with Gems'
        };
        
        // Game state
        let currentLevel = null;
        let grid = [];
        let emptyPos = { row: 0, col: 0 };
        let gridSize = 3;
        let timeRemaining = 90;
        let moveCount = 0;
        let gameActive = false;
        let lastTime = 0;
        let animatingTile = null;
        
        // UI state
        let hoveredTile = null;
        let selectedLevelButton = null;
        let levelSelectScrollOffset = 0;
        const LEVEL_CARD_HEIGHT = 140;
        const LEVEL_CARD_GAP = 16;
        
        // Snow particle system
        let snowflakes = [];
        const MAX_SNOWFLAKES = 80;
        

        
        function initSnow() {
            snowflakes = [];
            for (let i = 0; i < MAX_SNOWFLAKES; i++) {
                snowflakes.push({
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height - canvas.height,
                    size: Math.random() * 3 + 1,
                    speed: Math.random() * 1 + 0.5,
                    opacity: Math.random() * 0.5 + 0.3,
                    wobble: Math.random() * 2,
                    wobbleSpeed: Math.random() * 0.02 + 0.01
                });
            }
        }
        
        function updateSnow(deltaTime) {
            for (let i = 0; i < snowflakes.length; i++) {
                const flake = snowflakes[i];
                flake.y += flake.speed * 100 * deltaTime;
                flake.x += Math.sin(flake.wobble) * 20 * deltaTime;
                flake.wobble += flake.wobbleSpeed;
                
                // Reset snowflake when it falls off screen
                if (flake.y > canvas.height) {
                    flake.y = -10;
                    flake.x = Math.random() * canvas.width;
                }
                
                // Wrap horizontally
                if (flake.x < -10) flake.x = canvas.width + 10;
                if (flake.x > canvas.width + 10) flake.x = -10;
            }
        }
        

        
        function drawSnow() {
            for (let i = 0; i < snowflakes.length; i++) {
                const flake = snowflakes[i];
                
                ctx.save();
                ctx.globalAlpha = flake.opacity;
                ctx.fillStyle = 'white';
                
                // Draw snowflake as a circle
                ctx.beginPath();
                ctx.arc(flake.x, flake.y, flake.size, 0, Math.PI * 2);
                ctx.fill();
                
                ctx.restore();
            }
        }
        

        
        // ===== SAVE INDICATOR =====
        
        let saveIndicatorTimeout = null;
        
        function showSaveIndicator() {
            // Silent save - no visual indicator
            // Only show feedback when explicitly exiting
        }
        
        // ===== INITIALIZATION =====
        
        async function preloadAssets() {
            lib.log('Preloading assets...');
            
            // Load images
            const imageAssets = [
                'tile_classic', 'tile_neon_glow', 'tile_wooden_blocks',
                'tile_ocean_waves', 'tile_sunset_gradient', 'tile_retro_pixel',
                'tile_galaxy_space', 'tile_candy_pop', 'tile_minimalist_mono',
                'tile_golden_luxury', 'tile_christmas', 'tile_pumpkin_scary', 'tile_crown_gems', 'background_cute'
            ];
            
            const imagePromises = imageAssets.map(id => {
                return new Promise((resolve, reject) => {
                    const assetInfo = lib.getAsset(id);
                    if (assetInfo) {
                        const img = new Image();
                        img.onload = () => {
                            assetCache[id] = img;
                            resolve();
                        };
                        img.onerror = reject;
                        img.src = assetInfo.url;
                    } else {
                        reject(new Error(`Asset ${id} not found`));
                    }
                });
            });
            
            await Promise.all(imagePromises);
            lib.log('Images loaded');
            
            // Setup audio
            audioContext = new (window.AudioContext || window.webkitAudioContext)();
            musicGainNode = audioContext.createGain();
            sfxGainNode = audioContext.createGain();
            musicGainNode.connect(audioContext.destination);
            sfxGainNode.connect(audioContext.destination);
            
            // Load audio
            const audioAssets = [
                'jingle_bells_music', 'tile_slide_sfx', 'level_complete_sfx',
                'level_fail_sfx', 'button_click_sfx', 'skin_unlock_sfx'
            ];
            
            const audioPromises = audioAssets.map(async id => {
                const assetInfo = lib.getAsset(id);
                if (assetInfo) {
                    try {
                        const response = await fetch(assetInfo.url);
                        const arrayBuffer = await response.arrayBuffer();
                        const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
                        audioBuffers[id] = audioBuffer;
                    } catch (e) {
                        lib.log(`Failed to load audio ${id}: ${e.message}`);
                    }
                }
            });
            
            await Promise.all(audioPromises);
            lib.log('Audio loaded');
        }
        
        function initializeGameConfig() {
            if (!window.gameConfig) {
                window.gameConfig = {};
            }
            
            if (!window.gameConfig.selectedSkin) {
                window.gameConfig.selectedSkin = 'tile_classic';
            }
            if (!window.gameConfig.audio) {
                window.gameConfig.audio = {
                    musicVolume: 0.7,
                    sfxVolume: 0.8,
                    musicEnabled: true,
                    sfxEnabled: true
                };
            }
            if (!window.gameConfig.customShuffleComplexity) {
                window.gameConfig.customShuffleComplexity = 'medium';
            }
        }
        
        async function loadUserProgress() {
            try {
                const saved = await lib.getUserGameState();
                if (saved) {
                    lib.log('User game state loaded from storage');
                    // Extract game state if it exists
                    if (saved.currentGameState) {
                        // Store for potential resume
                        window.savedGameState = saved.currentGameState;
                        lib.log(`Found saved game: Level ${saved.currentGameState.currentLevel}, ${saved.currentGameState.moveCount} moves`);
                        // Remove from userProgress to keep it clean
                        const { currentGameState, ...progressOnly } = saved;
                        userProgress = progressOnly;
                    } else {
                        userProgress = saved;
                        window.savedGameState = null;
                        lib.log('No saved game in progress');
                    }
                } else {
                    lib.log('No saved data found - starting fresh');
                    window.savedGameState = null;
                }
            } catch (error) {
                lib.log(`Failed to load user progress: ${error.message}`);
                window.savedGameState = null;
            }
            
            // Ensure at least level 1 is unlocked
            if (!userProgress.unlockedLevels || userProgress.unlockedLevels.length === 0) {
                userProgress.unlockedLevels = [1];
            }
            // Always unlock all skins
            userProgress.unlockedSkins = Object.keys(SKIN_NAMES);
            if (!userProgress.bestTimes) {
                userProgress.bestTimes = {};
            }
            
            lib.log(`Progress loaded: ${userProgress.unlockedLevels.length} levels unlocked, ${Object.keys(userProgress.bestTimes).length} levels completed`);
        }
        
        async function saveUserProgress() {
            try {
                await lib.saveUserGameState(userProgress);
                lib.log(`Progress saved: ${userProgress.unlockedLevels.length} levels, ${Object.keys(userProgress.bestTimes).length} completed`);
            } catch (error) {
                lib.log(`Failed to save progress: ${error.message}`);
            }
        }
        
        async function saveGameState() {
            try {
                // Also save current level state if in game
                if (currentScreen === 'game' && currentLevel && gameActive) {
                    const gameState = {
                        currentLevel: currentLevel.level,
                        moveCount: moveCount,
                        gridState: grid.map(row => [...row]),
                        emptyPos: { ...emptyPos },
                        timestamp: Date.now()
                    };
                    // Store in a separate key for resuming mid-game
                    const fullState = {
                        ...userProgress,
                        currentGameState: gameState
                    };
                    await lib.saveUserGameState(fullState);
                    window.savedGameState = gameState; // Keep in sync
                    showSaveIndicator();
                    lib.log(`Game state saved: Level ${gameState.currentLevel}, Moves ${gameState.moveCount}`);
                } else {
                    // Just save progress without game state
                    await lib.saveUserGameState(userProgress);
                    lib.log('Progress saved (no active game)');
                }
            } catch (error) {
                lib.log(`Failed to save game state: ${error.message}`);
            }
        }
        
        // ===== AUDIO FUNCTIONS =====
        
        function playMusic() {
            if (!window.gameConfig.audio.musicEnabled) return;
            if (musicSource) return; // Already playing
            
            if (audioBuffers['jingle_bells_music']) {
                musicSource = audioContext.createBufferSource();
                musicSource.buffer = audioBuffers['jingle_bells_music'];
                musicSource.loop = true;
                musicSource.connect(musicGainNode);
                musicGainNode.gain.value = window.gameConfig.audio.musicVolume;
                musicSource.start(0);
            }
        }
        
        function stopMusic() {
            if (musicSource) {
                musicSource.stop();
                musicSource = null;
            }
        }
        
        function updateMusicVolume() {
            if (musicGainNode) {
                musicGainNode.gain.value = window.gameConfig.audio.musicVolume;
            }
        }
        
        function updateSfxVolume() {
            if (sfxGainNode) {
                sfxGainNode.gain.value = window.gameConfig.audio.sfxVolume;
            }
        }
        
        function playSfx(id) {
            if (!window.gameConfig.audio.sfxEnabled) return;
            
            if (audioBuffers[id]) {
                const source = audioContext.createBufferSource();
                source.buffer = audioBuffers[id];
                source.connect(sfxGainNode);
                source.start(0);
            }
        }
        
        // ===== PUZZLE LOGIC =====
        
        function createSolvedGrid(size) {
            const g = [];
            let num = 1;
            for (let r = 0; r < size; r++) {
                const row = [];
                for (let c = 0; c < size; c++) {
                    if (r === size - 1 && c === size - 1) {
                        row.push(0); // Empty space
                    } else {
                        row.push(num++);
                    }
                }
                g.push(row);
            }
            return g;
        }
        
        function shuffleGrid(g, size, moves) {
            let emptyR = size - 1;
            let emptyC = size - 1;
            
            const directions = [
                { dr: -1, dc: 0 }, // up
                { dr: 1, dc: 0 },  // down
                { dr: 0, dc: -1 }, // left
                { dr: 0, dc: 1 }   // right
            ];
            
            for (let i = 0; i < moves; i++) {
                const validMoves = [];
                for (const dir of directions) {
                    const newR = emptyR + dir.dr;
                    const newC = emptyC + dir.dc;
                    if (newR >= 0 && newR < size && newC >= 0 && newC < size) {
                        validMoves.push({ r: newR, c: newC });
                    }
                }
                
                const move = validMoves[Math.floor(Math.random() * validMoves.length)];
                g[emptyR][emptyC] = g[move.r][move.c];
                g[move.r][move.c] = 0;
                emptyR = move.r;
                emptyC = move.c;
            }
            
            return { row: emptyR, col: emptyC };
        }
        
        function isAdjacent(r, c) {
            const dr = Math.abs(r - emptyPos.row);
            const dc = Math.abs(c - emptyPos.col);
            return (dr === 1 && dc === 0) || (dr === 0 && dc === 1);
        }
        
        function canMoveTile(r, c) {
            return isAdjacent(r, c);
        }
        
        function moveTile(r, c) {
            if (!canMoveTile(r, c) || animatingTile) return false;
            
            // Start animation - animate the empty space moving to the tile's position
            animatingTile = {
                value: grid[r][c],
                fromRow: emptyPos.row,
                fromCol: emptyPos.col,
                toRow: r,
                toCol: c,
                progress: 0,
                isEmptySpace: true
            };
            
            // Update grid immediately
            grid[emptyPos.row][emptyPos.col] = grid[r][c];
            grid[r][c] = 0;
            emptyPos = { row: r, col: c };
            
            moveCount++;
            playSfx('tile_slide_sfx');
            
            return true;
        }
        
        function isSolved() {
            let expected = 1;
            for (let r = 0; r < gridSize; r++) {
                for (let c = 0; c < gridSize; c++) {
                    if (r === gridSize - 1 && c === gridSize - 1) {
                        return grid[r][c] === 0;
                    }
                    if (grid[r][c] !== expected) return false;
                    expected++;
                }
            }
            return true;
        }
        
        function startLevel(levelNum) {
            currentLevel = LEVELS[levelNum - 1];
            gridSize = window.gameConfig.customGridSize || currentLevel.gridSize;
            moveCount = 0;
            gameActive = true;
            currentScreen = 'game';
            
            // Clear any saved game state when starting a fresh level
            window.savedGameState = null;
            
            // Create and shuffle grid
            grid = createSolvedGrid(gridSize);
            
            const complexityMap = {
                'easy': 150,
                'medium': 250,
                'hard': 350
            };
            const shuffleMoves = complexityMap[window.gameConfig.customShuffleComplexity] || 250;
            
            emptyPos = shuffleGrid(grid, gridSize, shuffleMoves);
            
            lastTime = performance.now();
            
            lib.log(`Started Level ${levelNum} (${gridSize}×${gridSize})`);
        }
        
        function resumeGame() {
            if (!window.savedGameState) {
                lib.log('No saved game to resume');
                return;
            }
            
            const saved = window.savedGameState;
            
            // Restore level
            currentLevel = LEVELS[saved.currentLevel - 1];
            gridSize = currentLevel.gridSize;
            
            // Restore game state
            moveCount = saved.moveCount;
            grid = saved.gridState.map(row => [...row]);
            emptyPos = { ...saved.emptyPos };
            
            // Set to game screen
            gameActive = true;
            currentScreen = 'game';
            
            lastTime = performance.now();
            
            lib.log(`Game resumed: Level ${saved.currentLevel}, ${saved.moveCount} moves`);
        }
        
        async function discardSavedGame() {
            window.savedGameState = null;
            // Save progress without the current game state
            await saveUserProgress();
            lib.log('Saved game discarded - starting fresh');
            currentScreen = 'levelSelect';
        }
        
        function showResumePrompt() {
            currentScreen = 'resumePrompt';
        }
        
        async function completeLevel() {
            gameActive = false;
            
            // Update progress
            const nextLevel = currentLevel.level + 1;
            if (nextLevel <= LEVELS.length && !userProgress.unlockedLevels.includes(nextLevel)) {
                userProgress.unlockedLevels.push(nextLevel);
                lib.log(`Level ${nextLevel} unlocked!`);
            }
            
            // All skins are unlocked from the start - no need to unlock
            
            // Save best move count
            if (!userProgress.bestTimes[currentLevel.level] || moveCount < userProgress.bestTimes[currentLevel.level]) {
                userProgress.bestTimes[currentLevel.level] = moveCount;
                lib.log(`New best time: ${moveCount} moves`);
            }
            
            // Clear saved game state since level is completed
            window.savedGameState = null;
            
            // Save progress without game state (silent)
            await saveUserProgress();
            playSfx('level_complete_sfx');
            
            currentScreen = 'results';
        }
        

        // ===== RENDERING =====
        
        function drawHeaderButtons() {
            const backBtnX = 32;
            const backBtnY = 20;
            const backBtnSize = 96;
            
            ctx.save();
            ctx.fillStyle = 'rgba(255, 255, 255, 0.2)';
            ctx.shadowColor = 'rgba(0, 0, 0, 0.2)';
            ctx.shadowBlur = 8;
            ctx.beginPath();
            ctx.arc(backBtnX + backBtnSize/2, backBtnY + backBtnSize/2, backBtnSize/2, 0, Math.PI * 2);
            ctx.fill();
            
            ctx.fillStyle = 'white';
            ctx.font = 'bold 40px Arial';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText('←', backBtnX + backBtnSize/2, backBtnY + backBtnSize/2);
            ctx.restore();
            
            // Settings button (right side, in header)
            const settingsBtnX = canvas.width - backBtnSize - 32;
            const settingsBtnY = 20;
            
            ctx.save();
            ctx.fillStyle = 'rgba(255, 255, 255, 0.2)';
            ctx.shadowColor = 'rgba(0, 0, 0, 0.2)';
            ctx.shadowBlur = 8;
            ctx.beginPath();
            ctx.arc(settingsBtnX + backBtnSize/2, settingsBtnY + backBtnSize/2, backBtnSize/2, 0, Math.PI * 2);
            ctx.fill();
            
            ctx.fillStyle = 'white';
            ctx.font = '40px Arial';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText('⚙️', settingsBtnX + backBtnSize/2, settingsBtnY + backBtnSize/2);
            ctx.restore();
        }
        
        function drawLevelSelect() {
            // Background gradient (already set by CSS)
            ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Draw header buttons
            drawHeaderButtons();
            
            // Title with modern styling
            ctx.save();
            ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
            ctx.shadowBlur = 20;
            ctx.shadowOffsetY = 4;
            ctx.fillStyle = 'white';
            ctx.font = 'bold 64px Poppins, sans-serif';
            ctx.textAlign = 'center';
            ctx.fillText('COZY TILES', canvas.width / 2, 100);
            ctx.restore();
            
            // Subtitle
            ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
            ctx.font = '20px Poppins, sans-serif';
            ctx.textAlign = 'center';
            ctx.fillText('Slide to solve the puzzle', canvas.width / 2, 140);
            
            // Level cards - vertical scrolling list
            const cardWidth = 640;
            const cardHeight = LEVEL_CARD_HEIGHT;
            const gap = LEVEL_CARD_GAP;
            const startX = (canvas.width - cardWidth) / 2;
            const startY = 200;
            
            // Calculate scroll bounds
            const totalContentHeight = LEVELS.length * (cardHeight + gap);
            const viewportHeight = canvas.height - startY - 160; // Account for bottom bar
            const maxScroll = Math.max(0, totalContentHeight - viewportHeight);
            
            // Clamp scroll offset
            levelSelectScrollOffset = Math.max(0, Math.min(levelSelectScrollOffset, maxScroll));
            
            for (let i = 0; i < LEVELS.length; i++) {
                const level = LEVELS[i];
                const y = startY + i * (cardHeight + gap) - levelSelectScrollOffset;
                
                // Skip if off screen
                if (y + cardHeight < startY || y > canvas.height - 160) continue;
                
                const isUnlocked = userProgress.unlockedLevels.includes(level.level);
                const isHovered = selectedLevelButton === i;
                
                // Glass card background
                ctx.save();
                ctx.fillStyle = isUnlocked ? 
                    (isHovered ? 'rgba(255, 255, 255, 0.25)' : 'rgba(255, 255, 255, 0.15)') : 
                    'rgba(0, 0, 0, 0.3)';
                ctx.shadowColor = 'rgba(0, 0, 0, 0.2)';
                ctx.shadowBlur = 16;
                ctx.shadowOffsetY = 4;
                
                // Rounded rectangle
                const radius = 20;
                ctx.beginPath();
                ctx.moveTo(startX + radius, y);
                ctx.lineTo(startX + cardWidth - radius, y);
                ctx.quadraticCurveTo(startX + cardWidth, y, startX + cardWidth, y + radius);
                ctx.lineTo(startX + cardWidth, y + cardHeight - radius);
                ctx.quadraticCurveTo(startX + cardWidth, y + cardHeight, startX + cardWidth - radius, y + cardHeight);
                ctx.lineTo(startX + radius, y + cardHeight);
                ctx.quadraticCurveTo(startX, y + cardHeight, startX, y + cardHeight - radius);
                ctx.lineTo(startX, y + radius);
                ctx.quadraticCurveTo(startX, y, startX + radius, y);
                ctx.closePath();
                ctx.fill();
                
                // Border
                ctx.strokeStyle = isUnlocked ? 'rgba(255, 255, 255, 0.3)' : 'rgba(255, 255, 255, 0.1)';
                ctx.lineWidth = 2;
                ctx.stroke();
                ctx.restore();
                
                if (isUnlocked) {
                    // Boss level indicator
                    if (level.isBoss) {
                        ctx.fillStyle = 'rgba(239, 68, 68, 0.3)';
                        ctx.fillRect(startX, y, cardWidth, cardHeight);
                        
                        ctx.fillStyle = '#ef4444';
                        ctx.font = 'bold 32px Poppins, sans-serif';
                        ctx.textAlign = 'center';
                        ctx.fillText('⚔️ BOSS LEVEL ⚔️', startX + cardWidth / 2, y + 35);
                    }
                    
                    // Level number - large and bold
                    ctx.fillStyle = level.isBoss ? '#ef4444' : 'white';
                    ctx.font = 'bold 48px Poppins, sans-serif';
                    ctx.textAlign = 'left';
                    ctx.fillText(`${level.level}`, startX + 24, y + 60);
                    
                    // Level info
                    ctx.font = '600 20px Poppins, sans-serif';
                    ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
                    ctx.fillText(`${level.gridSize}×${level.gridSize} Grid`, startX + 100, y + 45);
                    ctx.fillText(`${level.time}s`, startX + 100, y + 75);
                    
                    // Best time badge
                    if (userProgress.bestTimes[level.level]) {
                        ctx.fillStyle = 'rgba(74, 222, 128, 0.2)';
                        ctx.fillRect(startX + 100, y + 90, 140, 32);
                        ctx.fillStyle = '#4ade80';
                        ctx.font = '600 16px Poppins, sans-serif';
                        ctx.fillText(`⭐ ${userProgress.bestTimes[level.level].toFixed(1)}s`, startX + 110, y + 110);
                    }
                    
                    // Skin preview
                    const skinImg = assetCache[level.skin];
                    if (skinImg) {
                        ctx.save();
                        ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
                        ctx.shadowBlur = 8;
                        ctx.drawImage(skinImg, startX + cardWidth - 120, y + 20, 100, 100);
                        ctx.restore();
                    }
                } else {
                    // Locked state
                    ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
                    ctx.font = '64px Arial';
                    ctx.textAlign = 'center';
                    ctx.fillText('🔒', startX + cardWidth / 2, y + cardHeight / 2 + 20);
                    
                    ctx.font = '600 20px Poppins, sans-serif';
                    ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
                    ctx.fillText('Complete previous level', startX + cardWidth / 2, y + cardHeight - 20);
                }
            }
            
            // Draw scroll bar indicator if needed
            if (maxScroll > 0) {
                const scrollBarX = canvas.width - 12;
                const scrollBarY = startY;
                const scrollBarHeight = viewportHeight;
                const scrollBarWidth = 8;
                
                // Background track
                ctx.fillStyle = 'rgba(255, 255, 255, 0.1)';
                ctx.fillRect(scrollBarX - scrollBarWidth/2, scrollBarY, scrollBarWidth, scrollBarHeight);
                
                // Scroll thumb
                const thumbHeight = Math.max(40, (viewportHeight / totalContentHeight) * scrollBarHeight);
                const thumbY = scrollBarY + (levelSelectScrollOffset / maxScroll) * (scrollBarHeight - thumbHeight);
                
                ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
                const radius = 4;
                ctx.beginPath();
                ctx.moveTo(scrollBarX - scrollBarWidth/2 + radius, thumbY);
                ctx.lineTo(scrollBarX + scrollBarWidth/2 - radius, thumbY);
                ctx.quadraticCurveTo(scrollBarX + scrollBarWidth/2, thumbY, scrollBarX + scrollBarWidth/2, thumbY + radius);
                ctx.lineTo(scrollBarX + scrollBarWidth/2, thumbY + thumbHeight - radius);
                ctx.quadraticCurveTo(scrollBarX + scrollBarWidth/2, thumbY + thumbHeight, scrollBarX + scrollBarWidth/2 - radius, thumbY + thumbHeight);
                ctx.lineTo(scrollBarX - scrollBarWidth/2 + radius, thumbY + thumbHeight);
                ctx.quadraticCurveTo(scrollBarX - scrollBarWidth/2, thumbY + thumbHeight, scrollBarX - scrollBarWidth/2, thumbY + thumbHeight - radius);
                ctx.lineTo(scrollBarX - scrollBarWidth/2, thumbY + radius);
                ctx.quadraticCurveTo(scrollBarX - scrollBarWidth/2, thumbY, scrollBarX - scrollBarWidth/2 + radius, thumbY);
                ctx.closePath();
                ctx.fill();
            }
        }
        
        function drawGame() {
            
            // Top bar - glass panel (removed black background)
            ctx.save();
            ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
            ctx.shadowBlur = 16;
            ctx.restore();
            
            // Draw header buttons
            drawHeaderButtons();
            
            // Level info
            ctx.fillStyle = currentLevel.isBoss ? '#ef4444' : 'white';
            ctx.font = '600 24px Poppins, sans-serif';
            ctx.textAlign = 'center';
            if (currentLevel.isBoss) {
                ctx.fillText('⚔️ BOSS LEVEL ⚔️', canvas.width / 2, 40);
            } else {
                ctx.fillText(`Level ${currentLevel.level}`, canvas.width / 2, 40);
            }
            
            // Moves counter (secondary info)
            ctx.font = '400 18px Poppins, sans-serif';
            ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
            ctx.fillText(`${moveCount} moves`, canvas.width / 2, 70);
            

            
            // Calculate grid layout - centered with proper spacing
            const maxGridSize = Math.min(canvas.width - 48, canvas.height - 400);
            const tileSize = Math.floor(maxGridSize / gridSize) - 12;
            const gridWidth = gridSize * tileSize + (gridSize - 1) * 12;
            const gridHeight = gridSize * tileSize + (gridSize - 1) * 12;
            const gridX = (canvas.width - gridWidth) / 2;
            const gridY = 180;
            
            // Draw tiles with glass effect
            const selectedSkin = window.gameConfig.selectedSkin;
            const skinImg = assetCache[selectedSkin];
            
            // Draw animated empty space if animation is in progress
            if (animatingTile && animatingTile.isEmptySpace) {
                // Empty space is now invisible - just skip drawing it
            }
            
            for (let r = 0; r < gridSize; r++) {
                for (let c = 0; c < gridSize; c++) {
                    const value = grid[r][c];
                    let x = gridX + c * (tileSize + 12);
                    let y = gridY + r * (tileSize + 12);
                    
                    // Check if this tile is being animated (empty space moving to this position)
                    if (animatingTile && animatingTile.isEmptySpace && animatingTile.toRow === r && animatingTile.toCol === c && value !== 0) {
                        // This tile stays in place while empty space animates toward it
                        // No position change needed - tile renders at its grid position
                    }
                    
                    ctx.save();
                    
                    if (value === 0) {
                        // Empty space - now invisible/transparent
                        // Just skip drawing anything here
                    } else {
                        // Tile shadow
                        ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
                        ctx.shadowBlur = 12;
                        ctx.shadowOffsetY = 4;
                        
                        // Draw tile with rounded corners
                        const radius = 16;
                        ctx.beginPath();
                        ctx.moveTo(x + radius, y);
                        ctx.lineTo(x + tileSize - radius, y);
                        ctx.quadraticCurveTo(x + tileSize, y, x + tileSize, y + radius);
                        ctx.lineTo(x + tileSize, y + tileSize - radius);
                        ctx.quadraticCurveTo(x + tileSize, y + tileSize, x + tileSize - radius, y + tileSize);
                        ctx.lineTo(x + radius, y + tileSize);
                        ctx.quadraticCurveTo(x, y + tileSize, x, y + tileSize - radius);
                        ctx.lineTo(x, y + radius);
                        ctx.quadraticCurveTo(x, y, x + radius, y);
                        ctx.closePath();
                        
                        // Clip to rounded rectangle
                        ctx.clip();
                        
                        // Draw skin background
                        if (skinImg) {
                            ctx.drawImage(skinImg, x, y, tileSize, tileSize);
                        } else {
                            ctx.fillStyle = '#667eea';
                            ctx.fill();
                        }
                        
                        // Highlight if hoverable
                        if (hoveredTile && hoveredTile.row === r && hoveredTile.col === c && canMoveTile(r, c)) {
                            ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
                            ctx.fill();
                        }
                        
                        ctx.restore();
                        ctx.save();
                        
                        // Draw number with strong contrast
                        const fontSize = Math.floor(tileSize * 0.5);
                        ctx.font = `bold ${fontSize}px Poppins, sans-serif`;
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'middle';
                        
                        // Text shadow for readability
                        ctx.shadowColor = 'rgba(0, 0, 0, 0.8)';
                        ctx.shadowBlur = 8;
                        ctx.fillStyle = 'white';
                        ctx.fillText(value.toString(), x + tileSize / 2, y + tileSize / 2);
                    }
                    
                    ctx.restore();
                }
            }
        }
        
        function drawResults() {
            // Dark overlay
            ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            const won = true; // Always won since we removed timer
            
            // Result card - glass panel
            const cardWidth = 640;
            const cardHeight = 600;
            const cardX = (canvas.width - cardWidth) / 2;
            const cardY = 200;
            
            ctx.save();
            ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
            ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
            ctx.shadowBlur = 32;
            
            const radius = 24;
            ctx.beginPath();
            ctx.moveTo(cardX + radius, cardY);
            ctx.lineTo(cardX + cardWidth - radius, cardY);
            ctx.quadraticCurveTo(cardX + cardWidth, cardY, cardX + cardWidth, cardY + radius);
            ctx.lineTo(cardX + cardWidth, cardY + cardHeight - radius);
            ctx.quadraticCurveTo(cardX + cardWidth, cardY + cardHeight, cardX + cardWidth - radius, cardY + cardHeight);
            ctx.lineTo(cardX + radius, cardY + cardHeight);
            ctx.quadraticCurveTo(cardX, cardY + cardHeight, cardX, cardY + cardHeight - radius);
            ctx.lineTo(cardX, cardY + radius);
            ctx.quadraticCurveTo(cardX, cardY, cardX + radius, cardY);
            ctx.closePath();
            ctx.fill();
            
            ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
            ctx.lineWidth = 2;
            ctx.stroke();
            ctx.restore();
            
            // Result icon
            ctx.font = '96px Arial';
            ctx.textAlign = 'center';
            ctx.fillText('🎉', canvas.width / 2, cardY + 100);
            
            // Title
            ctx.save();
            ctx.shadowColor = currentLevel.isBoss ? 'rgba(239, 68, 68, 0.5)' : 'rgba(74, 222, 128, 0.5)';
            ctx.shadowBlur = 20;
            ctx.fillStyle = currentLevel.isBoss ? '#ef4444' : '#4ade80';
            ctx.font = 'bold 56px Poppins, sans-serif';
            if (currentLevel.isBoss) {
                ctx.fillText('BOSS DEFEATED!', canvas.width / 2, cardY + 200);
            } else {
                ctx.fillText('COMPLETE!', canvas.width / 2, cardY + 200);
            }
            ctx.restore();
            
            // Stats
            ctx.fillStyle = 'white';
            ctx.font = '600 28px Poppins, sans-serif';
            ctx.fillText(`Moves: ${moveCount}`, canvas.width / 2, cardY + 280);
            
            // Bottom action bar
            const barHeight = 140;
            const barY = canvas.height - barHeight;
            
            ctx.save();
            ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
            ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
            ctx.shadowBlur = 16;
            ctx.shadowOffsetY = -4;
            ctx.fillRect(0, barY, canvas.width, barHeight);
            ctx.restore();
            
            // Button layout
            const btnWidth = 200;
            const btnHeight = 96;
            const btnGap = 16;
            const btnY = barY + 22;
            
            if (currentLevel.level < LEVELS.length) {
                // Two buttons: Next Level + Retry
                const btn1X = (canvas.width - (btnWidth * 2 + btnGap)) / 2;
                const btn2X = btn1X + btnWidth + btnGap;
                
                // Next Level button (primary)
                drawButton(btn1X, btnY, btnWidth, btnHeight, 'Next Level', '#667eea', 'nextLevel');
                
                // Retry button (secondary)
                drawButton(btn2X, btnY, btnWidth, btnHeight, 'Retry', 'rgba(255, 255, 255, 0.2)', 'retry');
            } else {
                // Two buttons: Retry + Menu
                const btn1X = (canvas.width - (btnWidth * 2 + btnGap)) / 2;
                const btn2X = btn1X + btnWidth + btnGap;
                
                // Retry button (primary)
                drawButton(btn1X, btnY, btnWidth, btnHeight, 'Retry', '#fbbf24', 'retry');
                
                // Menu button (secondary)
                drawButton(btn2X, btnY, btnWidth, btnHeight, 'Menu', 'rgba(255, 255, 255, 0.2)', 'menu');
            }
        }
        
        function drawButton(x, y, width, height, text, color, id) {
            ctx.save();
            
            // Button background
            ctx.fillStyle = color;
            ctx.shadowColor = 'rgba(0, 0, 0, 0.2)';
            ctx.shadowBlur = 8;
            
            const radius = 16;
            ctx.beginPath();
            ctx.moveTo(x + radius, y);
            ctx.lineTo(x + width - radius, y);
            ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
            ctx.lineTo(x + width, y + height - radius);
            ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
            ctx.lineTo(x + radius, y + height);
            ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
            ctx.lineTo(x, y + radius);
            ctx.quadraticCurveTo(x, y, x + radius, y);
            ctx.closePath();
            ctx.fill();
            
            // Button text
            ctx.fillStyle = 'white';
            ctx.font = 'bold 24px Poppins, sans-serif';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(text, x + width / 2, y + height / 2);
            
            ctx.restore();
            
            // Store button bounds for click detection
            if (!window.resultButtons) window.resultButtons = {};
            window.resultButtons[id] = { x, y, width, height };
        }
        
        function drawResumePrompt() {
            // Dark overlay
            ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Resume card - glass panel
            const cardWidth = 640;
            const cardHeight = 640;
            const cardX = (canvas.width - cardWidth) / 2;
            const cardY = 300;
            
            ctx.save();
            ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
            ctx.shadowColor = 'rgba(0, 0, 0, 0.3)';
            ctx.shadowBlur = 32;
            
            const radius = 24;
            ctx.beginPath();
            ctx.moveTo(cardX + radius, cardY);
            ctx.lineTo(cardX + cardWidth - radius, cardY);
            ctx.quadraticCurveTo(cardX + cardWidth, cardY, cardX + cardWidth, cardY + radius);
            ctx.lineTo(cardX + cardWidth, cardY + cardHeight - radius);
            ctx.quadraticCurveTo(cardX + cardWidth, cardY + cardHeight, cardX + cardWidth - radius, cardY + cardHeight);
            ctx.lineTo(cardX + radius, cardY + cardHeight);
            ctx.quadraticCurveTo(cardX, cardY + cardHeight, cardX, cardY + cardHeight - radius);
            ctx.lineTo(cardX, cardY + radius);
            ctx.quadraticCurveTo(cardX, cardY, cardX + radius, cardY);
            ctx.closePath();
            ctx.fill();
            
            ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
            ctx.lineWidth = 2;
            ctx.stroke();
            ctx.restore();
            
            // Icon
            ctx.font = '96px Arial';
            ctx.textAlign = 'center';
            ctx.fillStyle = 'white';
            ctx.fillText('💾', canvas.width / 2, cardY + 100);
            
            // Title
            ctx.save();
            ctx.shadowColor = 'rgba(102, 126, 234, 0.5)';
            ctx.shadowBlur = 20;
            ctx.fillStyle = '#667eea';
            ctx.font = 'bold 48px Poppins, sans-serif';
            ctx.fillText('SAVED GAME FOUND', canvas.width / 2, cardY + 210);
            ctx.restore();
            
            // Info
            ctx.fillStyle = 'white';
            ctx.font = '600 24px Poppins, sans-serif';
            ctx.fillText('You have an unfinished game', canvas.width / 2, cardY + 280);
            
            // Saved game details
            const saved = window.savedGameState;
            ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
            ctx.font = '400 20px Poppins, sans-serif';
            ctx.fillText(`Level ${saved.currentLevel} • ${saved.moveCount} moves`, canvas.width / 2, cardY + 320);
            
            // Time ago
            const timeAgo = getTimeAgo(saved.timestamp);
            ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
            ctx.font = '400 18px Poppins, sans-serif';
            ctx.fillText(`Last played ${timeAgo}`, canvas.width / 2, cardY + 350);
            
            // Buttons
            const btnWidth = 280;
            const btnHeight = 96;
            const btnGap = 16;
            const btnY = cardY + 440;
            
            const btn1X = (canvas.width - (btnWidth * 2 + btnGap)) / 2;
            const btn2X = btn1X + btnWidth + btnGap;
            
            // Resume button (primary)
            drawButton(btn1X, btnY, btnWidth, btnHeight, '▶️ Resume', '#667eea', 'resume');
            
            // New Game button (secondary)
            drawButton(btn2X, btnY, btnWidth, btnHeight, '🆕 New Game', 'rgba(255, 255, 255, 0.2)', 'newGame');
        }
        
        function getTimeAgo(timestamp) {
            const now = Date.now();
            const diff = now - timestamp;
            const seconds = Math.floor(diff / 1000);
            const minutes = Math.floor(seconds / 60);
            const hours = Math.floor(minutes / 60);
            const days = Math.floor(hours / 24);
            
            if (days > 0) return `${days} day${days > 1 ? 's' : ''} ago`;
            if (hours > 0) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
            if (minutes > 0) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
            return 'just now';
        }
        
        function render() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            
            // Background with cute theme
            const bgImg = assetCache['background_cute'];
            if (bgImg) {
                ctx.drawImage(bgImg, 0, 0, canvas.width, canvas.height);
            } else {
                // Fallback gradient if background not loaded
                const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
                gradient.addColorStop(0, '#ffc0e0');
                gradient.addColorStop(1, '#b0e0ff');
                ctx.fillStyle = gradient;
                ctx.fillRect(0, 0, canvas.width, canvas.height);
            }
            
            if (currentScreen === 'resumePrompt') {
                drawResumePrompt();
            } else if (currentScreen === 'levelSelect') {
                drawLevelSelect();
            } else if (currentScreen === 'game') {
                drawGame();
            } else if (currentScreen === 'results') {
                drawResults();
            }
            
            // Draw falling snow on top of everything
            drawSnow();
        }
        
        // ===== INPUT HANDLING =====
        
        function getTileAtPosition(x, y) {
            if (currentScreen !== 'game') return null;
            
            const maxGridSize = Math.min(canvas.width - 48, canvas.height - 400);
            const tileSize = Math.floor(maxGridSize / gridSize) - 12;
            const gridWidth = gridSize * tileSize + (gridSize - 1) * 12;
            const gridX = (canvas.width - gridWidth) / 2;
            const gridY = 180;
            
            for (let r = 0; r < gridSize; r++) {
                for (let c = 0; c < gridSize; c++) {
                    const tx = gridX + c * (tileSize + 12);
                    const ty = gridY + r * (tileSize + 12);
                    
                    if (x >= tx && x < tx + tileSize && y >= ty && y < ty + tileSize) {
                        return { row: r, col: c };
                    }
                }
            }
            
            return null;
        }
        
        function handleClick(x, y) {
            playSfx('button_click_sfx');
            
            // Check header buttons (back and settings) - available on levelSelect and game screens
            if (currentScreen === 'levelSelect' || currentScreen === 'game') {
                const backBtnX = 32;
                const backBtnY = 20;
                const backBtnSize = 96;
                
                const dx = x - (backBtnX + backBtnSize/2);
                const dy = y - (backBtnY + backBtnSize/2);
                if (Math.sqrt(dx*dx + dy*dy) < backBtnSize/2) {
                    handleBackNavigation();
                    return;
                }
                
                // Check settings button (now in header)
                const settingsBtnX = canvas.width - backBtnSize - 32;
                const settingsBtnY = 20;
                
                const sdx = x - (settingsBtnX + backBtnSize/2);
                const sdy = y - (settingsBtnY + backBtnSize/2);
                if (Math.sqrt(sdx*sdx + sdy*sdy) < backBtnSize/2) {
                    openSettings();
                    return;
                }
            }
            
            if (currentScreen === 'resumePrompt') {
                // Check resume prompt buttons
                if (window.resultButtons) {
                    for (const [id, btn] of Object.entries(window.resultButtons)) {
                        if (x >= btn.x && x < btn.x + btn.width && 
                            y >= btn.y && y < btn.y + btn.height) {
                            
                            if (id === 'resume') {
                                resumeGame();
                            } else if (id === 'newGame') {
                                discardSavedGame().catch(err => lib.log(`Error discarding save: ${err.message}`));
                            }
                            return;
                        }
                    }
                }
            } else if (currentScreen === 'levelSelect') {
                // Check level cards
                const cardWidth = 640;
                const cardHeight = LEVEL_CARD_HEIGHT;
                const gap = LEVEL_CARD_GAP;
                const startX = (canvas.width - cardWidth) / 2;
                const startY = 200;
                
                for (let i = 0; i < LEVELS.length; i++) {
                    const level = LEVELS[i];
                    const cy = startY + i * (cardHeight + gap) - levelSelectScrollOffset;
                    
                    if (x >= startX && x < startX + cardWidth && y >= cy && y < cy + cardHeight) {
                        if (userProgress.unlockedLevels.includes(level.level)) {
                            startLevel(level.level);
                        }
                        return;
                    }
                }
            } else if (currentScreen === 'game') {
                // Check tile click
                if (gameActive && !animatingTile) {
                    const tile = getTileAtPosition(x, y);
                    if (tile && grid[tile.row][tile.col] !== 0) {
                        moveTile(tile.row, tile.col);
                    }
                }
            } else if (currentScreen === 'results') {
                // Check result buttons
                if (window.resultButtons) {
                    for (const [id, btn] of Object.entries(window.resultButtons)) {
                        if (x >= btn.x && x < btn.x + btn.width && 
                            y >= btn.y && y < btn.y + btn.height) {
                            
                            if (id === 'nextLevel') {
                                startLevel(currentLevel.level + 1);
                            } else if (id === 'retry') {
                                startLevel(currentLevel.level);
                            } else if (id === 'menu') {
                                currentScreen = 'levelSelect';
                            }
                            return;
                        }
                    }
                }
            }
        }
        
        function handleMouseMove(x, y) {
            if (currentScreen === 'levelSelect') {
                // Check level card hover
                const cardWidth = 640;
                const cardHeight = LEVEL_CARD_HEIGHT;
                const gap = LEVEL_CARD_GAP;
                const startX = (canvas.width - cardWidth) / 2;
                const startY = 200;
                
                selectedLevelButton = null;
                
                for (let i = 0; i < LEVELS.length; i++) {
                    const cy = startY + i * (cardHeight + gap) - levelSelectScrollOffset;
                    
                    if (x >= startX && x < startX + cardWidth && y >= cy && y < cy + cardHeight) {
                        selectedLevelButton = i;
                        break;
                    }
                }
            } else if (currentScreen === 'game') {
                hoveredTile = getTileAtPosition(x, y);
            }
        }
        
        // Keyboard controls for tile movement
        function handleKeyDown(e) {
            if (currentScreen !== 'game' || !gameActive || animatingTile) return;
            
            let targetRow = emptyPos.row;
            let targetCol = emptyPos.col;
            
            switch(e.key) {
                case 'ArrowUp':
                    // Move tile below empty space up
                    targetRow = emptyPos.row + 1;
                    break;
                case 'ArrowDown':
                    // Move tile above empty space down
                    targetRow = emptyPos.row - 1;
                    break;
                case 'ArrowLeft':
                    // Move tile to the right of empty space left
                    targetCol = emptyPos.col + 1;
                    break;
                case 'ArrowRight':
                    // Move tile to the left of empty space right
                    targetCol = emptyPos.col - 1;
                    break;
                case 'Escape':
                    if (document.getElementById('settingsModal').classList.contains('active')) {
                        closeSettings();
                    } else {
                        openSettings();
                    }
                    return;
                default:
                    return;
            }
            
            // Check if target is valid
            if (targetRow >= 0 && targetRow < gridSize && targetCol >= 0 && targetCol < gridSize) {
                if (grid[targetRow][targetCol] !== 0) {
                    moveTile(targetRow, targetCol);
                    e.preventDefault();
                }
            }
        }
        
        // ===== SETTINGS UI =====
        
        function openSettings() {
            document.getElementById('settingsModal').classList.add('active');
            updateSettingsUI();
        }
        
        function closeSettings() {
            document.getElementById('settingsModal').classList.remove('active');
        }
        
        function updateSettingsUI() {
            // Update skin grid
            const skinGrid = document.getElementById('skinGrid');
            skinGrid.innerHTML = '';
            
            for (const [skinId, skinName] of Object.entries(SKIN_NAMES)) {
                const isUnlocked = userProgress.unlockedSkins.includes(skinId);
                const isSelected = window.gameConfig.selectedSkin === skinId;
                
                const skinDiv = document.createElement('div');
                skinDiv.className = 'skin-option';
                if (isSelected) skinDiv.classList.add('selected');
                if (!isUnlocked) skinDiv.classList.add('locked');
                
                if (isUnlocked) {
                    const img = document.createElement('img');
                    img.src = assetCache[skinId].src;
                    skinDiv.appendChild(img);
                    
                    const nameLabel = document.createElement('div');
                    nameLabel.className = 'skin-name';
                    nameLabel.textContent = skinName;
                    skinDiv.appendChild(nameLabel);
                    
                    skinDiv.onclick = () => {
                        window.gameConfig.selectedSkin = skinId;
                        updateSettingsUI();
                        playSfx('button_click_sfx');
                        // Save progress when skin is selected
                        saveUserProgress().catch(err => {
                            lib.log(`Failed to save after skin selection: ${err.message}`);
                        });
                    };
                } else {
                    const lock = document.createElement('div');
                    lock.className = 'lock-icon';
                    lock.textContent = '🔒';
                    skinDiv.appendChild(lock);
                    
                    const nameLabel = document.createElement('div');
                    nameLabel.className = 'skin-name';
                    nameLabel.textContent = skinName;
                    skinDiv.appendChild(nameLabel);
                }
                
                skinGrid.appendChild(skinDiv);
            }
            
            // Update sliders
            document.getElementById('musicVolumeSlider').value = window.gameConfig.audio.musicVolume * 100;
            document.getElementById('musicVolumeValue').textContent = Math.round(window.gameConfig.audio.musicVolume * 100);
            
            document.getElementById('sfxVolumeSlider').value = window.gameConfig.audio.sfxVolume * 100;
            document.getElementById('sfxVolumeValue').textContent = Math.round(window.gameConfig.audio.sfxVolume * 100);
            
            // Update toggles
            document.getElementById('musicToggle').checked = window.gameConfig.audio.musicEnabled;
            document.getElementById('sfxToggle').checked = window.gameConfig.audio.sfxEnabled;
            
            // Update dropdowns
            document.getElementById('gridSizeSelect').value = window.gameConfig.customGridSize || 3;
            document.getElementById('shuffleComplexity').value = window.gameConfig.customShuffleComplexity || 'medium';
        }
        
        function resetSettings() {
            window.gameConfig.selectedSkin = 'tile_classic';
            window.gameConfig.customTimer = null;
            window.gameConfig.customGridSize = null;
            window.gameConfig.customShuffleComplexity = 'medium';
            window.gameConfig.audio = {
                musicVolume: 0.7,
                sfxVolume: 0.8,
                musicEnabled: true,
                sfxEnabled: true
            };
            updateSettingsUI();
            updateMusicVolume();
            updateSfxVolume();
            playSfx('button_click_sfx');
        }
        
        // ===== GAME LOOP =====
        
        function update(deltaTime) {
            // Update snow
            updateSnow(deltaTime);
            
            if (currentScreen === 'game' && gameActive) {
                
                // Update animation
                if (animatingTile) {
                    animatingTile.progress += deltaTime * 4; // 250ms animation
                    if (animatingTile.progress >= 1) {
                        animatingTile = null;
                        
                        // Check win condition
                        if (isSolved()) {
                            completeLevel();
                        }
                    }
                }
            }
        }
        
        function gameLoop(timestamp) {
            const deltaTime = Math.min((timestamp - lastTime) / 1000, 0.11);
            lastTime = timestamp;
            
            update(deltaTime);
            render();
            
            requestAnimationFrame(gameLoop);
        }
        
        // ===== MAIN RUN FUNCTION =====
        
        async function run(mode) {
            lib.log('run() called. Mode: ' + mode);
            currentMode = mode;
            
            // Setup canvas
            canvas = document.getElementById('gameCanvas');
            ctx = canvas.getContext('2d');
            canvas.width = 720;
            canvas.height = 1280;
            
            // Initialize
            initializeGameConfig();
            await preloadAssets();
            await loadUserProgress();
            initSnow();
            
            // Check for saved game
            if (window.savedGameState && mode === 'play') {
                showResumePrompt();
            }
            
            // Setup game parameters UI
            lib.showGameParameters({
                name: 'Game Settings',
                params: {
                    'Selected Skin': {
                        key: 'gameConfig.selectedSkin',
                        type: 'dropdown',
                        options: Object.entries(SKIN_NAMES).map(([id, name]) => ({
                            label: name,
                            value: id
                        })),
                        onChange: (value) => {
                            window.gameConfig.selectedSkin = value;
                        }
                    },
                    'Music Volume': {
                        key: 'gameConfig.audio.musicVolume',
                        type: 'slider',
                        min: 0,
                        max: 1,
                        step: 0.05,
                        onChange: (value) => {
                            window.gameConfig.audio.musicVolume = value;
                            updateMusicVolume();
                        }
                    },
                    'SFX Volume': {
                        key: 'gameConfig.audio.sfxVolume',
                        type: 'slider',
                        min: 0,
                        max: 1,
                        step: 0.05,
                        onChange: (value) => {
                            window.gameConfig.audio.sfxVolume = value;
                            updateSfxVolume();
                        }
                    }
                }
            });
            
            // Setup input handlers
            canvas.addEventListener('click', (e) => {
                const rect = canvas.getBoundingClientRect();
                const x = (e.clientX - rect.left) * (canvas.width / rect.width);
                const y = (e.clientY - rect.top) * (canvas.height / rect.height);
                handleClick(x, y);
            });
            
            canvas.addEventListener('mousemove', (e) => {
                const rect = canvas.getBoundingClientRect();
                const x = (e.clientX - rect.left) * (canvas.width / rect.width);
                const y = (e.clientY - rect.top) * (canvas.height / rect.height);
                handleMouseMove(x, y);
            });
            
            canvas.addEventListener('touchstart', (e) => {
                e.preventDefault();
                const rect = canvas.getBoundingClientRect();
                const touch = e.touches[0];
                const x = (touch.clientX - rect.left) * (canvas.width / rect.width);
                const y = (touch.clientY - rect.top) * (canvas.height / rect.height);
                handleClick(x, y);
            });
            
            // Touch scroll for level select
            let touchStartY = 0;
            canvas.addEventListener('touchmove', (e) => {
                if (currentScreen !== 'levelSelect') return;
                
                const rect = canvas.getBoundingClientRect();
                const touch = e.touches[0];
                const currentY = (touch.clientY - rect.top) * (canvas.height / rect.height);
                
                if (touchStartY === 0) {
                    touchStartY = currentY;
                } else {
                    const delta = touchStartY - currentY;
                    levelSelectScrollOffset += delta;
                    touchStartY = currentY;
                }
            }, { passive: true });
            
            canvas.addEventListener('touchend', () => {
                touchStartY = 0;
            });
            
            // Mouse wheel scroll for level select
            canvas.addEventListener('wheel', (e) => {
                if (currentScreen !== 'levelSelect') return;
                
                e.preventDefault();
                levelSelectScrollOffset += e.deltaY * 0.5;
            }, { passive: false });
            
            // Keyboard controls
            document.addEventListener('keydown', handleKeyDown);
            
            // Setup settings modal
            document.querySelectorAll('.modal-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.modal-tab').forEach(t => t.classList.remove('active'));
                    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                    
                    tab.classList.add('active');
                    document.getElementById(tab.dataset.tab + 'Tab').classList.add('active');
                    playSfx('button_click_sfx');
                });
            });
            
            document.getElementById('musicVolumeSlider').addEventListener('input', (e) => {
                const value = parseInt(e.target.value) / 100;
                window.gameConfig.audio.musicVolume = value;
                document.getElementById('musicVolumeValue').textContent = Math.round(value * 100);
                updateMusicVolume();
            });
            
            document.getElementById('sfxVolumeSlider').addEventListener('input', (e) => {
                const value = parseInt(e.target.value) / 100;
                window.gameConfig.audio.sfxVolume = value;
                document.getElementById('sfxVolumeValue').textContent = Math.round(value * 100);
                updateSfxVolume();
            });
            
            document.getElementById('musicToggle').addEventListener('change', (e) => {
                window.gameConfig.audio.musicEnabled = e.target.checked;
                if (e.target.checked) {
                    playMusic();
                } else {
                    stopMusic();
                }
            });
            
            document.getElementById('sfxToggle').addEventListener('change', (e) => {
                window.gameConfig.audio.sfxEnabled = e.target.checked;
            });
            
            document.getElementById('gridSizeSelect').addEventListener('change', (e) => {
                window.gameConfig.customGridSize = parseInt(e.target.value);
            });
            
            document.getElementById('shuffleComplexity').addEventListener('change', (e) => {
                window.gameConfig.customShuffleComplexity = e.target.value;
            });
            
            // Start music
            if (window.gameConfig.audio.musicEnabled) {
                playMusic();
            }
            
            // Save game state when leaving
            window.addEventListener('beforeunload', (e) => {
                // Use synchronous save attempt - browsers may not wait for async
                if (currentScreen === 'game' && currentLevel && gameActive) {
                    const gameState = {
                        currentLevel: currentLevel.level,
                        moveCount: moveCount,
                        gridState: grid.map(row => [...row]),
                        emptyPos: { ...emptyPos },
                        timestamp: Date.now()
                    };
                    const fullState = {
                        ...userProgress,
                        currentGameState: gameState
                    };
                    // Fire and forget - browser may or may not wait
                    lib.saveUserGameState(fullState).then(() => {
                        lib.log('Saved on unload');
                    }).catch(err => {
                        lib.log(`Unload save failed: ${err.message}`);
                    });
                }
            });
            
            // Save when page becomes hidden (tab switch, minimize, etc.)
            document.addEventListener('visibilitychange', () => {
                if (document.hidden) {
                    saveGameState().then(() => {
                        lib.log('Saved on visibility change');
                    }).catch(err => {
                        lib.log(`Visibility save failed: ${err.message}`);
                    });
                }
            });
            
            // Also save periodically during gameplay and on level select
            const autoSaveInterval = setInterval(() => {
                if (currentScreen === 'game' && gameActive) {
                    // During active gameplay, save game state
                    saveGameState().then(() => {
                        lib.log('Auto-save completed (gameplay)');
                    }).catch(err => {
                        lib.log(`Auto-save failed: ${err.message}`);
                    });
                } else if (currentScreen === 'levelSelect') {
                    // On level select, save progress (skins, levels, times)
                    saveUserProgress().then(() => {
                        lib.log('Auto-save completed (progress)');
                    }).catch(err => {
                        lib.log(`Auto-save failed: ${err.message}`);
                    });
                }
            }, 3000); // Save every 3 seconds
            
            lib.log('Auto-save timer started (3 second interval)');
            
            // Start game loop
            lastTime = performance.now();
            requestAnimationFrame(gameLoop);
            
            if (mode === 'edit') {
                openSettings();
            }
        }
        
        // Delete saved game function
        async function deleteSavedGame() {
            if (window.confirm('Are you sure you want to delete your saved game? This cannot be undone.')) {
                window.savedGameState = null;
                await saveUserProgress();
                updateSettingsUI();
                playSfx('button_click_sfx');
                lib.log('Saved game deleted');
            }
        }
        
        // Make functions globally accessible for HTML buttons
        window.openSettings = openSettings;
        window.closeSettings = closeSettings;
        window.resetSettings = resetSettings;
        window.deleteSavedGame = deleteSavedGame;
         try {
            // Prefer 'play' mode; if unavailable, fall back to 'auto-start'
            if (typeof run === 'function') run('play');
        } catch (e) {
            console.warn('Auto-run failed',e);
        }

        async function handleBackNavigation() {
            if (currentScreen === 'game') {
                try { await saveGameState(); } catch (err) { lib.log(`Failed to save before menu: ${err.message}`); }
                gameActive = false;
                currentScreen = 'levelSelect';
                try { await saveUserProgress(); } catch (err) { lib.log(`Progress save failed: ${err.message}`); }
                return;
            }
            if (currentScreen === 'levelSelect') {
                try { handleBackButton(); } catch (err) { console.warn('handleBackButton failed', err); }
            }
        }

          function handleBackButton() {
            console.log('🔙 Back button clicked - attempting to notify host app or navigate back');
            try {
                const payload = {
                    type: 'exitGame',
                    level: typeof currentLevel !== 'undefined' ? currentLevel : null,
                    score: typeof playerHighScore !== 'undefined' ? playerHighScore : null,
                    timestamp: Date.now()
                };

                // 1) App-provided JS callback
                if (typeof window.onBackButton === 'function') {
                    try { window.onBackButton(payload); return; } catch (e) { console.warn('onBackButton threw',e); }
                }

                // 2) flutter_inappwebview plugin (callHandler)
                if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
                    try { window.flutter_inappwebview.callHandler('onBack',payload); return; } catch (e) { console.warn('flutter_inappwebview.callHandler failed',e); }
                }

                // 3) common JS channel names exposed by embedding (webview_flutter or custom)
                if (window.FlutterWebViewChannel && typeof window.FlutterWebViewChannel.postMessage === 'function') {
                    try { window.FlutterWebViewChannel.postMessage(JSON.stringify(payload)); return; } catch (e) { console.warn('FlutterWebViewChannel.postMessage failed',e); }
                }

                if (window.JSBridge && typeof window.JSBridge.postMessage === 'function') {
                    try { window.JSBridge.postMessage(JSON.stringify(payload)); return; } catch (e) { console.warn('JSBridge.postMessage failed',e); }
                }

                // 4) generic flutter postMessage (some setups expose `window.flutter.postMessage`)
                if (window.flutter && typeof window.flutter.postMessage === 'function') {
                    try { window.flutter.postMessage(JSON.stringify(payload)); return; } catch (e) { console.warn('window.flutter.postMessage failed',e); }
                }

                // 5) iOS WKWebView message handler (common naming varies)
                if (window.webkit && window.webkit.messageHandlers) {
                    // try a few common handler names
                    const handlers = ['flutter','Flutter','flutter_inappwebview','JSBridge'];
                    for (let h of handlers) {
                        if (window.webkit.messageHandlers[h] && typeof window.webkit.messageHandlers[h].postMessage === 'function') {
                            try { window.webkit.messageHandlers[h].postMessage(payload); return; } catch (e) { /* continue */ }
                        }
                    }
                }

                // 6) postMessage to parent window (if embedded)
                if (window.parent && window.parent !== window && typeof window.parent.postMessage === 'function') {
                    window.parent.postMessage({ type: 'back',payload: payload },'*');
                    return;
                }

                // 7) Fallback to navigation or UI fallback
                if (window.history && history.length > 1) {
                    history.back();
                    return;
                }

                // final fallback: toggle pause so user doesn't get stuck
                togglePause();
            } catch (e) {
                console.warn('backButton click error',e);
            }
        }
    </script>
  ''';
}
