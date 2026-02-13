import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebLiquidSort extends StatefulWidget {
  const WebLiquidSort({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebLiquidSort> createState() => _WebPackPalStubState();
}

class _WebPackPalStubState extends State<WebLiquidSort> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

  late final perferen = Shared.instance.sharedPreferences;

  final _kSavedGameStateKey = 'liquid_sort_saved_game_state';

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
          'assets/liquid_sort/liquid_sort.html',
        );

        final config = await rootBundle.loadString(
          'assets/liquid_sort/config.json',
        );

        html = html.replaceAll('<style id="gameStyle"></style>', style);

        if (config.isNotEmpty) {
          html = html.replaceAll(
            '<script id="gameConfig"></script>',
            '<script id="gameConfig"> window.gameConfig = $config;</script>',
          );
        }

        final assets = await rootBundle.loadString(
          'assets/liquid_sort/assetMap.json',
        );

        if (assets.isNotEmpty) {
          html = html.replaceAll(
            '<script id="assetsMap" type="application/json"></script>',
            '<script id="assetsMap" type="application/json">$assets</script>',
          );
        }

        html = html.replaceAll('<script id="logic"></script>', loadLogicGame);

        html = html.replaceFirst(
          '<script id="startLoadApp"></script>',
          startLoadApp,
        );

        final String? _savedState = perferen.getString(_kSavedGameStateKey);
        if (_savedState != null) {
          // Ensure we inject a valid integer value (fallback to 0)
          final int? _parsed = int.tryParse(_savedState);
          final int _scoreVal = _parsed ?? 0;
          html = html.replaceAll(
            'let playerHighScore = 0;',
            'let playerHighScore = $_scoreVal;',
          );
        }

        // persisted = await _loadPersistedState();
        // if (persisted != null) {
        //   html = html
        //       .replaceAll(
        //         'let currentLevel = 0;',
        //         'let currentLevel = ${persisted!['level'] ?? 0};',
        //       )
        //       .replaceAll(
        //         '"currentLevel": 0',
        //         '"currentLevel": ${persisted!['level'] ?? 0}',
        //       )
        //       .replaceAll(
        //         'startLevel(0)',
        //         'startLevel(${persisted!['level'] ?? 0})',
        //       );
        // }

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
            stateObj['score'] != null ? stateObj['score'].toString() : '',
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

    //linear-gradient(180deg, #87CEEB 0%, #B0E0E6 50%, #E0F6FF 100%)
    return PopScope(
      canPop: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xffB0E0E6).withOpacity(.5),
              const Color(0xffE0F6FF),
            ],
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
                    color: Colors.white,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffE0F6FF),
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

  String get style => '''<style>
        /* CSS Reset & Base */
        * {
            box-sizing: border-box;
            -webkit-tap-highlight-color: transparent;
        }
        
        body, html {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            font-family: var(--font-primary);
            background: var(--gradient-game-bg);
            background-attachment: fixed;
            touch-action: manipulation;
            position: relative;
        }

        /* Candy-themed Background Pattern */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(255,255,255,0.3) 0%, transparent 30%),
                radial-gradient(circle at 80% 70%, rgba(255,255,255,0.2) 0%, transparent 25%),
                radial-gradient(circle at 50% 50%, rgba(255,255,255,0.15) 0%, transparent 40%),
                radial-gradient(circle at 10% 80%, rgba(255,182,193,0.2) 0%, transparent 20%),
                radial-gradient(circle at 90% 20%, rgba(135,206,235,0.2) 0%, transparent 25%);
            background-size: 100% 100%;
            animation: candyFloat 10s ease-in-out infinite;
            pointer-events: none;
            z-index: 0;
        }

        @keyframes candyFloat {
            0%, 100% {
                transform: translateY(0) scale(1);
                opacity: 0.6;
            }
            50% {
                transform: translateY(-20px) scale(1.05);
                opacity: 0.8;
            }
        }
        
        /* CSS Custom Properties - Candy Crush Style */
        :root {
            /* Candy Gradient System */
            --gradient-primary: linear-gradient(135deg, #FF8C00 0%, #FFA500 100%);
            --gradient-secondary: linear-gradient(135deg, #32CD32 0%, #7FFF00 100%);
            --gradient-success: linear-gradient(135deg, #00FF7F 0%, #32CD32 100%);
            --gradient-warning: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
            --gradient-game-bg: linear-gradient(180deg, #87CEEB 0%, #B0E0E6 50%, #E0F6FF 100%);
            --gradient-editor-bg: linear-gradient(180deg, #FFB6C1 0%, #FFA07A 50%, #FFD700 100%);

            /* Candy Solid Colors */
            --color-electric-purple: #9370DB;
            --color-vibrant-pink: #FF69B4;
            --color-cyan-bright: #00BFFF;
            --color-golden-sun: #FFD700;
            --color-mint-fresh: #00FF7F;

            --color-white-pure: #ffffff;
            --color-white-soft: #f8f9ff;
            --color-gray-light: #e2e8f0;
            --color-gray-medium: #94a3b8;
            --color-gray-dark: #475569;
            --color-dark-overlay: rgba(15, 23, 42, 0.6);

            --color-timer-normal: #00FF7F;
            --color-timer-warning: #FFD700;
            --color-timer-critical: #FF4500;

            /* Legacy color mappings for compatibility */
            --color-primary: #667eea;
            --color-primary-hover: #764ba2;
            --color-accent: #f5576c;
            --color-accent-hover: #f093fb;
            --color-warning: #fa709a;
            --color-neutral-50: #f8f9ff;
            --color-neutral-100: #e2e8f0;
            --color-neutral-500: #94a3b8;
            --color-neutral-700: #475569;
            --color-neutral-900: #0f172a;

            /* Spacing Scale (8px base) */
            --space-1: 4px;
            --space-2: 8px;
            --space-3: 12px;
            --space-4: 16px;
            --space-5: 20px;
            --space-6: 24px;
            --space-8: 32px;
            --space-10: 40px;
            --space-12: 48px;
            --space-16: 64px;

            /* Legacy spacing for compatibility */
            --space-xs: 8px;
            --space-sm: 16px;
            --space-md: 24px;
            --space-lg: 32px;
            --space-xl: 48px;

            /* Touch Targets */
            --touch-min: 44px;
            --touch-comfortable: 52px;
            --touch-generous: 60px;

            /* Border Radius */
            --radius-sm: 12px;
            --radius-md: 16px;
            --radius-lg: 24px;
            --radius-xl: 32px;
            --radius-full: 9999px;

            /* Shadows & Elevation */
            --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.08);
            --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.12);
            --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.16);
            --shadow-xl: 0 12px 48px rgba(0, 0, 0, 0.2);

            --glow-primary: 0 0 20px rgba(102, 126, 234, 0.5);
            --glow-success: 0 0 20px rgba(74, 222, 128, 0.5);
            --glow-warning: 0 0 20px rgba(251, 191, 36, 0.5);
            --glow-critical: 0 0 30px rgba(248, 113, 113, 0.7);

            /* Animation Timings */
            --duration-fast: 150ms;
            --duration-normal: 250ms;
            --duration-slow: 400ms;
            --duration-slower: 600ms;

            /* Legacy timings for compatibility */
            --transition-fast: 150ms;
            --transition-normal: 250ms;
            --transition-slow: 400ms;

            /* Easing Functions */
            --ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);
            --ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
            --ease-elastic: cubic-bezier(0.68, -0.6, 0.32, 1.6);
            --ease-out: cubic-bezier(0.0, 0, 0.2, 1);

            /* Typography - Candy Crush Style */
            --font-primary: 'Lato', 'Fredoka', -apple-system, BlinkMacSystemFont, sans-serif;
            --font-display: 'Luckiest Guy', 'Fredoka', sans-serif;

            --text-xs: 12px;
            --text-sm: 14px;
            --text-base: 16px;
            --text-lg: 20px;
            --text-xl: 24px;
            --text-2xl: 32px;
            --text-3xl: 48px;

            --weight-regular: 400;
            --weight-medium: 500;
            --weight-semibold: 600;
            --weight-bold: 700;
            --weight-extrabold: 800;

            /* Glass Morphism (legacy, updated) */
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.3);
            --glass-backdrop: blur(20px);
        }
        
        /* Game Container */
        #gameContainer {
            width: 100%;
            height: 100%;
            position: relative;
            display: flex;
            flex-direction: column;
        }
        
        /* Status Bar - Simple Design */
        #statusBar {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 60px;
            background: rgba(255, 255, 255, 0.95);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            z-index: 100;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        /* Game Status Area */
        #gameStatusArea {
            display: flex;
            align-items: center;
            gap: var(--space-3);
        }

        /* Step Counter - Candy Style */
        #stepCounter {
            background: white;
            border: 4px solid var(--color-electric-purple);
            border-radius: var(--radius-md);
            padding: 10px 20px;
            font-weight: var(--weight-extrabold);
            font-size: 22px;
            color: var(--color-gray-dark);
            min-width: 120px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-2);
            box-shadow: 0 4px 0 rgba(147,112,219,0.4),
                        0 6px 15px rgba(0,0,0,0.2),
                        inset 0 -2px 0 rgba(0,0,0,0.1),
                        inset 0 1px 0 rgba(255,255,255,0.8);
            backdrop-filter: none;
            font-family: var(--font-display);
            text-shadow: 1px 1px 2px rgba(255,255,255,0.8);
        }

        #stepCounter::before {
            content: '👣';
            font-size: 24px;
        }

        /* Level Badge - Glossy Candy Style */
        #levelInfo {
            background: var(--gradient-primary);
            color: var(--color-white-pure);
            border-radius: 24px;
            border: 4px solid white;
            padding: 10px 24px;
            font-weight: 700;
            font-size: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 0 rgba(255,140,0,0.6),
                        0 6px 15px rgba(0,0,0,0.3),
                        inset 0 -2px 0 rgba(0,0,0,0.2),
                        inset 0 2px 0 rgba(255,255,255,0.5);
            font-family: var(--font-display);
            text-shadow: 2px 2px 4px rgba(0,0,0,0.4);
        }

        /* Countdown Timer Component - Candy Style */
        #countdownTimer {
            background: white;
            border: 4px solid var(--color-timer-normal);
            border-radius: var(--radius-md);
            padding: 10px 20px;
            font-weight: var(--weight-extrabold);
            font-size: 22px;
            color: var(--color-timer-normal);
            min-width: 120px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-2);
            transition: all var(--duration-normal) var(--ease-bounce);
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 0 rgba(0,255,127,0.4),
                        0 6px 15px rgba(0,0,0,0.2),
                        inset 0 -2px 0 rgba(0,0,0,0.1),
                        inset 0 1px 0 rgba(255,255,255,0.8);
            font-family: var(--font-display);
            text-shadow: 1px 1px 2px rgba(255,255,255,0.5);
        }

        #countdownTimer .timer-icon {
            font-size: var(--text-xl);
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        #countdownTimer.warning {
            background: #FFFACD;
            border-color: var(--color-timer-warning);
            color: #CC8800;
            animation: pulse 1s infinite;
            box-shadow: 0 4px 0 rgba(255,215,0,0.5),
                        0 6px 15px rgba(255,215,0,0.4),
                        inset 0 -2px 0 rgba(0,0,0,0.1),
                        inset 0 1px 0 rgba(255,255,255,0.8);
        }

        #countdownTimer.critical {
            background: #FFE4E4;
            border-color: var(--color-timer-critical);
            color: #CC0000;
            animation: shake 0.5s infinite, pulseGlow 0.5s infinite;
            box-shadow: 0 4px 0 rgba(255,69,0,0.6),
                        0 6px 20px rgba(255,69,0,0.6),
                        0 0 40px rgba(255,69,0,0.5),
                        inset 0 -2px 0 rgba(0,0,0,0.1),
                        inset 0 1px 0 rgba(255,255,255,0.8);
        }

        /* Menu Button - Simple Right Position */
        #menuButton {
            position: absolute;
            right: 16px;
            width: 40px;
            height: 40px;
            background: var(--gradient-secondary);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 20px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #backButton {
            position: fixed; 
            top: 10px;     
            left: 16px;     
            width: 40px;
            height: 40px;
            background: var(--gradient-secondary);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 20px;
            cursor: pointer;
            display: flex;
            padding-bottom: 10px;
            align-items: center;
            justify-content: center;
            z-index: 300;    /* ensure it sits above most UI layers */
        }

        #menuButton:active {
            opacity: 0.8;
        }

        #backButton:active {
            opacity: 0.8;
        }


        /* Animation for shake */
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-4px); }
            75% { transform: translateX(4px); }
        }
        
        /* Game Canvas */
        #gameCanvas {
            flex: 1;
            background: transparent;
            touch-action: none;
            margin-top: 110px;
            margin-bottom: 140px;
            position: relative;
            z-index: 1;
        }

        /* Bottom Action Bar - Floating Card */
        #actionBar {
            position: fixed;
            bottom: var(--space-4);
            left: var(--space-4);
            right: var(--space-4);
            height: 100px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: var(--radius-xl);
            display: flex;
            align-items: center;
            justify-content: space-around;
            padding: 0 var(--space-6);
            z-index: 100;
            box-shadow: var(--shadow-xl);
        }

        /* Action Buttons - Glossy Candy Style */
        .action-button {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 5px solid white;
            border-radius: var(--radius-md);
            cursor: pointer;
            box-shadow: 0 6px 0 rgba(0,0,0,0.15),
                        0 8px 20px rgba(0,0,0,0.2),
                        inset 0 -4px 0 rgba(0,0,0,0.1),
                        inset 0 2px 0 rgba(255,255,255,0.8);
            transition: all var(--duration-fast) var(--ease-bounce);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }

        /* Glossy shine effect overlay */
        .action-button::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 50%;
            background: linear-gradient(180deg,
                rgba(255,255,255,0.6) 0%,
                rgba(255,255,255,0.2) 50%,
                transparent 100%);
            border-radius: var(--radius-md) var(--radius-md) 50% 50% / var(--radius-md) var(--radius-md) 80% 80%;
            pointer-events: none;
        }

        .action-button:active {
            opacity: 0.8;
        }

        .action-button:disabled {
            opacity: 0.4;
            cursor: not-allowed;
            transform: none !important;
            box-shadow: 0 2px 0 rgba(0,0,0,0.2) !important;
            filter: grayscale(1);
            animation: none !important;
        }

        @keyframes pulseGlow {
            0%, 100% { filter: brightness(1); }
            50% { filter: brightness(1.15); }
        }

        .action-button .button-icon {
            width: 42px;
            height: 42px;
            object-fit: contain;
            pointer-events: none;
            position: relative;
            z-index: 1;
        }

        /* Unified button background - icons provide color */
        #undoBtn,
        #restartBtn,
        #hintBtn {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            position: relative;
        }

        /* Hint countdown display */
        #hintCountdown {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(0, 0, 0, 0.7);
            color: #FFD700;
            font-size: 14px;
            font-weight: bold;
            padding: 2px 6px;
            border-radius: 8px;
            z-index: 10;
            font-family: 'Fredoka', sans-serif;
            min-width: 24px;
            text-align: center;
        }

        
        /* Slide-out Drawer - Premium Design */
        #drawer {
            position: fixed;
            top: 0;
            right: -100%;
            width: 400px;
            max-width: 90vw;
            height: 100%;
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(30px);
            z-index: 200;
            transition: right var(--duration-slow) var(--ease-smooth);
            overflow-y: auto;
            box-shadow: var(--shadow-xl);
        }

        #drawer.open {
            right: 0;
        }

        #drawerBackdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: var(--color-dark-overlay);
            backdrop-filter: blur(4px);
            z-index: 150;
            opacity: 0;
            visibility: hidden;
            transition: all var(--duration-normal) var(--ease-smooth);
        }

        #drawerBackdrop.visible {
            opacity: 1;
            visibility: visible;
        }

        .drawer-header {
            padding: var(--space-6);
            background: var(--gradient-primary);
            color: var(--color-white-pure);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .drawer-title {
            font-size: var(--text-xl);
            font-weight: var(--weight-bold);
            font-family: var(--font-primary);
        }

        #closeDrawer {
            width: var(--touch-min);
            height: var(--touch-min);
            background: rgba(255, 255, 255, 0.2);
            border: none;
            border-radius: var(--radius-md);
            color: var(--color-white-pure);
            font-size: var(--text-xl);
            cursor: pointer;
            transition: all var(--duration-fast) var(--ease-smooth);
        }

        #closeDrawer:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }

        .drawer-section {
            padding: var(--space-6);
            border-bottom: 1px solid var(--color-gray-light);
        }

        .drawer-section:last-child {
            border-bottom: none;
        }

        .section-title {
            font-size: var(--text-lg);
            font-weight: var(--weight-bold);
            color: var(--color-gray-dark);
            margin-bottom: var(--space-4);
            font-family: var(--font-primary);
        }

        .drawer-button {
            width: 100%;
            height: var(--touch-comfortable);
            background: var(--color-white-soft);
            border: 2px solid var(--color-gray-light);
            border-radius: var(--radius-md);
            font-size: var(--text-base);
            font-weight: var(--weight-semibold);
            color: var(--color-gray-dark);
            cursor: pointer;
            margin-bottom: var(--space-3);
            transition: all var(--duration-fast) var(--ease-smooth);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-3);
            font-family: var(--font-primary);
        }

        .drawer-button:hover {
            background: var(--color-white-pure);
            border-color: var(--color-electric-purple);
            transform: translateX(-4px);
            box-shadow: var(--shadow-sm);
        }

        .drawer-button:last-child {
            margin-bottom: 0;
        }

        .drawer-button.primary {
            background: var(--gradient-primary);
            color: var(--color-white-pure);
            border: none;
            box-shadow: var(--shadow-md);
        }

        .drawer-button.primary:hover {
            transform: translateX(-4px) scale(1.02);
            box-shadow: var(--shadow-lg);
        }
        
        /* Edit Mode Specific Styles */
        .edit-mode body {
            background: var(--gradient-editor-bg);
        }

        .edit-mode #levelInfo {
            background: linear-gradient(135deg, #ff9a56 0%, #ff6a88 100%);
        }

        .edit-mode .action-button {
            background: linear-gradient(135deg, #ff9a56 0%, #ff6a88 100%);
        }

        /* Toast Notifications - Premium Design */
        #toastContainer {
            position: fixed;
            top: 100px;
            left: var(--space-4);
            right: var(--space-4);
            z-index: 300;
            pointer-events: none;
        }

        .toast {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: var(--radius-lg);
            padding: var(--space-4) var(--space-5);
            margin-bottom: var(--space-3);
            box-shadow: var(--shadow-lg);
            transform: translateY(-100px);
            opacity: 0;
            transition: all var(--duration-normal) var(--ease-smooth);
            font-weight: var(--weight-semibold);
            color: var(--color-gray-dark);
            display: flex;
            align-items: center;
            gap: var(--space-3);
            font-family: var(--font-primary);
        }

        .toast.show {
            transform: translateY(0);
            opacity: 1;
            animation: bounceIn 0.5s var(--ease-bounce);
        }

        .toast.success {
            border-left: 4px solid var(--color-mint-fresh);
        }

        .toast.success::before {
            content: '✓';
            display: flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            background: var(--gradient-success);
            color: white;
            border-radius: 50%;
            font-weight: var(--weight-bold);
        }

        .toast.warning {
            border-left: 4px solid var(--color-timer-warning);
        }

        .toast.warning::before {
            content: '⚠';
            font-size: var(--text-lg);
            color: var(--color-timer-warning);
        }

        /* Core Animations */
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }

        @keyframes bounceIn {
            0% {
                opacity: 0;
                transform: translateY(-100px) scale(0.8);
            }
            60% {
                opacity: 1;
                transform: translateY(5px) scale(1.02);
            }
            100% {
                transform: translateY(0) scale(1);
            }
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes slideInRight {
            from { transform: translateX(100%); }
            to { transform: translateX(0); }
        }

        @keyframes shimmer {
            0% { background-position: -100% 0; }
            100% { background-position: 200% 0; }
        }
        
        /* Main Menu Screen */
        .main-menu-screen {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: var(--gradient-game-bg);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            overflow: hidden;
        }

        .menu-container {
            text-align: center;
            padding: var(--space-8);
            animation: fadeInScale 0.5s ease-out;
        }

        @keyframes fadeInScale {
            0% {
                opacity: 0;
                transform: scale(0.95);
            }
            100% {
                opacity: 1;
                transform: scale(1);
            }
        }

        /* Game Title Section */
        .game-title-section {
            text-align: center;
            margin-bottom: var(--space-10);
            animation: slideDown 0.6s ease-out;
        }

        @keyframes slideDown {
            0% {
                opacity: 0;
                transform: translateY(-20px);
            }
            100% {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .game-title-logo {
            width: 65%;
            max-width: 480px;
            height: auto;
            margin: 0 auto;
            display: block;
            filter: drop-shadow(3px 3px 8px rgba(0, 0, 0, 0.3));
        }

        .game-title {
            font-size: clamp(48px, 10vw, 72px);
            font-weight: var(--weight-bold);
            color: var(--color-white-pure);
            text-shadow:
                3px 3px 0 rgba(0, 0, 0, 0.2),
                0 0 30px rgba(255, 255, 255, 0.3);
            margin: 0;
            letter-spacing: -2px;
            animation: titlePulse 3s ease-in-out infinite;
        }

        @keyframes titlePulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.02); }
        }

        .game-subtitle {
            font-size: var(--text-xl);
            background: linear-gradient(135deg, #FFD700 0%, #FFA500 50%, #FF69B4 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-top: var(--space-2);
            font-weight: var(--weight-bold);
            text-shadow: none;
        }

        /* Main Menu Buttons - Candy Crush Spectacular Style */
        .main-menu-buttons {
            margin: var(--space-10) 0 var(--space-10);
            perspective: 1000px;
        }

        .menu-main-btn {
            background: linear-gradient(135deg, #32CD32 0%, #7FFF00 50%, #32CD32 100%);
            border: 8px solid white;
            color: var(--color-white-pure);
            padding: 28px 80px;
            font-size: 56px;
            font-weight: var(--weight-bold);
            border-radius: 32px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: var(--space-4);
            box-shadow: 0 10px 0 rgba(50,205,50,0.5),
                        0 15px 40px rgba(0,0,0,0.4),
                        0 0 60px rgba(50,205,50,0.3),
                        inset 0 -6px 0 rgba(0,0,0,0.25),
                        inset 0 4px 0 rgba(255,255,255,0.6);
            transition: all 0.15s cubic-bezier(0.68, -0.6, 0.32, 1.6);
            font-family: var(--font-display);
            text-transform: uppercase;
            letter-spacing: 4px;
            text-shadow: 4px 4px 0 rgba(0,0,0,0.3),
                         6px 6px 20px rgba(0,0,0,0.5);
            position: relative;
            overflow: hidden;
            animation: playButtonBounce 3s ease-in-out infinite,
                       playButtonGlow 2s ease-in-out infinite;
        }

        /* Glossy candy shine overlay */
        .menu-main-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 50%;
            background: linear-gradient(180deg,
                rgba(255,255,255,0.7) 0%,
                rgba(255,255,255,0.3) 50%,
                transparent 100%);
            border-radius: 24px 24px 60% 60% / 24px 24px 50% 50%;
            pointer-events: none;
        }

        @keyframes playButtonBounce {
            0%, 100% {
                transform: translateY(0) scale(1);
            }
            50% {
                transform: translateY(-8px) scale(1.02);
            }
        }

        @keyframes playButtonGlow {
            0%, 100% {
                filter: brightness(1);
            }
            50% {
                filter: brightness(1.15);
            }
        }

        .menu-main-btn:hover {
            transform: translateY(-12px) scale(1.08);
            box-shadow: 0 16px 0 rgba(50,205,50,0.6),
                        0 20px 50px rgba(0,0,0,0.5),
                        0 0 80px rgba(127,255,0,0.6),
                        inset 0 -6px 0 rgba(0,0,0,0.25),
                        inset 0 4px 0 rgba(255,255,255,0.6);
            animation: playButtonBounce 3s ease-in-out infinite,
                       playButtonGlow 0.5s ease-in-out infinite;
        }

        .menu-main-btn:active {
            transform: translateY(4px) scale(0.92, 1.05);
            box-shadow: 0 4px 0 rgba(50,205,50,0.5),
                        0 8px 25px rgba(0,0,0,0.4),
                        0 0 40px rgba(50,205,50,0.2),
                        inset 0 -3px 0 rgba(0,0,0,0.25),
                        inset 0 2px 0 rgba(255,255,255,0.6);
        }

        .btn-text {
            font-size: 56px;
            position: relative;
            z-index: 1;
        }

        .menu-secondary-buttons {
            margin-top: var(--space-8);
            display: flex;
            justify-content: center;
            gap: var(--space-4);
        }

        /* Menu Stats */
        .menu-stats {
            background: rgba(255, 255, 255, 0.98);
            border-radius: var(--radius-xl);
            padding: var(--space-8) var(--space-6);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15),
                        0 0 0 1px rgba(255, 255, 255, 0.8),
                        inset 0 1px 0 rgba(255, 255, 255, 1);
            display: flex;
            flex-wrap: nowrap;
            justify-content: space-around;
            gap: var(--space-4);
            max-width: 600px;
            margin: 0 auto;
            animation: statsGlow 3s ease-in-out infinite;
        }

        @keyframes statsGlow {
            0%, 100% {
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15),
                            0 0 0 1px rgba(255, 255, 255, 0.8),
                            inset 0 1px 0 rgba(255, 255, 255, 1);
            }
            50% {
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15),
                            0 0 0 1px rgba(255, 255, 255, 0.8),
                            0 0 30px rgba(255, 215, 0, 0.3),
                            inset 0 1px 0 rgba(255, 255, 255, 1);
            }
        }

        .stat-item {
            display: flex;
            flex-direction: column;
            gap: var(--space-2);
            flex-shrink: 0;
            min-width: 0;
        }

        .stat-label {
            font-size: 15px;
            color: #64748b;
            font-weight: var(--weight-bold);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .stat-value {
            font-size: 28px;
            font-weight: var(--weight-extrabold);
            white-space: nowrap;
        }

        #menuTotalScore {
            background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: valueShine 2s ease-in-out infinite;
        }

        #menuTotalStars {
            background: linear-gradient(135deg, #9370DB 0%, #FF69B4 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: valueShine 2s ease-in-out infinite 0.3s;
        }

        #menuLevelsCompleted {
            background: linear-gradient(135deg, #32CD32 0%, #00CED1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: valueShine 2s ease-in-out infinite 0.6s;
        }

        @keyframes valueShine {
            0%, 100% {
                filter: brightness(1);
            }
            50% {
                filter: brightness(1.2);
            }
        }

        /* Top 3 Leaderboard Preview */
        .menu-leaderboard-preview {
            background: rgba(255, 255, 255, 0.98);
            border-radius: var(--radius-xl);
            padding: var(--space-6);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15),
                        0 0 0 1px rgba(255, 255, 255, 0.8),
                        inset 0 1px 0 rgba(255, 255, 255, 1);
            max-width: 600px;
            margin: var(--space-6) auto 0;
        }

        .leaderboard-header {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: var(--space-4);
            position: relative;
        }

        .leaderboard-title {
            font-size: 16px;
            font-weight: var(--weight-bold);
            color: #64748b;
            letter-spacing: 1px;
            text-align: center;
        }

        .leaderboard-btn {
            position: absolute;
            right: 0;
            width: 44px;
            height: 44px;
            border-radius: 50%;
            border: 3px solid white;
            background: linear-gradient(180deg, #FFD54F 0%, #FFB300 100%);
            box-shadow: 0 4px 0 #E69500,
                        0 6px 12px rgba(0, 0, 0, 0.15),
                        inset 0 2px 0 rgba(255, 255, 255, 0.4);
            font-size: 20px;
            cursor: pointer;
            transition: all 150ms ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .leaderboard-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 0 #E69500,
                        0 8px 16px rgba(0, 0, 0, 0.2),
                        inset 0 2px 0 rgba(255, 255, 255, 0.4);
        }

        .leaderboard-btn:active {
            transform: translateY(3px) scale(0.98);
            box-shadow: 0 1px 0 #E69500,
                        0 2px 4px rgba(0, 0, 0, 0.1),
                        inset 0 2px 0 rgba(255, 255, 255, 0.4);
        }

        .top3-list {
            display: flex;
            flex-direction: column;
            gap: var(--space-3);
        }

        .loading-text {
            text-align: center;
            color: #94a3b8;
            font-size: 14px;
            padding: var(--space-4);
        }

        .top3-item {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            padding: var(--space-3) var(--space-4);
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border-radius: var(--radius-lg);
            transition: transform 0.2s;
        }

        .top3-item:hover {
            transform: translateX(4px);
        }

        .top3-item.rank-1 {
            background: linear-gradient(135deg, #fff9e6 0%, #ffe6b3 100%);
            box-shadow: 0 4px 15px rgba(255, 215, 0, 0.3);
        }

        .top3-item.rank-2 {
            background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
            box-shadow: 0 4px 15px rgba(192, 192, 192, 0.3);
        }

        .top3-item.rank-3 {
            background: linear-gradient(135deg, #fff5e6 0%, #ffe6cc 100%);
            box-shadow: 0 4px 15px rgba(205, 127, 50, 0.3);
        }

        .rank-badge {
            font-size: 24px;
            min-width: 32px;
            text-align: center;
        }

        .player-info {
            flex: 1;
            display: flex;
            flex-direction: row;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }

        .player-name {
            font-size: 18px;
            font-weight: var(--weight-bold);
            color: #1e293b;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            flex: 1;
            text-align: left;
        }

        .top3-item.rank-1 .player-name {
            color: #d97706;
            font-weight: var(--weight-extrabold);
        }

        .top3-item.rank-2 .player-name {
            color: #64748b;
            font-weight: var(--weight-extrabold);
        }

        .top3-item.rank-3 .player-name {
            color: #c2410c;
            font-weight: var(--weight-extrabold);
        }

        .player-score {
            font-size: 20px;
            font-weight: var(--weight-extrabold);
            background: linear-gradient(135deg, #7c3aed 0%, #ec4899 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            flex-shrink: 0;
            text-align: right;
            padding-right: 8px;
        }

        .empty-leaderboard {
            text-align: center;
            padding: var(--space-6);
            color: #94a3b8;
            font-size: 14px;
        }

        /* Level Selection Modal */
        .modal-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.8);
            backdrop-filter: blur(8px);
            z-index: 2000;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            visibility: hidden;
            transition: all var(--duration-normal) var(--ease-smooth);
        }

        .modal-backdrop.show {
            opacity: 1;
            visibility: visible;
        }

        .level-selection-container {
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            background: rgba(255, 255, 255, 0.98);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-xl);
            overflow: hidden;
            transform: scale(0.9);
            transition: transform var(--duration-normal) var(--ease-bounce);
        }

        .modal-backdrop.show .level-selection-container {
            transform: scale(1);
        }

        .level-header {
            padding: var(--space-6);
            background: var(--gradient-primary);
            color: var(--color-white-pure);
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 2px solid rgba(255, 255, 255, 0.2);
        }

        .level-title {
            font-size: var(--text-2xl);
            font-weight: var(--weight-bold);
            font-family: var(--font-primary);
            margin: 0;
        }

        .close-modal-btn {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: var(--color-white-pure);
            font-size: var(--text-2xl);
            width: 40px;
            height: 40px;
            border-radius: var(--radius-full);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all var(--duration-fast) var(--ease-smooth);
        }

        .close-modal-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
        }


        /* Level Grid - Shared styles for menu */
        .level-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: var(--space-4);
            padding: var(--space-2);
            max-height: 60vh;
            overflow-y: auto;
            overflow-x: hidden;
        }

        @media (min-width: 480px) {
            .level-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            }
        }

        .level-card {
            background: var(--gradient-primary);
            border-radius: var(--radius-lg);
            padding: var(--space-4);
            cursor: pointer;
            position: relative;
            transition: all var(--duration-fast) var(--ease-bounce);
            box-shadow: var(--shadow-md);
            min-height: 150px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: var(--space-2);
        }

        .level-card.locked {
            background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%);
            cursor: not-allowed;
            opacity: 0.7;
        }

        .level-card:not(.locked):hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: var(--shadow-lg), var(--glow-primary);
        }

        .level-card:not(.locked):active {
            transform: translateY(-2px) scale(0.98);
        }

        .level-number {
            font-size: var(--text-3xl);
            font-weight: var(--weight-bold);
            color: var(--color-white-pure);
            font-family: var(--font-display);
        }

        .level-name {
            display: none;
        }

        .level-stars {
            display: flex;
            gap: var(--space-1);
            margin-top: var(--space-2);
        }

        .star {
            font-size: var(--text-lg);
            color: rgba(255, 255, 255, 0.3);
        }

        .star.earned {
            color: var(--color-golden-sun);
            animation: twinkle 1s ease-in-out infinite;
        }

        @keyframes twinkle {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.8; transform: scale(1.1); }
        }

        .level-score {
            background: rgba(0, 0, 0, 0.25);
            backdrop-filter: blur(4px);
            padding: 6px 12px;
            border-radius: 12px;
            margin-top: var(--space-2);
            font-size: 20px;
            font-weight: var(--weight-extrabold);
            color: #ffffff;
            text-shadow: 1px 1px 3px rgba(0,0,0,0.5);
            min-width: 80px;
            text-align: center;
        }

        .level-score.has-score {
            color: #FFD700;
            text-shadow: 1px 1px 3px rgba(0,0,0,0.6),
                         0 0 10px rgba(255,215,0,0.4);
        }

        .level-score.no-score {
            color: rgba(255, 255, 255, 0.6);
            font-weight: var(--weight-semibold);
        }

        .lock-icon {
            position: absolute;
            top: var(--space-3);
            right: var(--space-3);
            font-size: var(--text-xl);
        }

        .level-footer {
            padding: var(--space-4) var(--space-6);
            background: var(--color-white-soft);
            border-top: 1px solid var(--color-gray-light);
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* Victory Dark Overlay (separate element for z-index control) */
        #victoryDarkOverlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.90);
            z-index: 2000;
            opacity: 0;
            visibility: hidden;
            transition: all var(--duration-normal) var(--ease-smooth);
        }

        #victoryDarkOverlay.show {
            opacity: 1;
            visibility: visible;
        }

        /* Victory Modal */
        #victoryModal.modal-backdrop {
            background: transparent;
            backdrop-filter: none;
            z-index: 3000;
        }

        .victory-container {
            width: 90%;
            max-width: 500px;
            background: linear-gradient(135deg, #FFD700 0%, #FFA500 50%, #FF8C00 100%);
            border: 8px solid white;
            border-radius: 32px;
            box-shadow: 0 8px 0 rgba(255,140,0,0.5),
                        0 20px 60px rgba(0, 0, 0, 0.4),
                        0 0 40px rgba(255,215,0,0.3),
                        inset 0 -4px 0 rgba(0,0,0,0.2),
                        inset 0 3px 0 rgba(255,255,255,0.5);
            overflow: visible;
            transform: scale(0.7) rotate(-5deg);
            transition: transform 0.5s cubic-bezier(0.68, -0.6, 0.32, 1.6);
            padding: 0;
            text-align: center;
            position: relative;
            animation: victoryBounce 0.6s ease-out;
        }

        @keyframes victoryBounce {
            0% { transform: scale(0) rotate(-180deg); }
            60% { transform: scale(1.1) rotate(5deg); }
            80% { transform: scale(0.95) rotate(-2deg); }
            100% { transform: scale(1) rotate(0deg); }
        }

        .modal-backdrop.show .victory-container {
            transform: scale(1) rotate(0deg);
        }

        .victory-header {
            padding: var(--space-8) var(--space-6) var(--space-6);
            background: rgba(255, 255, 255, 0.25);
            position: relative;
        }

        .victory-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 50%;
            background: linear-gradient(180deg, rgba(255,255,255,0.4) 0%, transparent 100%);
            border-radius: 24px 24px 0 0;
        }

        .victory-title {
            font-size: 48px;
            font-weight: var(--weight-bold);
            color: #ffffff;
            margin: 0;
            text-shadow: 4px 4px 0 rgba(0,0,0,0.3),
                         6px 6px 20px rgba(0,0,0,0.4);
            font-family: var(--font-display);
            text-transform: uppercase;
            letter-spacing: 2px;
            position: relative;
            z-index: 1;
        }

        /* Stars Display */
        .stars-display {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin: var(--space-6) 0;
            padding: var(--space-4) 0;
        }

        .star-item {
            font-size: 56px;
            opacity: 0.25;
            transform: scale(0.7);
            transition: all 0.3s ease;
            filter: grayscale(100%) brightness(2);
        }

        .star-item.earned {
            opacity: 1;
            transform: scale(1);
            filter: grayscale(0%) brightness(1);
            animation: starPop 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }

        @keyframes starPop {
            0% {
                transform: scale(0) rotate(-180deg);
                opacity: 0;
            }
            50% {
                transform: scale(1.3) rotate(10deg);
            }
            100% {
                transform: scale(1) rotate(0deg);
                opacity: 1;
            }
        }

        /* Score Card */
        .score-card {
            background: #ffffff;
            margin: 0 var(--space-6) var(--space-5);
            padding: var(--space-6);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }

        .score-main {
            margin-bottom: var(--space-4);
        }

        .score-value {
            font-size: 72px;
            font-weight: var(--weight-bold);
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1;
            margin-bottom: var(--space-2);
        }

        .score-label {
            font-size: 14px;
            font-weight: var(--weight-semibold);
            color: #94a3b8;
            letter-spacing: 3px;
            text-transform: uppercase;
        }

        /* Previous Best Score */
        .previous-best {
            text-align: center;
            margin-top: var(--space-3);
            padding: var(--space-2) var(--space-4);
            font-size: 13px;
            color: #64748b;
            background: rgba(148, 163, 184, 0.1);
            border-radius: 12px;
            font-weight: var(--weight-medium);
        }

        .new-record {
            color: #f59e0b;
            font-weight: var(--weight-bold);
            animation: pulse 1.5s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.6; }
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--space-4);
            margin: 0 var(--space-6) var(--space-6);
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            padding: var(--space-5);
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            transition: transform 0.2s ease;
        }

        .stat-card:hover {
            transform: translateY(-2px);
        }

        .stat-icon {
            font-size: 32px;
            margin-bottom: var(--space-2);
        }

        .stat-value {
            font-size: 28px;
            font-weight: var(--weight-bold);
            color: #1e293b;
            margin-bottom: var(--space-1);
            line-height: 1.2;
        }

        .stat-label {
            font-size: 12px;
            color: #64748b;
            font-weight: var(--weight-medium);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* Victory Buttons */
        .victory-buttons {
            display: flex;
            gap: var(--space-3);
            padding: 0 var(--space-6) var(--space-6);
        }

        .victory-btn {
            flex: 1;
            padding: 18px 24px;
            border: 5px solid white;
            border-radius: 16px;
            font-size: 18px;
            font-weight: var(--weight-extrabold);
            cursor: pointer;
            transition: all 0.15s cubic-bezier(0.68, -0.6, 0.32, 1.6);
            min-height: 64px;
            box-shadow: 0 6px 0 rgba(0,0,0,0.2),
                        0 8px 20px rgba(0,0,0,0.3),
                        inset 0 -4px 0 rgba(0,0,0,0.2),
                        inset 0 2px 0 rgba(255,255,255,0.5);
            font-family: var(--font-display);
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            position: relative;
            overflow: hidden;
        }

        .victory-btn::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 50%;
            background: linear-gradient(180deg,
                rgba(255,255,255,0.5) 0%,
                rgba(255,255,255,0.2) 50%,
                transparent 100%);
            border-radius: 11px 11px 50% 50%;
            pointer-events: none;
        }

        .victory-btn:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 10px 0 rgba(0,0,0,0.2),
                        0 12px 30px rgba(0,0,0,0.4),
                        0 0 30px currentColor,
                        inset 0 -4px 0 rgba(0,0,0,0.2),
                        inset 0 2px 0 rgba(255,255,255,0.5);
        }

        .victory-btn:active {
            transform: translateY(2px) scale(0.98);
            box-shadow: 0 2px 0 rgba(0,0,0,0.2),
                        0 4px 15px rgba(0,0,0,0.3),
                        inset 0 -2px 0 rgba(0,0,0,0.2),
                        inset 0 1px 0 rgba(255,255,255,0.5);
        }

        .victory-btn.primary {
            background: linear-gradient(135deg, #32CD32 0%, #228B22 100%);
            color: #ffffff;
        }

        .victory-btn.primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
        }

        .victory-btn.primary:active {
            transform: translateY(0);
        }

        /* Breathing scale animation for Next Level button */
        @keyframes breathingScale {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.08);
            }
        }

        .victory-btn.primary {
            animation: breathingScale 1.5s ease-in-out infinite;
        }

        .victory-btn.primary:hover {
            animation: none;
        }

        .victory-btn.secondary {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
        }

        .victory-btn.secondary:hover {
            background: rgba(255, 255, 255, 1);
            transform: translateY(-2px);
        }

        .victory-btn.secondary:active {
            transform: translateY(0);
        }

        /* Failure Modal - Encouraging Candy Crush Style */
        .failure-container {
            width: 90%;
            max-width: 500px;
            background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 50%, #FFA500 100%);
            border: 8px solid white;
            border-radius: 32px;
            box-shadow: 0 8px 0 rgba(255,107,107,0.5),
                        0 20px 60px rgba(0, 0, 0, 0.4),
                        0 0 40px rgba(255,107,107,0.3),
                        inset 0 -4px 0 rgba(0,0,0,0.2),
                        inset 0 3px 0 rgba(255,255,255,0.5);
            overflow: visible;
            transform: scale(0.7) rotate(-3deg);
            transition: transform 0.5s cubic-bezier(0.68, -0.6, 0.32, 1.6);
            padding: 0;
            text-align: center;
            position: relative;
            animation: failureBounce 0.6s ease-out;
        }

        @keyframes failureBounce {
            0% { transform: scale(0) rotate(-180deg); }
            60% { transform: scale(1.05) rotate(3deg); }
            80% { transform: scale(0.98) rotate(-1deg); }
            100% { transform: scale(1) rotate(0deg); }
        }

        .modal-backdrop.show .failure-container {
            transform: scale(1) rotate(0deg);
        }

        .failure-header {
            padding: var(--space-8) var(--space-6) var(--space-6);
            background: rgba(255, 255, 255, 0.25);
            position: relative;
        }

        .failure-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 50%;
            background: linear-gradient(180deg, rgba(255,255,255,0.4) 0%, transparent 100%);
            border-radius: 24px 24px 0 0;
        }

        .failure-title {
            font-size: 44px;
            font-weight: var(--weight-bold);
            color: #ffffff;
            margin: 0;
            text-shadow: 4px 4px 0 rgba(0,0,0,0.3),
                         6px 6px 20px rgba(0,0,0,0.4);
            font-family: var(--font-display);
            text-transform: uppercase;
            letter-spacing: 2px;
            position: relative;
            z-index: 1;
        }

        .failure-message {
            padding: var(--space-8) var(--space-6);
            background: rgba(255, 255, 255, 0.15);
        }

        .failure-text {
            font-size: 22px;
            font-weight: var(--weight-bold);
            color: #ffffff;
            margin: 0 0 var(--space-3);
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            font-family: var(--font-primary);
        }

        .failure-hint {
            font-size: 16px;
            font-weight: var(--weight-medium);
            color: rgba(255, 255, 255, 0.95);
            margin: 0;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
            font-family: var(--font-primary);
        }

        .failure-buttons {
            display: flex;
            gap: var(--space-3);
            padding: 0 var(--space-6) var(--space-6);
        }

        .failure-btn {
            flex: 1;
            padding: 18px 24px;
            border: 5px solid white;
            border-radius: 16px;
            font-size: 22px;
            font-weight: var(--weight-extrabold);
            cursor: pointer;
            transition: all 0.15s cubic-bezier(0.68, -0.6, 0.32, 1.6);
            min-height: 64px;
            box-shadow: 0 6px 0 rgba(0,0,0,0.2),
                        0 8px 20px rgba(0,0,0,0.3),
                        inset 0 -4px 0 rgba(0,0,0,0.2),
                        inset 0 2px 0 rgba(255,255,255,0.5);
            font-family: var(--font-display);
            position: relative;
            overflow: hidden;
        }

        .failure-btn::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 50%;
            background: linear-gradient(180deg,
                rgba(255,255,255,0.5) 0%,
                rgba(255,255,255,0.2) 50%,
                transparent 100%);
            border-radius: 11px 11px 50% 50%;
            pointer-events: none;
        }

        .failure-btn:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 10px 0 rgba(0,0,0,0.2),
                        0 12px 30px rgba(0,0,0,0.4),
                        0 0 30px currentColor,
                        inset 0 -4px 0 rgba(0,0,0,0.2),
                        inset 0 2px 0 rgba(255,255,255,0.5);
        }

        .failure-btn:active {
            transform: translateY(2px) scale(0.98);
            box-shadow: 0 2px 0 rgba(0,0,0,0.2),
                        0 4px 15px rgba(0,0,0,0.3),
                        inset 0 -2px 0 rgba(0,0,0,0.2),
                        inset 0 1px 0 rgba(255,255,255,0.5);
        }

        .failure-btn.primary {
            background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
            color: #ffffff;
            text-shadow: 3px 3px 0 rgba(0,0,0,0.4),
                         4px 4px 8px rgba(0,0,0,0.5);
        }

        .failure-btn.secondary {
            background: rgba(255, 255, 255, 0.95);
            color: #666666;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.9);
        }

        /* Full Leaderboard Modal - Candy Style */
        .leaderboard-container {
            width: 90%;
            max-width: 500px;
            max-height: 85vh;
            background: linear-gradient(180deg, #E8F5E9 0%, #C8E6C9 100%);
            border: 6px solid white;
            border-radius: 32px;
            box-shadow: 0 8px 0 rgba(76, 175, 80, 0.4),
                        0 12px 40px rgba(0, 0, 0, 0.3),
                        inset 0 2px 0 rgba(255, 255, 255, 0.8);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .leaderboard-modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px;
            background: linear-gradient(180deg, #FFD54F 0%, #FFB300 100%);
            border-bottom: 4px solid white;
            box-shadow: inset 0 -3px 0 rgba(0, 0, 0, 0.1),
                        inset 0 2px 0 rgba(255, 255, 255, 0.5);
        }

        .leaderboard-modal-title {
            font-size: 28px;
            font-weight: var(--weight-extrabold);
            color: white;
            text-shadow: 3px 3px 0 rgba(0, 0, 0, 0.2);
            letter-spacing: 2px;
            font-family: var(--font-display);
        }

        .close-modal-btn {
            width: 44px;
            height: 44px;
            border: 4px solid white;
            border-radius: 50%;
            background: linear-gradient(180deg, #FF6B6B 0%, #EE5A5A 100%);
            color: white;
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.15s;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 0 rgba(200, 50, 50, 0.5),
                        inset 0 2px 0 rgba(255, 255, 255, 0.3);
            text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
        }

        .close-modal-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 0 rgba(200, 50, 50, 0.5),
                        inset 0 2px 0 rgba(255, 255, 255, 0.3);
        }

        .close-modal-btn:active {
            transform: translateY(2px);
            box-shadow: 0 2px 0 rgba(200, 50, 50, 0.5),
                        inset 0 2px 0 rgba(255, 255, 255, 0.3);
        }

        .leaderboard-scroll {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            background: linear-gradient(180deg, rgba(255,255,255,0.5) 0%, rgba(255,255,255,0.3) 100%);
            -webkit-overflow-scrolling: touch;
        }

        .full-leaderboard-list {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .leaderboard-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 12px;
            background: #f8f8f8;
            border-radius: 8px;
        }

        .leaderboard-item.top-1 {
            background: #FFF8E1;
        }

        .leaderboard-item.top-2 {
            background: #F5F5F5;
        }

        .leaderboard-item.top-3 {
            background: #FFF3E0;
        }

        .leaderboard-rank {
            font-family: var(--font-display);
            font-size: 24px;
            font-weight: 700;
            color: #9575CD;
            min-width: 50px;
            text-align: center;
        }

        .leaderboard-name {
            flex: 1;
            font-size: 16px;
            font-weight: 700;
            color: #8B4513;
            text-align: left;
            padding: 0 12px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-family: var(--font-primary);
        }

        .leaderboard-score {
            font-family: var(--font-display);
            font-size: 18px;
            font-weight: 700;
            color: #5a67d8;
            min-width: 50px;
            text-align: right;
            text-shadow: 1px 1px 0 white;
        }

        .my-rank-footer {
            padding: 16px 20px;
            background: linear-gradient(180deg, #7C4DFF 0%, #651FFF 100%);
            border-top: 4px solid white;
            box-shadow: inset 0 3px 0 rgba(255, 255, 255, 0.2);
        }

        .my-rank-content {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-2);
        }

        #myRankText {
            font-size: 18px;
            font-weight: 700;
            color: white;
            text-shadow: 2px 2px 0 rgba(0, 0, 0, 0.2);
            font-family: var(--font-display);
            letter-spacing: 1px;
        }

        .leaderboard-entry {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            padding: var(--space-3) var(--space-4);
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border-radius: var(--radius-lg);
            transition: all 0.2s;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }

        .leaderboard-entry:hover {
            transform: translateX(4px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }

        .leaderboard-entry.rank-1 {
            background: linear-gradient(135deg, #fff9e6 0%, #ffe6b3 100%);
            box-shadow: 0 4px 15px rgba(255, 215, 0, 0.3);
        }

        .leaderboard-entry.rank-2 {
            background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
            box-shadow: 0 4px 15px rgba(192, 192, 192, 0.3);
        }

        .leaderboard-entry.rank-3 {
            background: linear-gradient(135deg, #fff5e6 0%, #ffe6cc 100%);
            box-shadow: 0 4px 15px rgba(205, 127, 50, 0.3);
        }

        .entry-rank {
            min-width: 48px;
            font-size: 18px;
            font-weight: var(--weight-extrabold);
            color: #64748b;
            text-align: center;
        }

        .leaderboard-entry.rank-1 .entry-rank {
            color: #FFD700;
            font-size: 22px;
        }

        .leaderboard-entry.rank-2 .entry-rank {
            color: #C0C0C0;
            font-size: 20px;
        }

        .leaderboard-entry.rank-3 .entry-rank {
            color: #CD7F32;
            font-size: 20px;
        }

        .entry-info {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 2px;
            min-width: 0;
        }

        .entry-name {
            font-size: 16px;
            font-weight: var(--weight-bold);
            color: #1e293b;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .entry-score {
            font-size: 20px;
            font-weight: var(--weight-extrabold);
            background: linear-gradient(135deg, #7c3aed 0%, #ec4899 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .total-stars {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            font-size: var(--text-xl);
            font-weight: var(--weight-bold);
            color: var(--color-gray-dark);
            font-family: var(--font-primary);
        }

        .star-icon {
            font-size: var(--text-2xl);
        }

        /* Menu Control Buttons */
        .menu-control-btn {
            width: 52px;
            height: 52px;
            border: none;
            border-radius: var(--radius-full);
            background: var(--gradient-primary);
            color: var(--color-white-pure);
            font-size: var(--text-xl);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--shadow-md);
            transition: all var(--duration-fast) var(--ease-bounce);
        }

        .menu-control-btn:hover {
            transform: scale(1.1);
            box-shadow: var(--shadow-lg);
        }

        .menu-control-btn:active {
            transform: scale(0.95);
        }

        .menu-control-btn.disabled {
            opacity: 0.5;
            text-decoration: line-through;
        }

        /* Special level styles */
        .level-card.current {
            background: var(--gradient-success);
            animation: glow 2s ease-in-out infinite;
        }

        @keyframes glow {
            0%, 100% { box-shadow: var(--shadow-md); }
            50% { box-shadow: var(--shadow-lg), 0 0 30px rgba(79, 172, 254, 0.5); }
        }

        .level-card.completed {
            background: var(--gradient-secondary);
        }

        /* Scrollbar styling for level grid - Desktop only */
        @media (min-width: 768px) {
            .level-grid::-webkit-scrollbar {
                width: 8px;
            }

            .level-grid::-webkit-scrollbar-track {
                background: var(--color-gray-light);
                border-radius: var(--radius-md);
            }

            .level-grid::-webkit-scrollbar-thumb {
                background: var(--color-electric-purple);
                border-radius: var(--radius-md);
            }

            .level-grid::-webkit-scrollbar-thumb:hover {
                background: var(--color-vibrant-pink);
            }
        }

        /* Hide scrollbar on mobile */
        @media (max-width: 767px) {
            .level-grid::-webkit-scrollbar {
                display: none;
            }

            .level-grid {
                -ms-overflow-style: none;  /* IE and Edge */
                scrollbar-width: none;  /* Firefox */
            }
        }

        /* Responsive adjustments for level modal */
        @media (max-width: 640px) {
            .level-grid {
                grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
                gap: var(--space-3);
                padding: var(--space-4);
            }

            .level-card {
                min-height: 120px;
                padding: var(--space-3);
            }

            .level-number {
                font-size: var(--text-2xl);
            }
        }

        /* Reduced Motion Support */
        @media (prefers-reduced-motion: reduce) {
            * {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
        }
        
        /* Responsive Adjustments */
        @media (max-width: 480px) {
            #statusBar {
                height: 56px;
            }

            #gameStatusArea {
                gap: var(--space-2);
            }

            #countdownTimer,
            #stepCounter {
                font-size: var(--text-base);
                padding: var(--space-2) var(--space-3);
                min-width: 80px;
            }

            #levelInfo {
                font-size: var(--text-base);
                padding: var(--space-2) var(--space-4);
            }

            #levelInfo::before {
                font-size: var(--text-base);
            }

            #menuButton {
                width: 36px;
                height: 36px;
                right: var(--space-2);
                font-size: 18px;
            }

            #actionBar {
                height: 88px;
                padding: 0 var(--space-4);
            }

            .action-button {
                width: var(--touch-comfortable);
                height: var(--touch-comfortable);
            }

            .action-button .button-icon {
                width: 36px;
                height: 36px;
            }

            #drawer {
                width: 100%;
                right: -100%;
            }
        }

        /* Confetti Canvas Styles */
        .confetti-canvas {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            pointer-events: none;
            z-index: 2500;
            display: none;
        }

        .confetti-canvas.active {
            display: block;
        }

        /* Tutorial Styles */
        .tutorial-hint-bubble {
            position: absolute;
            background: linear-gradient(135deg, #FF8C00 0%, #FFA500 100%);
            color: white;
            padding: 14px 24px;
            border-radius: 20px;
            font-size: 16px;
            font-weight: 600;
            white-space: nowrap;
            box-shadow: 0 8px 24px rgba(255, 140, 0, 0.4);
            border: none;
            transform: translateX(-50%);
            animation: tutorialPulse 1.5s ease-in-out infinite;
            letter-spacing: 0.5px;
        }

        .tutorial-arrow {
            position: absolute;
            font-size: 50px;
            color: #FF8C00;
            text-shadow: 0 4px 12px rgba(255, 140, 0, 0.6);
            transform: translateX(-50%);
            animation: tutorialBounce 1.2s ease-in-out infinite;
            filter: drop-shadow(0 2px 8px rgba(255, 165, 0, 0.4));
        }

        @keyframes tutorialBounce {
            0%, 100% {
                transform: translateX(-50%) translateY(0);
            }
            50% {
                transform: translateX(-50%) translateY(-20px);
            }
        }

        @keyframes tutorialPulse {
            0%, 100% {
                transform: translateX(-50%) scale(1);
                opacity: 1;
            }
            50% {
                transform: translateX(-50%) scale(1.05);
                opacity: 0.95;
            }
        }
    </style>''';

  String get startLoadApp => '''
<script>  
        if (!window.lib) {
            window.lib = (function(){
             
                function _getAssetsMap() {
                    try {
                        const el = document.getElementById('assetsMap');
                        if (!el) return {};
                        return JSON.parse(el.textContent || el.innerText || '{}');
                    } catch (e) {
                        return {};
                    }
                }

                return {
                    log: function(){ console.log.apply(console, arguments); },
                    // Persist/load user game state to localStorage
                    getUserGameState: async function(){
                        try {
                            const raw = localStorage.getItem(storageKey);
                            return { state: raw ? JSON.parse(raw) : null };
                        } catch(e){ return { state: null }; }
                    },
                    // saveUserGameState: async function(state){
                    //     try { localStorage.setItem(storageKey, JSON.stringify(state)); return true; } catch(e){ return false; }
                    // },
                    // deleteUserGameState: async function(){
                    //     try { localStorage.removeItem(storageKey); return true; } catch(e){ return false; }
                    // },
                    // Leaderboard fallbacks
                    getTopNEntriesFromLeaderboard: async function(n){ return []; },
                    addPlayerScoreToLeaderboard: async function(score,n){ return true; },
                    // Asset lookup using embedded map (lazy parsed)
                    getAsset: function(id){
                        try {
                            const map = _getAssetsMap();
                            return map && map[id] ? map[id] : null;
                        } catch (e) {
                            return null;
                        }
                    },
                    // No-op showGameParameters used by run() to show debug UI in host
                    showGameParameters: function(opts) { console.log('showGameParameters (stub)', opts); },
                    // Minimal helper to load images (not used by default)
                    getCurrentUser: async function(){ return { id: 'local', name: 'Player' }; }
                };
            }
        )();
        }
    </script>''';

  String get loadLogicGame => r'''
     <script>
        /* ==================================================
         * GAME OVERVIEW: Liquid Sort - A puzzle game where players pour colorful liquids between test tubes
         * to sort each color into separate containers. Features smooth pouring animations, realistic liquid
         * physics, and satisfying visual/audio feedback. Edit mode allows customization of tube contents.
         * 
         * GAME STATE SHAPE: window.gameConfig = {
         *   currentLevel: number,
         *   tubes: Array<Array<string|null>>, // Each tube is array of 4 slots with color strings or null
         *   colors: Array<string>, // Available colors: ['red', 'blue', 'yellow', 'green', 'purple', 'orange']
         *   maxLayers: number, // Maximum layers per tube (4)
         *   moveHistory: Array<{from: number, to: number}> // For undo functionality
         * }
         * ==================================================
         */

        // Game constants
        const COLORS = {
            red: '#FF3366',
            blue: '#00BFFF',
            yellow: '#FFD700',
            green: '#00FF7F',
            purple: '#9370DB',
            orange: '#FF8C00',
            pink: '#FF69B4',
            cyan: '#00FFFF',
            brown: '#8B4513',
            gray: '#808080',
            teal: '#008080',
            coral: '#FF7F50'
        };
        
        // Color manipulation functions for 3D effects
        function lightenColor(color, amount) {
            const hex = color.replace('#', '');
            const r = Math.min(255, parseInt(hex.substr(0, 2), 16) + Math.round(255 * amount));
            const g = Math.min(255, parseInt(hex.substr(2, 2), 16) + Math.round(255 * amount));
            const b = Math.min(255, parseInt(hex.substr(4, 2), 16) + Math.round(255 * amount));
            return '#' + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0');
        }
        
        function darkenColor(color, amount) {
            const hex = color.replace('#', '');
            const r = Math.max(0, parseInt(hex.substr(0, 2), 16) - Math.round(255 * amount));
            const g = Math.max(0, parseInt(hex.substr(2, 2), 16) - Math.round(255 * amount));
            const b = Math.max(0, parseInt(hex.substr(4, 2), 16) - Math.round(255 * amount));
            return '#' + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0');
        }
        
        // Add water surface effects
        function addWaterSurfaceEffects(x, y, width, colorName, isTopSurface = false) {
            if (!isTopSurface) return;
            
            const currentTime = Date.now();
            const baseColor = COLORS[colorName];
            
            // Animated ripples on water surface
            const rippleCount = 3;
            for (let i = 0; i < rippleCount; i++) {
                const ripplePhase = (currentTime * 0.002 + i * Math.PI * 0.7) % (Math.PI * 2);
                const rippleIntensity = Math.sin(ripplePhase) * 0.3 + 0.1;
                const rippleOffset = Math.sin(ripplePhase * 1.5) * 2;
                
                if (rippleIntensity > 0) {
                    ctx.save();
                    ctx.globalAlpha = rippleIntensity;
                    
                    // Create ripple gradient
                    const rippleGradient = ctx.createLinearGradient(x, y, x + width, y);
                    rippleGradient.addColorStop(0, 'rgba(255, 255, 255, 0.0)');
                    rippleGradient.addColorStop(0.3 + i * 0.2, 'rgba(255, 255, 255, 0.6)');
                    rippleGradient.addColorStop(0.7 + i * 0.1, 'rgba(255, 255, 255, 0.0)');
                    
                    ctx.fillStyle = rippleGradient;
                    ctx.fillRect(x + 2, y + rippleOffset, width - 4, 2);
                    
                    ctx.restore();
                }
            }
            
            // Surface tension effect - subtle curved highlight
            ctx.save();
            const tensionGradient = ctx.createRadialGradient(
                x + width / 2, y + 1, 0,
                x + width / 2, y + 1, width / 2
            );
            tensionGradient.addColorStop(0, 'rgba(255, 255, 255, 0.4)');
            tensionGradient.addColorStop(0.6, 'rgba(255, 255, 255, 0.1)');
            tensionGradient.addColorStop(1, 'rgba(255, 255, 255, 0.0)');
            
            ctx.fillStyle = tensionGradient;
            ctx.fillRect(x + 2, y, width - 4, 3);
            ctx.restore();
            
            // Subtle surface reflection animation
            const reflectionPhase = (currentTime * 0.001) % (Math.PI * 2);
            const reflectionIntensity = Math.sin(reflectionPhase) * 0.2 + 0.3;
            
            ctx.save();
            ctx.globalAlpha = reflectionIntensity;
            
            // Moving reflection highlight
            const reflectionPos = (Math.sin(reflectionPhase * 0.7) + 1) * 0.5; // 0 to 1
            const reflectionX = x + reflectionPos * (width - 20) + 10;
            
            const reflectionGradient = ctx.createRadialGradient(
                reflectionX, y + 1, 0,
                reflectionX, y + 1, 8
            );
            reflectionGradient.addColorStop(0, 'rgba(255, 255, 255, 0.8)');
            reflectionGradient.addColorStop(1, 'rgba(255, 255, 255, 0.0)');
            
            ctx.fillStyle = reflectionGradient;
            ctx.beginPath();
            ctx.arc(reflectionX, y + 1, 6, 0, Math.PI * 2);
            ctx.fill();
            
            ctx.restore();
            
            // Micro-bubbles on surface
            if (Math.random() < 0.05) {
                const numMicroBubbles = Math.floor(Math.random() * 3) + 1;
                for (let i = 0; i < numMicroBubbles; i++) {
                    const bubbleX = x + 5 + Math.random() * (width - 10);
                    const bubbleY = y + Math.random() * 2;
                    const bubbleSize = Math.random() * 0.8 + 0.2;
                    
                    ctx.save();
                    ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
                    ctx.shadowColor = 'rgba(255, 255, 255, 0.5)';
                    ctx.shadowBlur = 1;
                    
                    ctx.beginPath();
                    ctx.arc(bubbleX, bubbleY, bubbleSize, 0, Math.PI * 2);
                    ctx.fill();
                    
                    ctx.restore();
                }
            }
        }
        
        const COLOR_NAMES = Object.keys(COLORS);
        const TUBE_WIDTH = 80;
        const TUBE_HEIGHT = 200;
        const LAYER_HEIGHT = 45;
        const MAX_LAYERS = 4;
        const POUR_STREAM_START_OFFSET_X = 100;  // Horizontal offset from bottle center for water stream start
        const POUR_STREAM_START_OFFSET_Y = 2; // Vertical offset from bottle top for water stream start
        
        // Game state
        let canvas, ctx;
        let gameMode = 'play';
        let selectedTube = -1;
        let tubeLiftOffsets = new Map(); // Map<tubeIndex, currentOffset>
        let tubeLiftAnimations = new Map(); // Map<tubeIndex, {targetOffset, startOffset, progress, duration}>
        let hintDestinationTube = -1;
        let pouringTubes = new Set();  // Tracks all tubes currently involved in pours
        let pourAnimations = [];       // Array of concurrent animations

        // Helper functions for parallel pouring
        function isTubeAvailable(tubeIndex) {
            return !pouringTubes.has(tubeIndex);
        }

        function isTubeDestination(tubeIndex) {
            return pourAnimations.some(anim => anim.to === tubeIndex);
        }

        function getAnimationForTube(tubeIndex) {
            return pourAnimations.find(anim => anim.from === tubeIndex || anim.to === tubeIndex);
        }

        let assetCache = {};
        let moveHistory = [];
        let currentLevel = 1;
        let tubes = [];
        let tubePositions = [];
        let lastTime = 0;
        let completedTubes = new Set();
        let sparkleEffects = [];
        let splashEffects = [];
        let liquidWobbleEffects = [];
        let bottleShakeEffects = [];
        let victoryPopupVisible = false;
        let victoryPopupOpacity = 0;
        let gameOverPopupVisible = false;
        let gameOverPopupOpacity = 0;
        let backgroundMusic = null;
        let soundEnabled = true;
        let musicEnabled = true;
        let vibrationEnabled = true;

        // Tutorial system
        let tutorialActive = false;
        let tutorialStep = 0; // 0: select source tube, 1: select destination tube, 2: completed
        let tutorialTargetTube = -1;
        let tutorialCompletedThisSession = false; // Track completion in current session

        // Hint system with countdown
        let hintCooldownTime = 30000; // 30 seconds cooldown
        let hintCooldownRemaining = 0;
        let hintCooldownActive = false;
        
        // Game countdown timer
        let gameTimeLimit = 300000; // 5 minutes in milliseconds
        let gameTimeRemaining = gameTimeLimit;
        let gameTimerActive = false;
        let gameTimerFailed = false;
        let gameTimerPopupVisible = false;
        let gameTimerPopupOpacity = 0;
        
        // Step counter
        let stepCount = 0;
        let levelStartTime = 0;
        let levelCompletionTime = 0;
        
        // Physics engine state
        let physicsEnabled = false;
        
        // Mobile UI state
        let drawerOpen = false;
        let toastQueue = [];
        
        // Input handling
        let touchDevice = false;

        // ===== AUDIO MANAGER =====
        // Comprehensive audio management with Web Audio API, pooling, and iOS support
        class AudioManager {
            constructor() {
                this.context = null;
                this.masterGain = null;
                this.musicGain = null;
                this.sfxGain = null;
                this.pools = {}; // Sound effect pools
                this.music = null; // Background music element
                this.unlocked = false;
                this.soundEnabled = true;
                this.musicEnabled = true;

                // Volume levels (0.0 to 1.0)
                this.MUSIC_VOLUME = 0.6; // 60% as per documentation
                this.SFX_VOLUME = 0.8;   // 80% as per documentation

                // Pool configuration
                this.POOL_SIZE = 4; // 4 instances per sound effect
                this.MAX_CONCURRENT_SOUNDS = 3; // Max 3 concurrent pour sounds

                // Pitch variation range
                this.PITCH_MIN = 0.95;
                this.PITCH_MAX = 1.05;

                // Track active sounds for limiting
                this.activeSounds = new Map();

                this.init();
            }

            init() {
                // Create Web Audio API context (with fallback for older browsers)
                try {
                    const AudioContext = window.AudioContext || window.webkitAudioContext;
                    this.context = new AudioContext();

                    // Create gain nodes for volume control
                    this.masterGain = this.context.createGain();
                    this.masterGain.connect(this.context.destination);

                    this.musicGain = this.context.createGain();
                    this.musicGain.gain.value = this.MUSIC_VOLUME;
                    this.musicGain.connect(this.masterGain);

                    this.sfxGain = this.context.createGain();
                    this.sfxGain.gain.value = this.SFX_VOLUME;
                    this.sfxGain.connect(this.masterGain);

                    console.log('[AudioManager] Web Audio API initialized');
                } catch (e) {
                    console.warn('[AudioManager] Web Audio API not supported, falling back to HTML5 Audio', e);
                    this.context = null;
                }

                // Setup iOS unlock mechanism
                this.setupIOSUnlock();
            }

            setupIOSUnlock() {
                // iOS requires user interaction before audio can play
                const unlockAudio = () => {
                    if (this.unlocked) return;

                    console.log('[AudioManager] Attempting iOS audio unlock...');

                    // Method 1: Resume AudioContext
                    if (this.context && this.context.state === 'suspended') {
                        this.context.resume().then(() => {
                            console.log('[AudioManager] AudioContext resumed');
                        });
                    }

                    // Method 2: Play silent buffer
                    if (this.context) {
                        const buffer = this.context.createBuffer(1, 1, 22050);
                        const source = this.context.createBufferSource();
                        source.buffer = buffer;
                        source.connect(this.context.destination);
                        source.start(0);
                    }

                    // Method 3: Try playing music if available
                    if (this.music) {
                        const playPromise = this.music.play();
                        if (playPromise) {
                            playPromise.then(() => {
                                this.music.pause();
                                this.music.currentTime = 0;
                                console.log('[AudioManager] iOS audio unlocked via music element');
                            }).catch(() => {
                                // Silent fail - will retry on next interaction
                            });
                        }
                    }

                    this.unlocked = true;
                    console.log('[AudioManager] Audio system unlocked');

                    // Remove listeners after first unlock
                    document.removeEventListener('touchstart', unlockAudio);
                    document.removeEventListener('touchend', unlockAudio);
                    document.removeEventListener('click', unlockAudio);
                };

                // Attach to multiple events for maximum compatibility
                document.addEventListener('touchstart', unlockAudio, { once: true });
                document.addEventListener('touchend', unlockAudio, { once: true });
                document.addEventListener('click', unlockAudio, { once: true });
            }

            // Load sound effect with pooling
            loadSoundEffect(id, url) {
                if (!this.pools[id]) {
                    this.pools[id] = [];
                    this.activeSounds.set(id, 0);

                    // Create pool of audio elements
                    for (let i = 0; i < this.POOL_SIZE; i++) {
                        const audio = new Audio(url);
                        audio.preload = 'auto';
                        audio.volume = this.SFX_VOLUME;

                        // Track when sound finishes
                        audio.addEventListener('ended', () => {
                            const count = this.activeSounds.get(id) || 0;
                            this.activeSounds.set(id, Math.max(0, count - 1));
                        });

                        this.pools[id].push({
                            element: audio,
                            inUse: false
                        });
                    }

                    console.log(`[AudioManager] Sound effect pool created: ${id} (${this.POOL_SIZE} instances)`);
                }
            }

            // Load background music
            loadMusic(url) {
                this.music = new Audio(url);
                this.music.preload = 'auto';
                this.music.loop = true;
                this.music.volume = this.MUSIC_VOLUME;

                // Connect to Web Audio API if available
                if (this.context && !this.musicSource) {
                    try {
                        this.musicSource = this.context.createMediaElementSource(this.music);
                        this.musicSource.connect(this.musicGain);
                    } catch (e) {
                        // Element may already be connected
                        console.warn('[AudioManager] Could not connect music to Web Audio API', e);
                    }
                }

                console.log('[AudioManager] Background music loaded');
            }

            // Play sound effect with pooling and pitch variation
            playSound(id, options = {}) {
                if (!this.soundEnabled) return;

                const pool = this.pools[id];
                if (!pool || pool.length === 0) {
                    console.warn(`[AudioManager] Sound effect not loaded: ${id}`);
                    return;
                }

                // Check concurrent sound limit
                const activeCount = this.activeSounds.get(id) || 0;
                if (activeCount >= this.MAX_CONCURRENT_SOUNDS) {
                    console.log(`[AudioManager] Max concurrent sounds reached for ${id}, skipping`);
                    return;
                }

                // Find available audio element in pool
                let audioObj = pool.find(obj => !obj.inUse);

                // If all in use, reuse the first one
                if (!audioObj) {
                    audioObj = pool[0];
                }

                const audio = audioObj.element;

                // Reset and configure
                audio.currentTime = 0;
                audioObj.inUse = true;

                // Apply pitch variation if requested
                if (options.pitchVariation && this.context) {
                    const pitch = this.PITCH_MIN + Math.random() * (this.PITCH_MAX - this.PITCH_MIN);
                    audio.playbackRate = pitch;
                } else {
                    audio.playbackRate = 1.0;
                }

                // Apply custom volume if provided
                if (options.volume !== undefined) {
                    audio.volume = options.volume * this.SFX_VOLUME;
                } else {
                    audio.volume = this.SFX_VOLUME;
                }

                // Update active count
                this.activeSounds.set(id, activeCount + 1);

                // Play sound
                const playPromise = audio.play();
                if (playPromise) {
                    playPromise.then(() => {
                        // Success
                        setTimeout(() => {
                            audioObj.inUse = false;
                        }, 100);
                    }).catch((error) => {
                        console.warn(`[AudioManager] Failed to play sound ${id}:`, error);
                        audioObj.inUse = false;
                        const count = this.activeSounds.get(id) || 0;
                        this.activeSounds.set(id, Math.max(0, count - 1));
                    });
                }
            }

            // Play background music
            playMusic() {
                if (!this.music || !this.musicEnabled) return;

                const playPromise = this.music.play();
                if (playPromise) {
                    playPromise.then(() => {
                        console.log('[AudioManager] Background music started');
                    }).catch((error) => {
                        console.warn('[AudioManager] Failed to play music:', error);
                    });
                }
            }

            // Pause background music
            pauseMusic() {
                if (this.music) {
                    this.music.pause();
                }
            }

            // Stop background music
            stopMusic() {
                if (this.music) {
                    this.music.pause();
                    this.music.currentTime = 0;
                }
            }

            // Toggle sound effects
            toggleSound() {
                this.soundEnabled = !this.soundEnabled;
                console.log(`[AudioManager] Sound effects ${this.soundEnabled ? 'enabled' : 'disabled'}`);
                return this.soundEnabled;
            }

            // Toggle music
            toggleMusic() {
                this.musicEnabled = !this.musicEnabled;

                if (this.musicEnabled) {
                    this.playMusic();
                } else {
                    this.pauseMusic();
                }

                console.log(`[AudioManager] Music ${this.musicEnabled ? 'enabled' : 'disabled'}`);
                return this.musicEnabled;
            }

            // Set music volume
            setMusicVolume(volume) {
                this.MUSIC_VOLUME = Math.max(0, Math.min(1, volume));
                if (this.music) {
                    this.music.volume = this.MUSIC_VOLUME;
                }
                if (this.musicGain) {
                    this.musicGain.gain.value = this.MUSIC_VOLUME;
                }
            }

            // Set SFX volume
            setSFXVolume(volume) {
                this.SFX_VOLUME = Math.max(0, Math.min(1, volume));
                if (this.sfxGain) {
                    this.sfxGain.gain.value = this.SFX_VOLUME;
                }

                // Update all pooled sounds
                Object.values(this.pools).forEach(pool => {
                    pool.forEach(audioObj => {
                        audioObj.element.volume = this.SFX_VOLUME;
                    });
                });
            }

            // Cleanup
            destroy() {
                // Stop all sounds
                Object.values(this.pools).forEach(pool => {
                    pool.forEach(audioObj => {
                        audioObj.element.pause();
                        audioObj.element.src = '';
                    });
                });

                if (this.music) {
                    this.music.pause();
                    this.music.src = '';
                }

                if (this.context) {
                    this.context.close();
                }

                console.log('[AudioManager] Audio system destroyed');
            }
        }

        // Create global audio manager instance
        let audioManager = null;

        // Mobile UI Controller
        const MobileUI = {
            toggleDrawer() {
                drawerOpen = !drawerOpen;
                const drawer = document.getElementById('drawer');
                const backdrop = document.getElementById('drawerBackdrop');
                
                if (drawerOpen) {
                    drawer.classList.add('open');
                    backdrop.classList.add('visible');
                } else {
                    drawer.classList.remove('open');
                    backdrop.classList.remove('visible');
                }
            },
            
            closeDrawer() {
                if (drawerOpen) {
                    this.toggleDrawer();
                }
            },
            
            showToast(message, type = 'info', duration = 3000) {
                const container = document.getElementById('toastContainer');
                const toast = document.createElement('div');
                toast.className = `toast ${type}`;
                toast.textContent = message;
                
                container.appendChild(toast);
                
                // Trigger animation
                setTimeout(() => toast.classList.add('show'), 10);
                
                // Remove after duration
                setTimeout(() => {
                    toast.classList.remove('show');
                    setTimeout(() => container.removeChild(toast), 300);
                }, duration);
            },
            
            updateEditVisibility() {
                const editSection = document.getElementById('editSection');
                editSection.style.display = gameMode === 'edit' ? 'block' : 'none';

                const container = document.getElementById('gameContainer');
                if (gameMode === 'edit') {
                    container.classList.add('edit-mode');
                } else {
                    container.classList.remove('edit-mode');
                }
            },
            
            provideTouchFeedback(element) {
                if (!element) return;

                element.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    element.style.transform = '';
                }, 150);
            }
        };
        
        // Preload assets
        function preloadAssets() {
            // Initialize AudioManager
            audioManager = new AudioManager();

            const assetIds = ['glass_test_tube', 'completion_sparkle', 'pour_sound', 'completion_chime', 'victory_fanfare', 'ambient_music'];

            assetIds.forEach(id => {
                const assetInfo = lib.getAsset(id);
                if (assetInfo) {
                    if (assetInfo.type === 'audio') {
                        // Use AudioManager for audio loading
                        if (assetInfo.loop === 'true') {
                            // Background music
                            audioManager.loadMusic(assetInfo.url);
                            backgroundMusic = audioManager.music; // Keep reference for compatibility
                        } else {
                            // Sound effects - load into pool
                            audioManager.loadSoundEffect(id, assetInfo.url);
                        }
                        // Keep in assetCache for compatibility
                        assetCache[id] = { type: 'audio', id: id };
                    } else {
                        const img = new Image();
                        img.src = assetInfo.url;
                        assetCache[id] = img;
                    }
                }
            });

            // Load button icons
            document.querySelectorAll('img[data-asset]').forEach(img => {
                const assetId = img.getAttribute('data-asset');
                const assetInfo = lib.getAsset(assetId);
                if (assetInfo && assetInfo.type === 'image') {
                    img.src = assetInfo.url;
                }
            });

            console.log('[Game] Assets preloaded with AudioManager');
        }
        
        // Initialize physics engine
        function initializePhysics() {
    // Simplified physics - just enable the flag for now
    // The complex Matter.js integration was causing errors
    physicsEnabled = true;
}
        
        
            // Version constant and output function
            const CURRENT_GAME_VERSION = "20251203153709";
            function outputVersion() {
                const version = CURRENT_GAME_VERSION
                console.log(`Game - Version ${version}`);
                if (typeof lib !== 'undefined' && lib.log) {
                    lib.log(`Game - Version ${version}`);
                }
            }


            // Call with default version
            outputVersion();

// Initialize game display
        function initializeDisplay() {
            canvas = document.getElementById('gameCanvas');
            ctx = canvas.getContext('2d');
            
            // Add roundRect polyfill if not available
            if (!ctx.roundRect) {
                ctx.roundRect = function(x, y, width, height, radius) {
                    this.beginPath();
                    this.moveTo(x + radius, y);
                    this.lineTo(x + width - radius, y);
                    this.quadraticCurveTo(x + width, y, x + width, y + radius);
                    this.lineTo(x + width, y + height - radius);
                    this.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
                    this.lineTo(x + radius, y + height);
                    this.quadraticCurveTo(x, y + height, x, y + height - radius);
                    this.lineTo(x, y + radius);
                    this.quadraticCurveTo(x, y, x + radius, y);
                    this.closePath();
                };
            }
            
            // Set canvas size to match container
            function resizeCanvas() {
                canvas.width = 720;
                canvas.height = 1280 - 200; // Account for UI bars
                canvas.style.width = '100%';
                canvas.style.height = '100%';
            }
            
            resizeCanvas();
            window.addEventListener('resize', resizeCanvas);

            // Detect touch device
            touchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;

            // Initialize WebGL for liquid rendering
            initializeWebGLForLiquid();
        }

        // ====================================================================
        // WebGL Liquid Rendering System
        // ====================================================================

        // WebGL context and shader resources for liquid rendering
        let gl = null;
        let liquidProgram = null;
        let liquidBuffers = null;
        let liquidUniforms = null;
        let webglNeedsClear = true;

        // Convert hex color to RGB array [0-1]
        function hexToRgb(hex) {
            const r = parseInt(hex.slice(1, 3), 16) / 255;
            const g = parseInt(hex.slice(3, 5), 16) / 255;
            const b = parseInt(hex.slice(5, 7), 16) / 255;
            return [r, g, b];
        }

        // Initialize WebGL context and shaders for liquid rendering only
        function initializeWebGLForLiquid() {
            // Create offscreen canvas for WebGL
            const webglCanvas = document.createElement('canvas');
            webglCanvas.width = 720;
            webglCanvas.height = 1280 - 200;

            gl = webglCanvas.getContext('webgl', { alpha: true, premultipliedAlpha: false });

            if (!gl) {
                console.warn('WebGL not supported, falling back to Canvas 2D for liquid');
                return;
            }

            // Enable blending for transparency
            gl.enable(gl.BLEND);
            gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

            // Compile shaders
            const vertexShaderSource = `
                attribute vec4 a_position;
                attribute vec2 a_texCoord;

                uniform mat4 u_worldMatrix;      // Object-to-world transform (with rotation)
                uniform mat4 u_viewProjection;   // World-to-clip transform
                uniform float u_canvasHeight;

                varying vec2 v_texCoord;
                varying float v_worldY;
                varying float v_worldX;
                varying float v_localY;

                void main() {
                    // Transform to world space (with rotation)
                    vec4 worldPos = u_worldMatrix * a_position;

                    // Store world position before projection
                    v_worldY = worldPos.y;
                    v_worldX = worldPos.x;

                    // Transform to clip space
                    gl_Position = u_viewProjection * worldPos;

                    v_texCoord = a_texCoord;
                    v_localY = a_position.y;
                }
            `;

            const fragmentShaderSource = `
                precision mediump float;

                varying vec2 v_texCoord;
                varying float v_worldY;
                varying float v_worldX;
                varying float v_localY;

                uniform float u_liquidLevel;      // World-space Y coordinate of liquid surface (at center)
                uniform vec3 u_liquidColor;
                uniform float u_wobbleStrength;
                uniform float u_time;
                uniform float u_isTopLayer;       // 1.0 if top layer, 0.0 otherwise
                uniform float u_surfaceTilt;      // Tilt slope for liquid surface
                uniform float u_centerX;          // Center X position for tilt calculation
                uniform float u_curveHeight;      // Height of curved bottom (in texture coords, 0-1)

                void main() {
                    // Wobble effect on surface
                    float wobble = sin(v_texCoord.x * 10.0 + u_time * 5.0) * u_wobbleStrength;

                    // Calculate tilted liquid level: y = liquidLevel + (x - centerX) * tiltSlope
                    float tiltOffset = (v_worldX - u_centerX) * u_surfaceTilt;
                    float effectiveLiquidLevel = u_liquidLevel + wobble + tiltOffset;

                    // KEY: Discard pixels above liquid surface (tilted in world space)
                    // In canvas coords: Y increases downward, so discard if Y is less than (above) liquid level
                    if (v_worldY < effectiveLiquidLevel) {
                        discard;
                    }

                    // 3D cylinder gradient (horizontal depth simulation)
                    float centerDist = abs(v_texCoord.x - 0.5) * 2.0;
                    float gradient = 1.0 - centerDist * 0.4;
                    vec3 color = u_liquidColor * gradient;

                    // Discard pixels outside curved bottom (all layers extend to bottle bottom)
                    if (u_curveHeight > 0.0) {
                        // Semi-ellipse curve at bottom
                        // v_texCoord.y = 1 at bottom, 0 at top of liquid quad (canvas Y increases downward)
                        float distFromBottom = 1.0 - v_texCoord.y;  // 0 at bottom, increases upward
                        float nx = (v_texCoord.x - 0.5) * 2.0;  // Normalize x to [-1, 1]
                        // Curve height at this x position (0 at center, max at edges)
                        float curveAtX = u_curveHeight * (1.0 - sqrt(max(0.0, 1.0 - nx * nx)));
                        // Discard pixels outside the curve
                        if (distFromBottom < curveAtX) {
                            discard;
                        }
                    }

                    // Surface effects only for top layer
                    if (u_isTopLayer > 0.5) {
                        // Surface highlight (bright line at top)
                        float distToSurface = v_worldY - effectiveLiquidLevel;
                        if (distToSurface < 10.0) {
                            float highlightStrength = (10.0 - distToSurface) / 10.0;
                            color += vec3(0.3, 0.3, 0.3) * highlightStrength;
                        }

                        // Surface foam (procedural noise)
                        if (distToSurface < 5.0) {
                            float foam = fract(sin(v_texCoord.x * 50.0 + u_time) * 43758.5453);
                            color += vec3(foam * 0.2);
                        }
                    }

                    gl_FragColor = vec4(color, 1.0);
                }
            `;

            // Compile shader helper
            function compileShader(source, type) {
                const shader = gl.createShader(type);
                gl.shaderSource(shader, source);
                gl.compileShader(shader);

                if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
                    console.error('Shader compilation error:', gl.getShaderInfoLog(shader));
                    gl.deleteShader(shader);
                    return null;
                }
                return shader;
            }

            const vertexShader = compileShader(vertexShaderSource, gl.VERTEX_SHADER);
            const fragmentShader = compileShader(fragmentShaderSource, gl.FRAGMENT_SHADER);

            if (!vertexShader || !fragmentShader) {
                console.error('Failed to compile shaders');
                gl = null;
                return;
            }

            liquidProgram = gl.createProgram();
            gl.attachShader(liquidProgram, vertexShader);
            gl.attachShader(liquidProgram, fragmentShader);
            gl.linkProgram(liquidProgram);

            if (!gl.getProgramParameter(liquidProgram, gl.LINK_STATUS)) {
                console.error('Program link error:', gl.getProgramInfoLog(liquidProgram));
                gl = null;
                return;
            }

            // Get attribute and uniform locations
            const attribLocations = {
                position: gl.getAttribLocation(liquidProgram, 'a_position'),
                texCoord: gl.getAttribLocation(liquidProgram, 'a_texCoord')
            };

            liquidUniforms = {
                worldMatrix: gl.getUniformLocation(liquidProgram, 'u_worldMatrix'),
                viewProjection: gl.getUniformLocation(liquidProgram, 'u_viewProjection'),
                canvasHeight: gl.getUniformLocation(liquidProgram, 'u_canvasHeight'),
                liquidLevel: gl.getUniformLocation(liquidProgram, 'u_liquidLevel'),
                liquidColor: gl.getUniformLocation(liquidProgram, 'u_liquidColor'),
                wobbleStrength: gl.getUniformLocation(liquidProgram, 'u_wobbleStrength'),
                time: gl.getUniformLocation(liquidProgram, 'u_time'),
                isTopLayer: gl.getUniformLocation(liquidProgram, 'u_isTopLayer'),
                surfaceTilt: gl.getUniformLocation(liquidProgram, 'u_surfaceTilt'),
                centerX: gl.getUniformLocation(liquidProgram, 'u_centerX'),
                curveHeight: gl.getUniformLocation(liquidProgram, 'u_curveHeight')
            };

            // Create geometry buffers (unit quad)
            const vertices = new Float32Array([
                // Position (x, y)    TexCoord (u, v)
                0.0, 0.0,            0.0, 0.0,  // Bottom-left
                1.0, 0.0,            1.0, 0.0,  // Bottom-right
                1.0, 1.0,            1.0, 1.0,  // Top-right
                0.0, 1.0,            0.0, 1.0   // Top-left
            ]);

            const indices = new Uint16Array([
                0, 1, 2,  // First triangle
                0, 2, 3   // Second triangle
            ]);

            const vertexBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
            gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

            const indexBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
            gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);

            liquidBuffers = {
                vertex: vertexBuffer,
                index: indexBuffer,
                attribLocations: attribLocations
            };

            console.log('WebGL liquid rendering initialized successfully');
        }

        // Matrix creation helper functions (following game_code_webgl.html pattern)
        function createWorldMatrix(x, y, rotation, scaleX, scaleY, pivotX = 0, pivotY = 0) {
            const mat = new Float32Array(16);
            const cos = Math.cos(rotation);
            const sin = Math.sin(rotation);

            // Apply transformations: T(pivot) * R * T(-pivot) * S * T(position)
            // This rotates around the pivot point
            const dx = x - pivotX;
            const dy = y - pivotY;
            const rotatedDx = dx * cos - dy * sin;
            const rotatedDy = dx * sin + dy * cos;
            const finalX = rotatedDx + pivotX;
            const finalY = rotatedDy + pivotY;

            // Column-major matrix format for WebGL
            // Combines rotation and scale
            mat[0] = cos * scaleX;   // X axis, X component
            mat[1] = sin * scaleX;   // X axis, Y component
            mat[2] = 0;
            mat[3] = 0;

            mat[4] = -sin * scaleY;  // Y axis, X component
            mat[5] = cos * scaleY;   // Y axis, Y component
            mat[6] = 0;
            mat[7] = 0;

            mat[8] = 0;              // m13
            mat[9] = 0;              // m23
            mat[10] = 1;             // m33
            mat[11] = 0;             // m43

            mat[12] = finalX;        // m14 (translation X after rotation)
            mat[13] = finalY;        // m24 (translation Y after rotation)
            mat[14] = 0;             // m34
            mat[15] = 1;             // m44

            return mat;
        }

        function createViewProjectionMatrix(canvasWidth, canvasHeight) {
            const mat = new Float32Array(16);

            // Orthographic projection to clip space
            mat[0] = 2.0 / canvasWidth;
            mat[1] = 0;
            mat[2] = 0;
            mat[3] = 0;

            mat[4] = 0;
            mat[5] = -2.0 / canvasHeight; // Negative to flip Y (canvas Y goes down, clip Y goes up)
            mat[6] = 0;
            mat[7] = 0;

            mat[8] = 0;
            mat[9] = 0;
            mat[10] = 1;
            mat[11] = 0;

            mat[12] = -1.0; // Translate to clip space X
            mat[13] = 1.0;  // Translate to clip space Y
            mat[14] = 0;
            mat[15] = 1;

            return mat;
        }

        // Render a single liquid layer using WebGL
        function renderLiquidWithWebGL(liquidX, liquidY, liquidWidth, liquidHeight, colorHex, liquidLevel, wobble, tiltAngle, bottleCenterX, bottleCenterY, isTopLayer = false, surfaceTilt = 0, curveHeight = 0) {
            if (!gl || !liquidProgram) return false;

            // Clear WebGL canvas once per frame
            if (webglNeedsClear) {
                gl.clearColor(0, 0, 0, 0);
                gl.clear(gl.COLOR_BUFFER_BIT);
                webglNeedsClear = false;
            }

            gl.useProgram(liquidProgram);

            const canvasWidth = gl.canvas.width;
            const canvasHeight = gl.canvas.height;

            // Create world matrix (rotation + translation + scale)
            // The matrix will handle the rotation around bottle center
            const worldMatrix = createWorldMatrix(
                liquidX,
                liquidY,
                tiltAngle,  // Use positive angle to match bottle rotation
                liquidWidth,
                liquidHeight,
                bottleCenterX,  // Pivot X
                bottleCenterY   // Pivot Y
            );

            // Create view-projection matrix (converts to clip space)
            const viewProjection = createViewProjectionMatrix(canvasWidth, canvasHeight);

            // Set uniforms
            gl.uniformMatrix4fv(liquidUniforms.worldMatrix, false, worldMatrix);
            gl.uniformMatrix4fv(liquidUniforms.viewProjection, false, viewProjection);
            gl.uniform1f(liquidUniforms.canvasHeight, canvasHeight);
            gl.uniform1f(liquidUniforms.liquidLevel, liquidLevel); // Already in world-space Y
            gl.uniform3fv(liquidUniforms.liquidColor, hexToRgb(colorHex));
            gl.uniform1f(liquidUniforms.wobbleStrength, wobble);
            gl.uniform1f(liquidUniforms.time, Date.now() * 0.001);
            gl.uniform1f(liquidUniforms.isTopLayer, isTopLayer ? 1.0 : 0.0);
            gl.uniform1f(liquidUniforms.surfaceTilt, surfaceTilt);
            gl.uniform1f(liquidUniforms.centerX, bottleCenterX);
            // curveHeight is in texture coordinates (0-1), relative to liquid height
            gl.uniform1f(liquidUniforms.curveHeight, curveHeight / liquidHeight);

            // Bind buffers
            gl.bindBuffer(gl.ARRAY_BUFFER, liquidBuffers.vertex);
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, liquidBuffers.index);

            // Set up vertex attributes
            const stride = 16; // 4 floats * 4 bytes
            gl.enableVertexAttribArray(liquidBuffers.attribLocations.position);
            gl.vertexAttribPointer(liquidBuffers.attribLocations.position, 2, gl.FLOAT, false, stride, 0);

            gl.enableVertexAttribArray(liquidBuffers.attribLocations.texCoord);
            gl.vertexAttribPointer(liquidBuffers.attribLocations.texCoord, 2, gl.FLOAT, false, stride, 8);

            // Draw
            gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_SHORT, 0);

            return true;
        }

        // Flush WebGL canvas to main canvas
        function flushWebGLToCanvas() {
            if (!gl) return;
            ctx.drawImage(gl.canvas, 0, 0);
        }
        
        // Calculate tube positions based on number of tubes
        function calculateTubePositions(numTubes) {
            const positions = [];
            const canvasWidth = 720;
            const canvasHeight = 1280 - 200; // Account for UI bars
            const availableHeight = canvasHeight - 100;
            const startY = 50;
            
            if (numTubes <= 4) {
                // Single row
                const spacing = canvasWidth / (numTubes + 1);
                for (let i = 0; i < numTubes; i++) {
                    positions.push({
                        x: spacing * (i + 1) - TUBE_WIDTH / 2,
                        y: startY + availableHeight / 2 - TUBE_HEIGHT / 2
                    });
                }
            } else if (numTubes <= 6) {
                // Two rows
                const cols = Math.ceil(numTubes / 2);
                const spacing = canvasWidth / (cols + 1);
                const rowSpacing = availableHeight / 3;
                
                for (let i = 0; i < numTubes; i++) {
                    const row = Math.floor(i / cols);
                    const col = i % cols;
                    const rowCols = (row === 1 && numTubes % 2 === 1) ? numTubes - cols : cols;
                    const rowSpacing2 = canvasWidth / (rowCols + 1);
                    
                    positions.push({
                        x: rowSpacing2 * (col + 1) - TUBE_WIDTH / 2,
                        y: startY + rowSpacing * (row + 1) - TUBE_HEIGHT / 2
                    });
                }
            } else {
                // Three rows for 7-8 tubes
                const rows = 3;
                const tubesPerRow = Math.ceil(numTubes / rows);
                const rowSpacing = availableHeight / (rows + 1);
                
                for (let i = 0; i < numTubes; i++) {
                    const row = Math.floor(i / tubesPerRow);
                    const col = i % tubesPerRow;
                    const currentRowTubes = Math.min(tubesPerRow, numTubes - row * tubesPerRow);
                    const spacing = canvasWidth / (currentRowTubes + 1);
                    
                    positions.push({
                        x: spacing * (col + 1) - TUBE_WIDTH / 2,
                        y: startY + rowSpacing * (row + 1) - TUBE_HEIGHT / 2
                    });
                }
            }
            
            return positions;
        }
        
        // Check if a puzzle configuration is solvable
        function isPuzzleSolvable(testTubes) {
            // A puzzle is solvable if:
            // 1. There's at least one empty tube
            // 2. Each color appears exactly MAX_LAYERS times
            // 3. No tube has more than 2 different colors initially (simplified check)
            
            // Count empty tubes
            const emptyCount = testTubes.filter(tube => tube.every(layer => layer === null)).length;
            if (emptyCount === 0) return false;
            
            // Count color occurrences
            const colorCounts = {};
            let totalColors = 0;
            
            for (const tube of testTubes) {
                const uniqueColorsInTube = new Set();
                for (const layer of tube) {
                    if (layer !== null) {
                        colorCounts[layer] = (colorCounts[layer] || 0) + 1;
                        uniqueColorsInTube.add(layer);
                        totalColors++;
                    }
                }
                
                // Avoid tubes with too many mixed colors (makes puzzle very hard)
                if (uniqueColorsInTube.size > 3) return false;
            }
            
            // Check each color appears exactly MAX_LAYERS times
            for (const color in colorCounts) {
                if (colorCounts[color] !== MAX_LAYERS) return false;
            }
            
            return true;
        }
        
        // Generate new level puzzle
        function generateLevelPuzzle(level) {
            const numTubes = Math.min(3 + Math.floor(level / 2), 6); // 3-6 tubes based on level
            const numColors = Math.min(2 + Math.floor(level / 3), 4); // 2-4 colors based on level
            const emptyTubes = Math.max(1, Math.floor(numTubes / 3)); // At least 1 empty tube
            
            const availableColors = COLOR_NAMES.slice(0, numColors);
            
            // Method 1: Create a simple but guaranteed solvable puzzle
            const tubes = [];
            
            // Add empty tubes
            for (let i = 0; i < emptyTubes; i++) {
                tubes.push([null, null, null, null]);
            }
            
            // Create color distribution - each color appears exactly MAX_LAYERS times
            const colorDistribution = [];
            for (let i = 0; i < numColors; i++) {
                for (let j = 0; j < MAX_LAYERS; j++) {
                    colorDistribution.push(availableColors[i]);
                }
            }
            
            // Shuffle the colors
            for (let i = colorDistribution.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [colorDistribution[i], colorDistribution[j]] = [colorDistribution[j], colorDistribution[i]];
            }
            
            // Fill the remaining tubes
            const filledTubes = numTubes - emptyTubes;
            let colorIndex = 0;
            
            for (let i = 0; i < filledTubes; i++) {
                const tube = [];
                for (let j = 0; j < MAX_LAYERS; j++) {
                    if (colorIndex < colorDistribution.length) {
                        tube.push(colorDistribution[colorIndex++]);
                    } else {
                        tube.push(null);
                    }
                }
                tubes.push(tube);
            }
            
            // Make the puzzle more interesting by controlled mixing
            // Higher levels get more mixing
            const mixingIterations = Math.min(level * 3, 20);
            
            for (let iter = 0; iter < mixingIterations; iter++) {
                // Pick two random tubes
                const tube1Index = Math.floor(Math.random() * tubes.length);
                const tube2Index = Math.floor(Math.random() * tubes.length);
                
                if (tube1Index === tube2Index) continue;
                
                const tube1 = tubes[tube1Index];
                const tube2 = tubes[tube2Index];
                
                // Find top liquid in tube1
                let tube1Top = -1;
                for (let i = MAX_LAYERS - 1; i >= 0; i--) {
                    if (tube1[i] !== null) {
                        tube1Top = i;
                        break;
                    }
                }
                
                // Find empty space in tube2
                let tube2Empty = -1;
                for (let i = 0; i < MAX_LAYERS; i++) {
                    if (tube2[i] === null) {
                        tube2Empty = i;
                        break;
                    }
                }
                
                // If we can move, do it
                if (tube1Top !== -1 && tube2Empty !== -1) {
                    // Move just one layer to avoid creating unsolvable puzzles
                    tube2[tube2Empty] = tube1[tube1Top];
                    tube1[tube1Top] = null;
                }
            }
            
            // Final validation - ensure puzzle is not already solved
            let isSolved = true;
            for (const tube of tubes) {
                const nonNullLayers = tube.filter(layer => layer !== null);
                if (nonNullLayers.length > 0 && nonNullLayers.length < MAX_LAYERS) {
                    isSolved = false;
                    break;
                }
                if (nonNullLayers.length === MAX_LAYERS) {
                    const firstColor = nonNullLayers[0];
                    if (!nonNullLayers.every(layer => layer === firstColor)) {
                        isSolved = false;
                        break;
                    }
                }
            }
            
            // If accidentally created a solved puzzle, mix it more
            if (isSolved) {
                return generateLevelPuzzle(level);
            }
            
            return tubes;
        }
        
        // Update step counter display
        function updateStepCounter() {
            const stepCounterElement = document.getElementById('stepCounter');
            if (stepCounterElement) {
                stepCounterElement.textContent = `${stepCount}`;
            }
        }

        // Calculate score and star rating based on performance
        function calculateScore(actualSteps, actualTime, metadata) {
            console.log('=== CALCULATE SCORE START ===');
            console.log('Input:', { actualSteps, actualTime, metadata });

            if (!metadata) {
                console.warn('⚠️ No metadata provided, using defaults');
                return {
                    score: 500,
                    stars: 1,
                    stepScore: 350,
                    timeScore: 150,
                    stepBreakdown: { actual: actualSteps, optimal: 20 },
                    timeBreakdown: { actual: actualTime, target: 120 }
                };
            }

            const optimalSteps = metadata.optimalSteps || 20;
            const targetTime = metadata.targetTime || 120;

            console.log('Thresholds:', { optimalSteps, targetTime });

            // Calculate step score (700 points max)
            // Perfect score if at or below optimal
            // Penalty: -30 points per extra step
            const stepDiff = actualSteps - optimalSteps;
            const stepScore = Math.max(0, Math.min(700, 700 - (stepDiff * 30)));

            console.log('Step calculation:', {
                actualSteps,
                optimalSteps,
                stepDiff,
                rawScore: 700 - (stepDiff * 30),
                finalStepScore: stepScore
            });

            // Calculate time score (300 base + bonus for fast completion)
            // Base: 300 points if within target time
            // Bonus: +1 point per second saved (if faster than target)
            // Penalty: -3 points per second over target
            const timeDiff = actualTime - targetTime;
            let timeScore;

            if (timeDiff <= 0) {
                // Finished faster than target: base 300 + bonus for saved time
                const savedTime = Math.abs(timeDiff);
                timeScore = 300 + savedTime; // +1 point per second saved
            } else {
                // Finished slower than target: penalty
                timeScore = Math.max(0, 300 - (timeDiff * 3)); // -3 points per extra second
            }

            console.log('Time calculation:', {
                actualTime,
                targetTime,
                timeDiff,
                savedTime: timeDiff <= 0 ? Math.abs(timeDiff) : 0,
                bonus: timeDiff <= 0 ? Math.abs(timeDiff) : 0,
                penalty: timeDiff > 0 ? timeDiff * 3 : 0,
                finalTimeScore: timeScore
            });

            // Total score - ensure it's a valid number
            const totalScore = Math.max(0, Math.round(stepScore + timeScore)) || 0;

            // Determine star rating based on step thresholds from config
            const currentLevel = levelManager.levels[levelManager.currentLevelIndex];
            const thresholds = currentLevel?.starThresholds;
            let stars = 0;

            if (thresholds) {
                // Use config thresholds: must be <= threshold to earn stars
                if (actualSteps <= thresholds.threeStar) {
                    stars = 3;
                } else if (actualSteps <= thresholds.twoStar) {
                    stars = 2;
                } else if (actualSteps <= thresholds.oneStar) {
                    stars = 1;
                }
            } else {
                // Fallback to score-based if no thresholds
                if (totalScore >= 850) stars = 3;
                else if (totalScore >= 650) stars = 2;
                else stars = 1;
            }

            console.log('Final result:', {
                totalScore,
                stars,
                actualSteps,
                thresholds: thresholds || 'none',
                breakdown: `${Math.round(stepScore)} (steps) + ${Math.round(timeScore)} (time) = ${totalScore}`
            });
            console.log('=== CALCULATE SCORE END ===');

            return {
                score: totalScore,
                stars: stars,
                stepScore: Math.round(stepScore) || 0,
                timeScore: Math.round(timeScore) || 0,
                stepBreakdown: {
                    actual: actualSteps,
                    optimal: optimalSteps,
                    diff: stepDiff
                },
                timeBreakdown: {
                    actual: actualTime,
                    target: targetTime,
                    diff: timeDiff
                }
            };
        }

        // Initialize game state from config
        function initializeGameState() {
            // Load current level from levelManager
            const currentLevelData = levelManager.levels[levelManager.currentLevelIndex];

            if (currentLevelData && currentLevelData.tubes) {
                // Use preset level tubes
                tubes = JSON.parse(JSON.stringify(currentLevelData.tubes));

                // Set level metadata for scoring
                currentLevelMetadata = {
                    optimalSteps: currentLevelData.optimalSteps || 20,
                    targetTime: currentLevelData.targetTime || 120,
                    difficulty: currentLevelData.difficulty || 'medium',
                    levelId: currentLevelData.id
                };

                console.log('🎮 Initialize Game - Metadata set:', currentLevelMetadata);
            } else {
                // Fallback: try to use config tubes or generate default
                if (typeof window.gameConfig.tubes === 'string') {
                    try {
                        tubes = JSON.parse(window.gameConfig.tubes);
                    } catch (e) {
                        tubes = generateLevelPuzzle(1);
                    }
                } else if (Array.isArray(window.gameConfig.tubes)) {
                    tubes = JSON.parse(JSON.stringify(window.gameConfig.tubes));
                } else {
                    tubes = generateLevelPuzzle(1);
                }

                // Set default metadata
                currentLevelMetadata = {
                    optimalSteps: 20,
                    targetTime: 120,
                    difficulty: 'medium',
                    levelId: 1
                };

                console.log('⚠️ Initialize Game - Default metadata (no level data):', currentLevelMetadata);
            }

            // Ensure tubes is properly formatted
            if (!Array.isArray(tubes) || tubes.length === 0) {
                tubes = generateLevelPuzzle(1);
            }

            moveHistory = [];
            selectedTube = -1;
            hintDestinationTube = -1;
            pouringTubes.clear();
            pourAnimations = [];
            completedTubes.clear();
            sparkleEffects = [];
            splashEffects = [];
            liquidWobbleEffects = [];
            bottleShakeEffects = [];
            victoryPopupVisible = false;
            victoryPopupOpacity = 0;
            gameOverPopupVisible = false;
            gameOverPopupOpacity = 0;
            gameTimerPopupVisible = false;
            gameTimerPopupOpacity = 0;
            gameTimerFailed = false;
            currentLevel = parseInt(window.gameConfig.currentLevel) || 1;

            // Reset step counter and start time
            stepCount = 0;
            levelStartTime = Date.now();
            levelCompletionTime = 0;
            updateStepCounter();

            tubePositions = calculateTubePositions(tubes.length);

            // Update config with proper tubes format
            window.gameConfig.tubes = JSON.parse(JSON.stringify(tubes));

            // Check for initially completed tubes
            checkCompletedTubes();
        }
        
        // Current level metadata for scoring
        let currentLevelMetadata = null;

        // Level Selection System
        const levelManager = {
            levels: [],

            currentLevelIndex: 0,

            init() {
                // Load game title logo
                this.loadTitleLogo();

                // Load levels from game config
                if (window.gameConfig && window.gameConfig.levels) {
                    this.levels = window.gameConfig.levels.map((level, index) => ({
                        id: level.id,
                        name: this.getLevelName(level.id, level.difficulty),
                        difficulty: level.difficulty,
                        tubes: level.tubes,
                        optimalSteps: level.optimalSteps,
                        targetTime: level.targetTime,
                        starThresholds: level.starThresholds, // Include star thresholds
                        colors: level.colors,
                        stars: 0,
                        bestScore: 0,
                        unlocked: index === 0 // First level unlocked by default
                    }));
                }

                // Load saved progress from localStorage or window.lib (async)
                this.loadProgress();

                // Ensure at least first level is unlocked
                if (this.levels.length > 0) {
                    this.levels[0].unlocked = true;
                }

                // Note: updateLevelGrid() is called inside loadProgress() after data loads
                this.bindEvents();
            },

            getLevelName(id, difficulty) {
                const easyNames = ["First Steps", "Easy Start", "Warm Up"];
                const mediumNames = ["Getting Harder", "Challenge", "Tricky"];
                const hardNames = ["Expert", "Master", "Pro"];
                const expertNames = ["Legend", "Impossible", "Ultimate"];

                if (difficulty === "easy") return easyNames[(id - 1) % easyNames.length] || `Level ${id}`;
                if (difficulty === "medium") return mediumNames[(id - 1) % mediumNames.length] || `Level ${id}`;
                if (difficulty === "hard") return hardNames[(id - 1) % hardNames.length] || `Level ${id}`;
                if (difficulty === "expert") return expertNames[(id - 1) % expertNames.length] || `Level ${id}`;
                return `Level ${id}`;
            },

            async loadProgress() {
                // Try to load from window.lib first
                if (window.lib && window.lib.getUserGameState) {
                    try {
                        const result = await window.lib.getUserGameState();
                        if (result.state) {
                            console.log('[Progress] Loaded from window.lib:', result.state);
                            this.applyProgress(result.state);
                        } else {
                            console.log('[Progress] No saved state in window.lib');
                        }
                    } catch (e) {
                        console.error('[Progress] Error loading from window.lib:', e);
                        this.loadProgressFromLocalStorage();
                    }
                } else {
                    console.log('[Progress] window.lib not available, using localStorage');
                    this.loadProgressFromLocalStorage();
                }

                // Always update UI after loading
                this.updateLevelGrid();

                // Auto-start Level 1 if not completed yet (first-time players)
                if (this.levels.length > 0 && this.levels[0].stars === 0 && gameMode === 'play') {
                    console.log('[Progress] Level 1 not completed, auto-starting Level 1');
                    // Small delay to ensure UI is ready
                    setTimeout(() => {
                        this.selectLevel(0);
                    }, 100);
                }
            },

            loadProgressFromLocalStorage() {
                const savedProgress = null; // localStorage disabled, using window.lib only
                if (savedProgress) {
                    try {
                        const progress = JSON.parse(savedProgress);
                        console.log('[Progress] Loaded from localStorage:', progress);
                        this.applyProgress(progress);
                    } catch (e) {
                        console.error('[Progress] Failed to load from localStorage:', e);
                    }
                }
            },

            applyProgress(progress) {
                if (progress.levels) {
                    // Merge saved progress with current levels
                    progress.levels.forEach(savedLevel => {
                        const level = this.levels.find(l => l.id === savedLevel.id);
                        if (level) {
                            level.stars = savedLevel.stars || 0;
                            level.bestScore = savedLevel.bestScore || 0;
                            level.unlocked = savedLevel.unlocked || false;
                        }
                    });
                }
                if (progress.currentLevelIndex !== undefined) {
                    this.currentLevelIndex = progress.currentLevelIndex;
                }

                // Auto-unlock next level if current has stars
                this.levels.forEach((level, index) => {
                    if (level.stars > 0 && index + 1 < this.levels.length) {
                        this.levels[index + 1].unlocked = true;
                    }
                });

                console.log('[Progress] Loaded and applied saved progress:', {
                    totalLevels: this.levels.length,
                    unlockedCount: this.levels.filter(l => l.unlocked).length,
                    totalStars: this.levels.reduce((sum, l) => sum + (l.stars || 0), 0)
                });
            },

            async saveProgress() {
                const progress = {
                    levels: this.levels,
                    currentLevelIndex: this.currentLevelIndex
                };

                console.log('[Progress] Saving progress:', {
                    totalLevels: this.levels.length,
                    unlockedCount: this.levels.filter(l => l.unlocked).length,
                    totalStars: this.levels.reduce((sum, l) => sum + (l.stars || 0), 0),
                    currentLevelIndex: this.currentLevelIndex
                });

                // Save to window.lib if available (API expects object, not string!)
                if (window.lib && window.lib.saveUserGameState) {
                    try {
                        await window.lib.saveUserGameState(progress);
                        console.log('[Progress] Saved to window.lib successfully');
                    } catch (e) {
                        console.error('[Progress] Failed to save to window.lib:', e);
                        // Fallback to localStorage
                        // localStorage disabled - using window.lib only
                        console.log('[Progress] Saved to localStorage as fallback');
                    }
                } else {
                    // localStorage disabled - using window.lib only
                    console.log('[Progress] Saved to localStorage (window.lib not available)');
                }
            },

            updateLevelGrid() {
                // Update level modal grid
                const levelGrid = document.getElementById('levelGrid');
                if (levelGrid) {
                    this.populateLevelGrid(levelGrid);
                }

                // Update main menu stats
                this.updateMenuStats();
            },

            updateMenuStats() {
                let totalStars = 0;
                let levelsCompleted = 0;
                let totalScore = 0;

                this.levels.forEach(level => {
                    totalStars += level.stars;
                    totalScore += level.bestScore || 0;
                    if (level.stars > 0) levelsCompleted++;
                });

                // Update total score
                const menuScoreElement = document.getElementById('menuTotalScore');
                if (menuScoreElement) {
                    menuScoreElement.textContent = `${totalScore.toLocaleString()}`;
                }

                // Update total stars
                const menuStarsElement = document.getElementById('menuTotalStars');
                if (menuStarsElement) {
                    menuStarsElement.textContent = `${totalStars} / ${this.levels.length * 3}`;
                }

                // Update levels completed
                const levelsCompletedElement = document.getElementById('menuLevelsCompleted');
                if (levelsCompletedElement) {
                    levelsCompletedElement.textContent = `${levelsCompleted} / ${this.levels.length}`;
                }

                // Update top 3 leaderboard
                loadTop3Leaderboard();
            },

            populateLevelGrid(levelGrid) {
                if (!levelGrid) return;

                levelGrid.innerHTML = '';
                let totalStars = 0;
                let maxStars = 0;

                this.levels.forEach((level, index) => {
                    const card = document.createElement('div');
                    card.className = 'level-card';
                    card.dataset.levelIndex = index;

                    if (!level.unlocked) {
                        card.classList.add('locked');
                    }
                    if (index === this.currentLevelIndex) {
                        card.classList.add('current');
                    }
                    if (level.stars === 3) {
                        card.classList.add('completed');
                    }

                    // Level number
                    const levelNumber = document.createElement('div');
                    levelNumber.className = 'level-number';
                    levelNumber.textContent = level.id;

                    // Level name
                    const levelName = document.createElement('div');
                    levelName.className = 'level-name';
                    levelName.textContent = level.name;

                    // Stars
                    const starsContainer = document.createElement('div');
                    starsContainer.className = 'level-stars';
                    for (let i = 0; i < 3; i++) {
                        const star = document.createElement('span');
                        star.className = 'star';
                        star.textContent = '⭐';
                        if (i < level.stars) {
                            star.classList.add('earned');
                        }
                        starsContainer.appendChild(star);
                    }

                    // Best score display
                    const scoreContainer = document.createElement('div');
                    scoreContainer.className = 'level-score';
                    if (level.bestScore && level.bestScore > 0) {
                        scoreContainer.classList.add('has-score');
                        scoreContainer.textContent = `Best: ${level.bestScore}`;
                    } else {
                        scoreContainer.classList.add('no-score');
                        scoreContainer.textContent = 'Not played';
                    }

                    // Lock icon
                    if (!level.unlocked) {
                        const lock = document.createElement('span');
                        lock.className = 'lock-icon';
                        lock.textContent = '🔒';
                        card.appendChild(lock);
                    }

                    card.appendChild(levelNumber);
                    card.appendChild(levelName);
                    card.appendChild(starsContainer);
                    card.appendChild(scoreContainer);

                    // Click handler
                    if (level.unlocked) {
                        card.onclick = () => this.selectLevel(index);
                    }

                    levelGrid.appendChild(card);

                    // Count stars
                    totalStars += level.stars;
                    maxStars += 3;
                });

                // Update total stars display in modal
                const totalStarsElement = document.getElementById('totalStarsCount');
                if (totalStarsElement) {
                    totalStarsElement.textContent = `${totalStars} / ${maxStars}`;
                }
            },

            selectLevel(index) {
                const level = this.levels[index];
                if (!level.unlocked) return;

                this.currentLevelIndex = index;
                currentLevel = level.id;
                window.gameConfig.currentLevel = level.id.toString();

                // Update level info display
                const levelInfo = document.getElementById('levelInfo');
                if (levelInfo) {
                    levelInfo.textContent = `Level ${level.id}`;
                }

                // Close modal
                this.closeLevelModal();

                // Transition from menu to game
                this.startGame();

                // Restart the game with new level (will load preset tubes from levelManager)
                restartLevel();
            },

            generateLevelPuzzle(level) {
                // Use preset tubes from level configuration
                if (level.tubes && Array.isArray(level.tubes)) {
                    tubes = JSON.parse(JSON.stringify(level.tubes));
                } else {
                    // Fallback: create empty tubes if config is missing
                    console.warn('Level tubes not found in config, creating empty tubes');
                    tubes = [[null, null, null, null]];
                }

                // Store level metadata for scoring
                currentLevelMetadata = {
                    optimalSteps: level.optimalSteps || 20,
                    targetTime: level.targetTime || 120,
                    difficulty: level.difficulty || 'medium',
                    levelId: level.id
                };

                console.log('🎯 Generate Level Puzzle - Metadata set:', currentLevelMetadata);

                // Update game state
                window.gameConfig.tubes = JSON.parse(JSON.stringify(tubes));
                tubePositions = calculateTubePositions(tubes.length);
            },

            showLevelModal() {
                const modal = document.getElementById('levelSelectionModal');
                if (modal) {
                    modal.classList.add('show');
                    this.updateLevelGrid();

                    // Auto-scroll to last unlocked level
                    setTimeout(() => {
                        const levelGrid = document.getElementById('levelGrid');
                        if (!levelGrid) return;

                        // Find last unlocked level
                        let lastUnlockedIndex = -1;
                        for (let i = this.levels.length - 1; i >= 0; i--) {
                            if (this.levels[i].unlocked) {
                                lastUnlockedIndex = i;
                                break;
                            }
                        }

                        if (lastUnlockedIndex >= 0) {
                            const targetCard = levelGrid.querySelector(`[data-level-index="${lastUnlockedIndex}"]`);
                            if (targetCard) {
                                targetCard.scrollIntoView({
                                    behavior: 'smooth',
                                    block: 'center'
                                });
                            }
                        }
                    }, 100);
                }
            },

            closeLevelModal() {
                const modal = document.getElementById('levelSelectionModal');
                if (modal) {
                    modal.classList.remove('show');
                }
            },

            startGame() {
                // Hide main menu
                const mainMenu = document.getElementById('mainMenuScreen');
                if (mainMenu) {
                    mainMenu.style.display = 'none';
                }

                // Show game container
                const gameContainer = document.getElementById('gameContainer');
                if (gameContainer) {
                    gameContainer.style.display = 'block';
                }

                // Start game timer (it resets automatically)
                startGameTimer();

                // Reset step counter
                stepCount = 0;
                updateStepCounter();
            },

            loadTitleLogo() {
                // Load game title logo from assets
                const logoImg = document.getElementById('gameTitleLogo');
                if (logoImg && window.lib && window.lib.getAsset) {
                    const logoAsset = window.lib.getAsset('liquid_sort_logo');
                    if (logoAsset && logoAsset.url) {
                        logoImg.src = logoAsset.url;
                    }
                }
            },

            backToMenu() {
                // Stop game timer
                stopGameTimer();

                // Show main menu
                const mainMenu = document.getElementById('mainMenuScreen');
                if (mainMenu) {
                    mainMenu.style.display = 'flex';
                }

                // Hide game container
                const gameContainer = document.getElementById('gameContainer');
                if (gameContainer) {
                    gameContainer.style.display = 'none';
                }

                // Update level grid to show latest progress
                this.updateLevelGrid();
            },

            completeLevel(scoreData) {
                const level = this.levels[this.currentLevelIndex];

                console.log('[Progress] Completing level:', {
                    levelId: level.id,
                    currentStars: level.stars,
                    newStars: scoreData.stars,
                    currentBestScore: level.bestScore,
                    newScore: scoreData.score
                });

                // Update stars (keep best)
                const newStars = parseInt(scoreData.stars) || 1;
                const oldStars = parseInt(level.stars) || 0;
                level.stars = Math.max(oldStars, newStars);

                // Update best score (keep highest) - ensure it's a valid number
                const newScore = parseInt(scoreData.score) || 0;
                const oldBestScore = parseInt(level.bestScore) || 0;
                level.bestScore = Math.max(oldBestScore, newScore);

                console.log('[Progress] Updated level data:', {
                    levelId: level.id,
                    stars: level.stars,
                    bestScore: level.bestScore,
                    improved: newStars > oldStars || newScore > oldBestScore
                });

                // Unlock next level
                if (this.currentLevelIndex < this.levels.length - 1) {
                    this.levels[this.currentLevelIndex + 1].unlocked = true;
                    console.log('[Progress] Unlocked next level:', this.levels[this.currentLevelIndex + 1].id);
                }

                this.saveProgress();
                this.updateLevelGrid();
            },

            calculateStars(timeUsed, stepsUsed) {
                // Calculate stars based on level-specific thresholds from config
                const currentLevel = this.levels[this.currentLevelIndex];

                if (!currentLevel || !currentLevel.starThresholds) {
                    // Fallback if no thresholds configured
                    return 1;
                }

                const thresholds = currentLevel.starThresholds;
                const timeLimitMs = currentLevel.targetTime * 1000;

                // Check stars from highest to lowest
                if (timeUsed <= timeLimitMs && stepsUsed <= thresholds.threeStar) {
                    return 3;
                } else if (timeUsed <= timeLimitMs && stepsUsed <= thresholds.twoStar) {
                    return 2;
                } else if (timeUsed <= timeLimitMs && stepsUsed <= thresholds.oneStar) {
                    return 1;
                } else {
                    return 0; // Failed (over time limit or too many steps)
                }
            },

            bindEvents() {
                // Play button - opens level selection modal
                const playBtn = document.getElementById('playButton');
                if (playBtn) {
                    playBtn.onclick = () => {
                        this.showLevelModal();
                    };
                }

                // Open leaderboard modal button
                const openLeaderboardBtn = document.getElementById('openLeaderboardBtn');
                if (openLeaderboardBtn) {
                    openLeaderboardBtn.onclick = () => {
                        openFullLeaderboard();
                    };
                }

                // Close leaderboard modal button
                const closeLeaderboardBtn = document.getElementById('closeLeaderboardBtn');
                if (closeLeaderboardBtn) {
                    closeLeaderboardBtn.onclick = () => {
                        closeFullLeaderboard();
                    };
                }

                // Click outside leaderboard modal to close
                const leaderboardModal = document.getElementById('leaderboardModal');
                if (leaderboardModal) {
                    leaderboardModal.onclick = (e) => {
                        if (e.target === leaderboardModal) {
                            closeFullLeaderboard();
                        }
                    };
                }

                // Close modal button
                const closeBtn = document.getElementById('closeLevelModal');
                if (closeBtn) {
                    closeBtn.onclick = () => {
                        this.closeLevelModal();
                    };
                }

                // Click outside modal to close
                const modal = document.getElementById('levelSelectionModal');
                if (modal) {
                    modal.onclick = (e) => {
                        if (e.target === modal) {
                            this.closeLevelModal();
                        }
                    };
                }
            }
        };

        // Check which tubes are completed (single color)
        function checkCompletedTubes() {
            const newCompleted = new Set();
            
            tubes.forEach((tube, index) => {
                const nonEmptyLayers = tube.filter(layer => layer !== null);
                if (nonEmptyLayers.length > 0) {
                    const firstColor = nonEmptyLayers[0];
                    const isComplete = nonEmptyLayers.every(layer => layer === firstColor) && nonEmptyLayers.length === MAX_LAYERS;
                    
                    if (isComplete) {
                        newCompleted.add(index);
                        
                        // Play completion sound and add effects if newly completed
                        if (!completedTubes.has(index)) {
                            if (audioManager) {
                                audioManager.playSound('completion_chime');
                            }

                            // Vibrate phone for haptic feedback
                            if (vibrationEnabled && navigator.vibrate) {
                                navigator.vibrate(100); // 100ms vibration
                            }

                            // Add shake effect for newly completed bottle
                            addBottleShakeEffect(index);

                            // Add particle effect for newly completed bottle
                            addCompletionParticleEffect(index);
                        }
                    }
                }
            });
            
            completedTubes = newCompleted;
        }

        // Open full leaderboard modal
        function openFullLeaderboard() {
            const modal = document.getElementById('leaderboardModal');
            if (modal) {
                modal.classList.add('show');
                loadFullLeaderboard();
            }
        }

        // Close full leaderboard modal
        function closeFullLeaderboard() {
            const modal = document.getElementById('leaderboardModal');
            if (modal) {
                modal.classList.remove('show');
            }
        }

        // Load full leaderboard data
        async function loadFullLeaderboard() {
            const listContainer = document.getElementById('fullLeaderboardList');
            const myRankText = document.getElementById('myRankText');
            if (!listContainer) return;

            listContainer.innerHTML = '<div class="loading-text">Loading...</div>';
            if (myRankText) myRankText.textContent = 'Loading...';

            try {
                if (window.lib && window.lib.getTopNEntriesFromLeaderboard) {
                    const result = await window.lib.getTopNEntriesFromLeaderboard(100);

                    // Get user's total score
                    const myTotalScore = levelManager.levels.reduce((sum, level) => {
                        return sum + (level.bestScore || 0);
                    }, 0);

                    if (result.entries && result.entries.length > 0) {
                        listContainer.innerHTML = result.entries.map((entry, index) => {
                            const rank = index + 1;
                            const rankDisplay = rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : `#${rank}`;
                            return `
                                <div class="leaderboard-item ${index < 3 ? 'top-' + (index + 1) : ''}">
                                    <div class="leaderboard-rank">${rankDisplay}</div>
                                    <div class="leaderboard-name">${entry.username || entry.playerName || 'Player'}</div>
                                    <div class="leaderboard-score">${entry.score.toLocaleString()}</div>
                                </div>
                            `;
                        }).join('');

                        // Find user's rank or calculate difference
                        if (myRankText) {
                            // Check if user is in the leaderboard
                            const myRankIndex = result.entries.findIndex(e => e.score <= myTotalScore);

                            if (myTotalScore > 0 && myRankIndex !== -1) {
                                // User would be at this rank
                                const myRank = myRankIndex + 1;
                                myRankText.textContent = `Your Rank: #${myRank} (${myTotalScore.toLocaleString()} pts)`;
                            } else if (myTotalScore > 0 && result.entries[result.entries.length - 1].score <= myTotalScore) {
                                // User is above the last entry
                                myRankText.textContent = `Your Score: ${myTotalScore.toLocaleString()} pts`;
                            } else {
                                // User is not on leaderboard
                                const lastScore = result.entries[result.entries.length - 1].score;
                                const diff = lastScore - myTotalScore;
                                if (myTotalScore === 0) {
                                    myRankText.textContent = `Play to earn points!`;
                                } else {
                                    myRankText.textContent = `${diff.toLocaleString()} pts to reach Top 100`;
                                }
                            }
                        }
                    } else {
                        listContainer.innerHTML = '<div class="loading-text">No entries yet</div>';
                        if (myRankText) {
                            myRankText.textContent = myTotalScore > 0
                                ? `Your Score: ${myTotalScore.toLocaleString()} pts`
                                : 'Play to earn points!';
                        }
                    }
                }
            } catch (error) {
                console.error('[Leaderboard] Error loading:', error);
                listContainer.innerHTML = '<div class="loading-text">Failed to load</div>';
                if (myRankText) myRankText.textContent = 'Unable to load rank';
            }
        }

        // Check victory condition
        function checkVictory() {
            const nonEmptyTubes = tubes.filter(tube => tube.some(layer => layer !== null));
            const completedCount = Array.from(completedTubes).length;

            if (completedCount === nonEmptyTubes.length && nonEmptyTubes.length > 0) {
                // Victory!
                levelCompletionTime = Date.now();
                stopGameTimer();

                // Calculate score and stars
                const timeUsedMs = levelCompletionTime - levelStartTime;
                const timeUsedSeconds = Math.round(timeUsedMs / 1000);
                const scoreData = calculateScore(stepCount, timeUsedSeconds, currentLevelMetadata);

                // Save level progress
                levelManager.completeLevel(scoreData);

                // Add victory sparkles
                tubePositions.forEach((pos, index) => {
                    if (completedTubes.has(index)) {
                        addSparkleEffect(pos.x + TUBE_WIDTH / 2, pos.y + TUBE_HEIGHT / 2);
                    }
                });

                // Wait 2 seconds before showing victory popup
                setTimeout(() => {
                if (audioManager) {
                    audioManager.playSound('victory_fanfare');
                }
                    showVictoryPopup(scoreData, timeUsedMs, stepCount);
                }, 800);
            }
        }
        
        // Add sparkle effect
        function addSparkleEffect(x, y) {
            sparkleEffects.push({
                x: x,
                y: y,
                scale: 0,
                opacity: 1,
                rotation: 0,
                life: 0
            });
        }
        
        // Show victory popup with HTML modal
        function showVictoryPopup(scoreData, timeUsed, stepCount) {
            const modal = document.getElementById('victoryModal');
            const darkOverlay = document.getElementById('victoryDarkOverlay');
            if (!modal) return;

            const stars = scoreData.stars || 1;

            // Format time
            const minutes = Math.floor(timeUsed / 60000);
            const seconds = Math.floor((timeUsed % 60000) / 1000);
            const timeString = minutes > 0 ? `${minutes}:${seconds.toString().padStart(2, '0')}` : `0:${seconds.toString().padStart(2, '0')}`;

            // Update score display
            const scoreElement = document.getElementById('victoryScore');
            if (scoreElement) {
                // Animate score counter
                animateScoreCounter(scoreElement, 0, scoreData.score, 1500);
            }

            // Update performance breakdown - simplified to show only actual values
            const stepsBreakdown = document.getElementById('victoryStepsBreakdown');
            if (stepsBreakdown) {
                stepsBreakdown.textContent = stepCount;
            }

            const timeBreakdown = document.getElementById('victoryTimeBreakdown');
            if (timeBreakdown) {
                timeBreakdown.textContent = timeString;
            }

            // Show previous best score if exists
            const previousBestElement = document.getElementById('victoryPreviousBest');
            const level = levelManager.levels[levelManager.currentLevelIndex];
            if (previousBestElement && level) {
                if (level.bestScore && level.bestScore > 0) {
                    const isNewRecord = scoreData.score > level.bestScore;
                    previousBestElement.innerHTML = isNewRecord
                        ? `<span class="new-record">🎉 NEW RECORD! (Previous: ${level.bestScore})</span>`
                        : `Previous Best: ${level.bestScore}`;
                    previousBestElement.style.display = 'block';
                } else {
                    previousBestElement.style.display = 'none';
                }
            }

            // Reset all stars
            const starItems = modal.querySelectorAll('.star-item');
            starItems.forEach(item => item.classList.remove('earned'));

            // Show dark overlay and modal
            if (darkOverlay) darkOverlay.classList.add('show');
            modal.classList.add('show');

            // Animate stars one by one
            for (let i = 0; i < stars; i++) {
                setTimeout(() => {
                    starItems[i].classList.add('earned');
                }, (i + 1) * 400);
            }

            // Upload to leaderboard if total score improved
            uploadToLeaderboardIfImproved();

            // Create confetti celebration
            startConfetti();
        }

        // Upload score to leaderboard if improved
        async function uploadToLeaderboardIfImproved() {
            try {
                // Calculate current total score - ensure all scores are valid numbers
                let currentTotalScore = 0;
                levelManager.levels.forEach(level => {
                    const levelScore = parseInt(level.bestScore) || 0;
                    currentTotalScore += levelScore;
                });

                // Ensure total score is a valid number
                currentTotalScore = Math.max(0, currentTotalScore) || 0;

                // Get previous best from localStorage
                const previousBestKey = 'liquidSort_bestTotalScore';
                const previousBest = parseInt(window.gameConfig[previousBestKey]) || 0;

                console.log('[Leaderboard] Current total:', currentTotalScore, 'Previous best:', previousBest);

                // Only upload if score improved
                if (currentTotalScore > previousBest) {
                    // Upload to leaderboard - API will handle player identification
                    if (window.lib && window.lib.addPlayerScoreToLeaderboard) {
                        const scoreToUpload = parseInt(currentTotalScore) || 0;
                        await window.lib.addPlayerScoreToLeaderboard(scoreToUpload, 100);
                        console.log('[Leaderboard] Score uploaded:', scoreToUpload);

                        // Save new best score
                        window.gameConfig[previousBestKey] = currentTotalScore;
                    }
                } else {
                    console.log('[Leaderboard] Score not improved, skipping upload');
                }
            } catch (error) {
                console.error('[Leaderboard] Error uploading score:', error);
            }
        }

        // Load top 3 leaderboard entries
        async function loadTop3Leaderboard() {
            const top3List = document.getElementById('top3List');
            if (!top3List) return;

            try {
                // Show loading state
                top3List.innerHTML = '<div class="loading-text">Loading...</div>';

                // Get top 3 from API
                if (window.lib && window.lib.getTopNEntriesFromLeaderboard) {
                    const leaderboardData = await window.lib.getTopNEntriesFromLeaderboard(3);

                    if (leaderboardData && leaderboardData.entries && leaderboardData.entries.length > 0) {
                        // Render top 3 entries
                        top3List.innerHTML = leaderboardData.entries.map((entry, index) => {
                            const rank = entry.rank || (index + 1);
                            const medals = ['🥇', '🥈', '🥉'];
                            const rankClass = `rank-${rank}`;
                            return `
                                <div class="top3-item ${rankClass}">
                                    <div class="rank-badge">${medals[index]}</div>
                                    <div class="player-info">
                                        <div class="player-name">${entry.username || 'Anonymous'}</div>
                                        <div class="player-score">${parseInt(entry.score).toLocaleString()}</div>
                                    </div>
                                </div>
                            `;
                        }).join('');
                    } else {
                        // Show empty state
                        top3List.innerHTML = '<div class="empty-leaderboard">No scores yet - be the first!</div>';
                    }
                } else {
                    top3List.innerHTML = '<div class="empty-leaderboard">Leaderboard unavailable</div>';
                }
            } catch (error) {
                console.error('[Leaderboard] Error loading top 3:', error);
                top3List.innerHTML = '<div class="empty-leaderboard">Failed to load leaderboard</div>';
            }
        }

        function animateScoreCounter(element, start, end, duration) {
            const startTime = Date.now();
            const range = end - start;

            function update() {
                const now = Date.now();
                const elapsed = now - startTime;
                const progress = Math.min(elapsed / duration, 1);

                // Easing function (ease-out)
                const eased = 1 - Math.pow(1 - progress, 3);
                const current = Math.round(start + range * eased);

                element.textContent = current;

                if (progress < 1) {
                    requestAnimationFrame(update);
                } else {
                    element.textContent = end;
                }
            }

            update();
        }

        // Confetti particle system with object pool
        let confettiParticles = [];
        let confettiParticlePool = [];
        let confettiAnimationId = null;
        let confettiRunning = false;
        let confettiFrameCount = 0;

        class ConfettiParticle {
            constructor(canvas) {
                this.canvas = canvas;
                this.reset(canvas);
            }

            reset(canvas) {
                this.canvas = canvas;

                // Random size for streamers - thin and long like ribbons
                this.width = Math.random() * 6 + 8;  // 8-14px wide
                this.height = Math.random() * 40 + 30;  // 30-70px tall (long)

                // Start from top of screen at random x position
                this.x = Math.random() * canvas.width;
                this.y = -50 - Math.random() * 50; // Start slightly above screen

                // Falling velocities - very slow like floating leaves
                this.vx = (Math.random() - 0.5) * 1; // -0.5 to 0.5 pixels horizontal drift
                this.vy = Math.random() * 0.5 + 0.2; // 0.2-0.7 pixels downward

                // Physics - floating effect
                this.gravity = 0.05;  // Very gentle gravity
                this.rotation = Math.random() * Math.PI * 2;
                this.rotationSpeed = (Math.random() - 0.5) * 0.08;

                // Add swaying motion like leaves
                this.swayAmplitude = Math.random() * 0.5 + 0.3; // 0.3-0.8
                this.swaySpeed = Math.random() * 0.02 + 0.01; // 0.01-0.03
                this.swayOffset = Math.random() * Math.PI * 2;

                // Random bright colors
                const colors = [
                    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96E6B3',
                    '#FDCB6E', '#6C5CE7', '#A8E6CF', '#FFD93D',
                    '#FF9FF3', '#54A0FF', '#48DBFB', '#00D2D3'
                ];
                this.color = colors[Math.floor(Math.random() * colors.length)];
            }

            update() {
                // Apply swaying motion (like leaves)
                this.swayOffset += this.swaySpeed;
                const sway = Math.sin(this.swayOffset) * this.swayAmplitude;

                // Update position with sway
                this.x += this.vx + sway;
                this.y += this.vy;

                // Apply very gentle gravity
                this.vy += this.gravity;

                // Update rotation (slower for floating effect)
                this.rotation += this.rotationSpeed;

                // Gentle air resistance
                this.vx *= 0.995;

                // Check if particle is still on screen
                return this.y < this.canvas.height + 50;  // Allow particles to fall slightly off screen
            }

            draw(ctx) {
                ctx.save();
                ctx.fillStyle = this.color;

                // Translate to particle position and rotate
                ctx.translate(this.x, this.y);
                ctx.rotate(this.rotation);

                // Draw rectangle
                ctx.fillRect(-this.width / 2, -this.height / 2, this.width, this.height);

                ctx.restore();
            }
        }

        function startConfetti() {
            const canvas = document.getElementById('confettiCanvas');
            if (!canvas) return;

            // Show the canvas
            canvas.classList.add('active');

            // Set canvas size to full window
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;

            // Reset confetti system
            confettiParticles = [];
            confettiRunning = true;

            // Create initial burst of particles already on screen for immediate effect
            const initialCount = 50;
            for (let i = 0; i < initialCount; i++) {
                let particle;
                if (confettiParticlePool.length > 0) {
                    particle = confettiParticlePool.pop();
                    particle.reset(canvas);
                } else {
                    particle = new ConfettiParticle(canvas);
                }
                // Distribute particles across the screen vertically
                particle.y = Math.random() * canvas.height * 0.6 - 50;
                confettiParticles.push(particle);
            }

            // Start animation
            if (confettiAnimationId) {
                cancelAnimationFrame(confettiAnimationId);
            }
            animateConfetti();
        }

        function animateConfetti() {
            const canvas = document.getElementById('confettiCanvas');
            if (!canvas || !canvas.width || !canvas.height) return;

            const ctx = canvas.getContext('2d');

            // Continue generating new particles while running (every 3 frames)
            confettiFrameCount++;
            if (confettiRunning && confettiFrameCount % 3 === 0) {
                // Get particle from pool or create new one
                let particle;
                if (confettiParticlePool.length > 0) {
                    particle = confettiParticlePool.pop();
                    particle.reset(canvas);
                } else {
                    particle = new ConfettiParticle(canvas);
                }
                confettiParticles.push(particle);
            }

            // Clear canvas
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Update and draw particles
            const activeParticles = [];
            for (let i = 0; i < confettiParticles.length; i++) {
                const particle = confettiParticles[i];
                const alive = particle.update();
                if (alive) {
                    particle.draw(ctx);
                    activeParticles.push(particle);
                } else {
                    // Return dead particle to pool
                    confettiParticlePool.push(particle);
                }
            }
            confettiParticles = activeParticles;

            // Continue animation if particles exist or still running
            if (confettiParticles.length > 0 || confettiRunning) {
                confettiAnimationId = requestAnimationFrame(animateConfetti);
            } else {
                confettiAnimationId = null;
                // Clear canvas and hide it
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                canvas.classList.remove('active');
            }
        }

        function stopConfetti() {
            // Stop generating new particles
            confettiRunning = false;

            // Return all active particles to pool
            confettiParticlePool.push(...confettiParticles);
            confettiParticles = [];

            // Cancel animation and clean up canvas
            if (confettiAnimationId) {
                cancelAnimationFrame(confettiAnimationId);
                confettiAnimationId = null;
            }

            const canvas = document.getElementById('confettiCanvas');
            if (canvas) {
                const ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                canvas.classList.remove('active');
            }
        }

        // Render victory popup
        function renderVictoryPopup() {
            if (!victoryPopupVisible) return;
            
            ctx.save();
            ctx.globalAlpha = victoryPopupOpacity;
            
            // Semi-transparent overlay
            ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Popup background
            const popupWidth = 500;
            const popupHeight = 300;
            const popupX = (canvas.width - popupWidth) / 2;
            const popupY = (canvas.height - popupHeight) / 2;
            
            // Gradient background
            const gradient = ctx.createLinearGradient(popupX, popupY, popupX, popupY + popupHeight);
            gradient.addColorStop(0, '#FFD700');
            gradient.addColorStop(0.5, '#FFA500');
            gradient.addColorStop(1, '#FF8C00');
            
            ctx.fillStyle = gradient;
            ctx.shadowColor = '#FFD700';
            ctx.shadowBlur = 30;
            
            // Rounded rectangle
            ctx.beginPath();
            ctx.roundRect(popupX, popupY, popupWidth, popupHeight, 20);
            ctx.fill();
            
            // Border
            ctx.strokeStyle = '#FFFFFF';
            ctx.lineWidth = 4;
            ctx.stroke();
            
            // Title text
            ctx.fillStyle = '#FFFFFF';
            ctx.font = 'bold 48px Poppins, sans-serif';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.shadowColor = '#000000';
            ctx.shadowBlur = 5;
            ctx.shadowOffsetX = 2;
            ctx.shadowOffsetY = 2;
            
            ctx.fillText('🎉 LEVEL COMPLETE! 🎉', canvas.width / 2, popupY + 80);
            
            // Subtitle
            ctx.font = 'bold 24px Poppins, sans-serif';
            ctx.fillText('Congratulations!', canvas.width / 2, popupY + 140);
            
            // Stats display
            ctx.font = '18px Poppins, sans-serif';
            ctx.fillText('All liquids sorted perfectly!', canvas.width / 2, popupY + 160);
            
            // Calculate completion time
            const completionTimeMs = levelCompletionTime - levelStartTime;
            const minutes = Math.floor(completionTimeMs / 60000);
            const seconds = Math.floor((completionTimeMs % 60000) / 1000);
            const timeString = minutes > 0 ? `${minutes}m ${seconds}s` : `${seconds}s`;
            
            ctx.font = 'bold 20px Poppins, sans-serif';
            ctx.fillText(`Steps: ${stepCount} | Time: ${timeString}`, canvas.width / 2, popupY + 190);
            
            // Continue button
            const buttonWidth = 200;
            const buttonHeight = 50;
            const buttonX = (canvas.width - buttonWidth) / 2;
            const buttonY = popupY + 230;
            
            ctx.fillStyle = '#4CAF50';
            ctx.shadowColor = '#2E7D32';
            ctx.shadowBlur = 10;
            ctx.beginPath();
            ctx.roundRect(buttonX, buttonY, buttonWidth, buttonHeight, 25);
            ctx.fill();
            
            ctx.fillStyle = '#FFFFFF';
            ctx.font = 'bold 20px Poppins, sans-serif';
            ctx.fillText('Continue', canvas.width / 2, buttonY + 25);
            
            ctx.restore();
        }
        
        // Handle victory popup click
        function handleVictoryPopupClick(x, y) {
            if (!victoryPopupVisible) return false;
            
            const buttonWidth = 200;
            const buttonHeight = 50;
            const buttonX = (canvas.width - buttonWidth) / 2;
            const buttonY = (canvas.height - 300) / 2 + 230;
            
            if (x >= buttonX && x <= buttonX + buttonWidth && 
                y >= buttonY && y <= buttonY + buttonHeight) {
                // Close victory popup
                victoryPopupVisible = false;
                victoryPopupOpacity = 0;
                
                // Advance to next level (increment by 1, don't jump to 10)
                currentLevel = parseInt(currentLevel) + 1;
                window.gameConfig.currentLevel = currentLevel.toString();
                document.getElementById('levelInfo').textContent = `Level ${currentLevel}`;
                
                // Generate new puzzle for the next level
                restartLevel();
                
                // Advanced to next level
                return true;
            }
            
            return false;
        }
        
        // Add splash effect when liquid lands
        function addSplashEffect(x, y, color) {
            // Create splash particles
            for (let i = 0; i < 8; i++) {
                const angle = (Math.PI * 2 * i) / 8;
                const speed = Math.random() * 3 + 2;
                splashEffects.push({
                    x: x,
                    y: y,
                    vx: Math.cos(angle) * speed,
                    vy: Math.sin(angle) * speed - Math.random() * 2,
                    size: Math.random() * 3 + 1,
                    color: color,
                    life: 0,
                    maxLife: 400 + Math.random() * 200,
                    opacity: 0.8,
                    gravity: 0.2
                });
            }
        }
        
        // Update sparkle effects
        function updateSparkleEffects(deltaTime) {
            sparkleEffects = sparkleEffects.filter(effect => {
                effect.life += deltaTime;
                
                if (effect.sparkle) {
                    // Enhanced particle physics for completion effects
                    effect.vy += effect.gravity;
                    effect.x += effect.vx;
                    effect.y += effect.vy;
                    
                    // Boundary collision detection and containment
                    if (effect.boundaryLeft !== undefined) {
                        // Check horizontal boundaries
                        if (effect.x <= effect.boundaryLeft) {
                            effect.x = effect.boundaryLeft;
                            effect.vx = Math.abs(effect.vx) * 0.6; // Bounce with energy loss
                        } else if (effect.x >= effect.boundaryRight) {
                            effect.x = effect.boundaryRight;
                            effect.vx = -Math.abs(effect.vx) * 0.6; // Bounce with energy loss
                        }
                        
                        // Check vertical boundaries
                        if (effect.y <= effect.boundaryTop) {
                            effect.y = effect.boundaryTop;
                            effect.vy = Math.abs(effect.vy) * 0.6; // Bounce with energy loss
                        } else if (effect.y >= effect.boundaryBottom) {
                            effect.y = effect.boundaryBottom;
                            effect.vy = -Math.abs(effect.vy) * 0.6; // Bounce with energy loss
                        }
                    }
                    
                    // Air resistance
                    effect.vx *= 0.995;
                    effect.vy *= 0.995;
                    
                    // Scale animation
                    effect.scale = Math.min(effect.targetScale, effect.scale + deltaTime * 0.003);
                    
                    // Rotation
                    effect.rotation += effect.rotationSpeed;
                    
                    // Fade out
                    const lifeRatio = effect.life / effect.maxLife;
                    effect.opacity = Math.max(0, 1 - lifeRatio);
                    
                    return effect.life < effect.maxLife;
                } else {
                    // Original sparkle behavior
                    effect.scale = Math.min(1, effect.life / 500);
                    effect.opacity = Math.max(0, 1 - effect.life / 1000);
                    effect.rotation += deltaTime * 0.002;
                    
                    return effect.life < 1000;
                }
            });
        }
        
        // Update splash effects
        function updateSplashEffects(deltaTime) {
            splashEffects = splashEffects.filter(effect => {
                effect.life += deltaTime;
                
                // Apply physics
                effect.vy += effect.gravity;
                effect.x += effect.vx;
                effect.y += effect.vy;
                
                // Fade out
                const lifeRatio = effect.life / effect.maxLife;
                effect.opacity = Math.max(0, 1 - lifeRatio);
                effect.size *= 0.998; // Shrink slightly
                
                return effect.life < effect.maxLife;
            });
        }
        
        // Update liquid wobble effects
        function updateLiquidWobbleEffects(deltaTime) {
            liquidWobbleEffects = liquidWobbleEffects.filter(effect => {
                effect.life += deltaTime;
                effect.amplitude *= 0.95; // Decay wobble
                
                return effect.amplitude > 0.1;
            });
        }
        
        // Add bottle shake effect
        function addBottleShakeEffect(tubeIndex) {
            bottleShakeEffects.push({
                tubeIndex: tubeIndex,
                life: 0,
                duration: 800, // 0.8 seconds
                amplitude: 8, // Maximum shake distance
                frequency: 0.02 // Shake speed
            });
        }
        
        // Add completion particle effect - fountain spray from bottle opening
        function addCompletionParticleEffect(tubeIndex) {
            const pos = tubePositions[tubeIndex];
            const centerX = pos.x + TUBE_WIDTH / 2;
            const openingY = pos.y + 45; // Slightly below bottle opening

            // Create fountain burst of colorful particles spraying upward
            const particleCount = 25;
            for (let i = 0; i < particleCount; i++) {
                // Spray angle: mostly upward with medium spread
                const spreadAngle = (Math.random() - 0.5) * Math.PI * 0.45; // -40 to +40 degrees spread
                const baseAngle = -Math.PI / 2; // Straight up
                const angle = baseAngle + spreadAngle;

                const speed = Math.random() * 4 + 3; // Medium upward velocity
                const size = Math.random() * 3 + 2;
                const colors = ['#FFD700', '#FF69B4', '#00CED1', '#FF6347', '#98FB98', '#DDA0DD', '#FFFFFF'];
                const color = colors[Math.floor(Math.random() * colors.length)];

                sparkleEffects.push({
                    x: centerX + (Math.random() - 0.5) * 20, // Slight horizontal spread at opening
                    y: openingY,
                    vx: Math.cos(angle) * speed,
                    vy: Math.sin(angle) * speed, // Negative = upward
                    size: size,
                    color: color,
                    life: 0,
                    maxLife: 2000 + Math.random() * 1000,
                    opacity: 1,
                    gravity: 0.12, // Gravity pulls particles back down
                    rotation: Math.random() * Math.PI * 2,
                    rotationSpeed: (Math.random() - 0.5) * 0.3,
                    scale: 0,
                    targetScale: 1,
                    sparkle: true,
                    tubeIndex: tubeIndex
                    // No boundary constraints - particles fly freely
                });
            }
        }
        
        // Update bottle shake effects
        function updateBottleShakeEffects(deltaTime) {
            bottleShakeEffects = bottleShakeEffects.filter(effect => {
                effect.life += deltaTime;
                
                // Decay amplitude over time for natural shake
                const lifeRatio = effect.life / effect.duration;
                effect.amplitude = 8 * (1 - lifeRatio) * (1 - lifeRatio); // Quadratic decay
                
                return effect.life < effect.duration;
            });
        }
        
        // Render sparkle effects
        function renderSparkleEffects() {
            sparkleEffects.forEach(effect => {
                // Apply clipping for completion particles to ensure they stay within bottle bounds
                if (effect.sparkle && effect.boundaryLeft !== undefined) {
                    ctx.save();
                    
                    // Create clipping region for the bottle
                    ctx.beginPath();
                    ctx.rect(
                        effect.boundaryLeft - 5, 
                        effect.boundaryTop - 5, 
                        effect.boundaryRight - effect.boundaryLeft + 10, 
                        effect.boundaryBottom - effect.boundaryTop + 10
                    );
                    ctx.clip();
                }
                
                ctx.save();
                ctx.globalAlpha = effect.opacity;
                ctx.translate(effect.x, effect.y);
                ctx.rotate(effect.rotation);
                ctx.scale(effect.scale, effect.scale);
                
                if (effect.sparkle) {
                    // Render completion particles as colorful stars
                    ctx.fillStyle = effect.color;
                    ctx.shadowColor = effect.color;
                    ctx.shadowBlur = 10;
                    
                    // Draw star shape
                    const spikes = 5;
                    const outerRadius = effect.size * 2;
                    const innerRadius = outerRadius * 0.4;
                    
                    ctx.beginPath();
                    for (let i = 0; i < spikes * 2; i++) {
                        const angle = (i * Math.PI) / spikes;
                        const radius = i % 2 === 0 ? outerRadius : innerRadius;
                        const x = Math.cos(angle) * radius;
                        const y = Math.sin(angle) * radius;
                        
                        if (i === 0) {
                            ctx.moveTo(x, y);
                        } else {
                            ctx.lineTo(x, y);
                        }
                    }
                    ctx.closePath();
                    ctx.fill();
                    
                    // Add bright center
                    ctx.fillStyle = '#FFFFFF';
                    ctx.shadowBlur = 5;
                    ctx.beginPath();
                    ctx.arc(0, 0, effect.size * 0.3, 0, Math.PI * 2);
                    ctx.fill();
                } else if (assetCache.completion_sparkle) {
                    // Original sparkle asset
                    const size = 60;
                    ctx.drawImage(assetCache.completion_sparkle, -size/2, -size/2, size, size);
                }
                
                ctx.restore();
                
                // Restore clipping if it was applied
                if (effect.sparkle && effect.boundaryLeft !== undefined) {
                    ctx.restore();
                }
            });
        }
        
        // Render splash effects
        function renderSplashEffects() {
            splashEffects.forEach(effect => {
                ctx.save();
                ctx.globalAlpha = effect.opacity;
                ctx.fillStyle = COLORS[effect.color];
                
                // Add glow to splash particles
                ctx.shadowColor = COLORS[effect.color];
                ctx.shadowBlur = 6;
                
                ctx.beginPath();
                ctx.arc(effect.x, effect.y, effect.size, 0, Math.PI * 2);
                ctx.fill();
                
                ctx.restore();
            });
        }

        // Initialize tutorial state (load from user data)
        async function initializeTutorial() {
            try {
                // Skip if already completed in this session
                if (tutorialCompletedThisSession) {
                    tutorialActive = false;
                    tutorialTargetTube = -1;
                    return;
                }

                // Check if tutorial has been completed before
                const userData = await window.lib.getUserGameState();
                const tutorialCompleted = userData.state && userData.state.tutorialCompleted;

                // Get current level ID from metadata
                const levelId = currentLevelMetadata ? currentLevelMetadata.levelId : 1;

                // Only show tutorial on Level 1 for first-time players
                if (levelId === 1 && !tutorialCompleted && gameMode === 'play') {
                    tutorialActive = true;
                    tutorialStep = 0;
                    tutorialTargetTube = 0; // Target first tube (index 0)
                } else {
                    tutorialActive = false;
                    tutorialTargetTube = -1;
                }
            } catch (error) {
                console.error('[Tutorial] Failed to load state:', error);
                tutorialActive = false;
                tutorialTargetTube = -1;
            }
        }

        // Complete tutorial and save state
        async function completeTutorial() {
            if (!tutorialActive) return;

            // Immediately mark as completed for this session
            tutorialActive = false;
            tutorialTargetTube = -1;
            tutorialCompletedThisSession = true;

            try {
                // Save tutorial completion to persistent storage
                const userData = await window.lib.getUserGameState();
                const currentState = userData.state || {};

                await window.lib.saveUserGameState({
                    ...currentState,
                    tutorialCompleted: true
                });
            } catch (error) {
                console.error('[Tutorial] Failed to save completion:', error);
            }
        }

        // Update tutorial arrow position and visibility
        function updateTutorialArrowPosition() {
            const tutorialContainer = document.getElementById('tutorialContainer');
            const tutorialHintBubble = document.getElementById('tutorialHintBubble');
            const tutorialHintText = document.getElementById('tutorialHintText');
            const tutorialArrow = document.getElementById('tutorialArrow');

            if (!tutorialActive || tutorialTargetTube === -1) {
                if (tutorialContainer) {
                    tutorialContainer.style.display = 'none';
                }
                return;
            }

            const targetPos = tubePositions[tutorialTargetTube];
            if (!targetPos) {
                if (tutorialContainer) {
                    tutorialContainer.style.display = 'none';
                }
                return;
            }

            // Show tutorial
            tutorialContainer.style.display = 'block';

            // Update hint text based on step
            tutorialHintText.textContent = "Tap";

            // Calculate positions (canvas coordinates to screen coordinates)
            const rect = canvas.getBoundingClientRect();
            const scaleX = rect.width / canvas.width;
            const scaleY = rect.height / canvas.height;

            const centerX = rect.left + (targetPos.x + TUBE_WIDTH / 2) * scaleX;
            const tubeTopY = rect.top + targetPos.y * scaleY;

            // Position hint bubble above arrow (must set position: fixed)
            tutorialHintBubble.style.position = 'fixed';
            tutorialHintBubble.style.left = centerX + 'px';
            tutorialHintBubble.style.top = (tubeTopY - 140) + 'px';
            tutorialHintBubble.style.transform = 'translateX(-50%)';

            // Position arrow pointing at tube (must set position: fixed)
            tutorialArrow.style.position = 'fixed';
            tutorialArrow.style.left = centerX + 'px';
            tutorialArrow.style.top = (tubeTopY - 70) + 'px';
            tutorialArrow.style.transform = 'translateX(-50%)';
        }

        // Update tube lift animations
        function updateTubeLiftAnimations(deltaTime) {
            const LIFT_DURATION = 250; // milliseconds
            const LIFT_AMOUNT = -50; // negative = up

            for (const [tubeIndex, animation] of tubeLiftAnimations.entries()) {
                animation.progress += deltaTime;

                if (animation.progress >= animation.duration) {
                    // Animation complete
                    tubeLiftOffsets.set(tubeIndex, animation.targetOffset);
                    tubeLiftAnimations.delete(tubeIndex);
                } else {
                    // Update position with easing
                    const t = Math.min(1, animation.progress / animation.duration);
                    const easedT = easeInOutCubic(t);
                    const currentOffset = animation.startOffset + (animation.targetOffset - animation.startOffset) * easedT;
                    tubeLiftOffsets.set(tubeIndex, currentOffset);
                }
            }
        }

        // Start lift animation for a tube with instant feedback
        function startTubeLiftAnimation(tubeIndex, targetOffset) {
            const LIFT_DURATION = 150; // Reduced from 250ms for faster response
            const currentOffset = tubeLiftOffsets.get(tubeIndex) || 0;

            // Provide instant visual feedback by immediately setting a small offset
            if (targetOffset < 0) {
                // Lifting up - give instant 10% lift
                tubeLiftOffsets.set(tubeIndex, currentOffset - 5);
            }

            tubeLiftAnimations.set(tubeIndex, {
                targetOffset: targetOffset,
                startOffset: currentOffset,
                progress: 0,
                duration: LIFT_DURATION
            });
        }

        // Get tube at position
        function getTubeAtPosition(x, y) {
            for (let i = 0; i < tubePositions.length; i++) {
                const pos = tubePositions[i];
                if (x >= pos.x && x <= pos.x + TUBE_WIDTH && 
                    y >= pos.y && y <= pos.y + TUBE_HEIGHT) {
                    return i;
                }
            }
            return -1;
        }
        
        // Get layer at position within tube
        function getLayerAtPosition(tubeIndex, x, y) {
            if (tubeIndex === -1) return -1;
            
            const pos = tubePositions[tubeIndex];
            const relativeY = y - pos.y;
            const layerIndex = Math.floor((TUBE_HEIGHT - relativeY) / LAYER_HEIGHT);
            
            return Math.max(0, Math.min(MAX_LAYERS - 1, layerIndex));
        }
        
        // Check if pour is valid
                // Check if pour is valid
        function canPour(fromTube, toTube) {
            if (fromTube === toTube) return false;
            if (fromTube < 0 || fromTube >= tubes.length) return false;
            if (toTube < 0 || toTube >= tubes.length) return false;
            
            const sourceTube = tubes[fromTube];
            const destTube = tubes[toTube];
            
            // Find top layer in source tube
            let sourceTopIndex = -1;
            for (let i = MAX_LAYERS - 1; i >= 0; i--) {
                if (sourceTube[i] !== null) {
                    sourceTopIndex = i;
                    break;
                }
            }
            
            if (sourceTopIndex === -1) return false; // Source tube is empty
            
            // Count how many matching colors are at the top of source tube
            const topColor = sourceTube[sourceTopIndex];
            let matchingCount = 0;
            for (let i = sourceTopIndex; i >= 0; i--) {
                if (sourceTube[i] === topColor) {
                    matchingCount++;
                } else {
                    break;
                }
            }
            
            // Find top layer in destination tube
            let destTopIndex = -1;
            for (let i = MAX_LAYERS - 1; i >= 0; i--) {
                if (destTube[i] !== null) {
                    destTopIndex = i;
                    break;
                }
            }
            
            // Calculate available space in destination
            const availableSpace = MAX_LAYERS - 1 - destTopIndex;
            
            // Check if destination has enough space for all matching colors
            if (availableSpace < matchingCount) return false;
            
            // If destination is empty, pour is valid
            if (destTopIndex === -1) return true;
            
            // If destination has liquid, colors must match
            return sourceTube[sourceTopIndex] === destTube[destTopIndex];
        }
        
        // Animation Helper Functions

        // Easing functions for smooth animations
        const easeInOutCubic = (t) => t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
        const easeInOutQuart = (t) => t < 0.5 ? 8 * t * t * t * t : 1 - Math.pow(-2 * t + 2, 4) / 2;

        // Define animation phases with timing
        const ANIMATION_PHASES = {
            MOVE: { start: 0.00, end: 0.20, name: 'MOVE' },
            TILT: { start: 0.20, end: 0.30, name: 'TILT' },
            POUR: { start: 0.30, end: 0.80, name: 'POUR' },
            RETURN: { start: 0.80, end: 1.00, name: 'RETURN' }
        };

        // Get current animation phase and normalized progress within that phase
        function getCurrentPhase(totalProgress) {
            for (const phase of Object.values(ANIMATION_PHASES)) {
                if (totalProgress >= phase.start && totalProgress < phase.end) {
                    const phaseProgress = (totalProgress - phase.start) / (phase.end - phase.start);
                    return { phase: phase, progress: phaseProgress };
                }
            }
            return { phase: ANIMATION_PHASES.RETURN, progress: 1.0 };
        }

        // Centralized tilt angle calculation for all animation phases
        function calculateTiltAngle(phaseName, phaseProgress, maxTiltAngle) {
            switch(phaseName) {
                case 'MOVE':
                    return 0; // No tilt during movement

                case 'TILT':
                    return maxTiltAngle * easeInOutQuart(phaseProgress);

                case 'POUR':
                    // Pour phase includes both pouring and untilting
                    // First 62.5% (0.30-0.70 of total): Hold max tilt
                    // Last 37.5% (0.70-0.80 of total): Untilt back to upright
                    const pourOnlyEnd = 0.625; // 70% of total / 80% of total = 0.875, but within phase: (0.70-0.30)/(0.80-0.30) = 0.80
                    if (phaseProgress < pourOnlyEnd) {
                        return maxTiltAngle; // Hold at max tilt
                    } else {
                        const untiltProgress = (phaseProgress - pourOnlyEnd) / (1.0 - pourOnlyEnd);
                        return maxTiltAngle * (1 - easeInOutCubic(untiltProgress));
                    }

                case 'RETURN':
                    // Already untilted in POUR phase, stay upright
                    return 0;

                default:
                    return 0;
            }
        }

        // Perform pour operation - updates state immediately, then animates
        function pourLiquid(fromTube, toTube) {
            if (!canPour(fromTube, toTube)) return false;

            const sourceTube = tubes[fromTube];
            const destTube = tubes[toTube];

            // Find source top layer
            let sourceTopIndex = -1;
            for (let i = MAX_LAYERS - 1; i >= 0; i--) {
                if (sourceTube[i] !== null) {
                    sourceTopIndex = i;
                    break;
                }
            }

            // Count how many matching colors are at the top of source tube
            const topColor = sourceTube[sourceTopIndex];
            let matchingCount = 0;
            for (let i = sourceTopIndex; i >= 0; i--) {
                if (sourceTube[i] === topColor) {
                    matchingCount++;
                } else {
                    break;
                }
            }

            // Find destination empty slot
            let destEmptyIndex = -1;
            for (let i = 0; i < MAX_LAYERS; i++) {
                if (destTube[i] === null) {
                    destEmptyIndex = i;
                    break;
                }
            }

            // Capture BEFORE state snapshots (for animation visual reference)
            const snapshot_sourceInitial = [...sourceTube];
            const snapshot_targetInitial = [...destTube];

            // UPDATE GAME STATE IMMEDIATELY
            // Pour all matching colors from source to destination
            for (let i = 0; i < matchingCount; i++) {
                destTube[destEmptyIndex + i] = topColor;
                sourceTube[sourceTopIndex - i] = null;
            }

            // Capture AFTER state snapshots
            const snapshot_sourceFinal = [...sourceTube];
            const snapshot_targetFinal = [...destTube];

            // Update global game config
            window.gameConfig.tubes = JSON.parse(JSON.stringify(tubes));

            // Update move history for undo functionality
            moveHistory.push({
                from: fromTube,
                to: toTube,
                count: matchingCount
            });

            // Increment step counter
            stepCount++;
            updateStepCounter();

            // Play pour sound with pitch variation
            if (audioManager) {
                audioManager.playSound('pour_sound', { pitchVariation: true });
            }

            // Start animation with snapshots (animation will not modify game state)
            startPourAnimation(
                fromTube,
                toTube,
                topColor,
                matchingCount,
                {
                    snapshot_sourceInitial,
                    snapshot_sourceFinal,
                    snapshot_targetInitial,
                    snapshot_targetFinal
                }
            );

            return true;
        }
        
        // Start pour animation
        // Create physics-based liquid particles
        function createLiquidParticles(fromTube, toTube, color, count = 20) {
    // Simplified particle creation without Matter.js for now
    const particles = [];
    const fromPos = tubePositions[fromTube];
    const toPos = tubePositions[toTube];
    const startX = fromPos.x + TUBE_WIDTH / 2;
    const startY = fromPos.y + 20;
    
    for (let i = 0; i < count; i++) {
        particles.push({
            x: startX + (Math.random() - 0.5) * 8,
            y: startY + i * 2,
            vx: (Math.random() - 0.5) * 3,
            vy: Math.random() * 2 + 1,
            size: Math.random() * 3 + 2,
            color: color,
            life: 0,
            maxLife: 1000 + Math.random() * 500,
            opacity: 0.8 + Math.random() * 0.2,
            gravity: 0.3
        });
    }
    
    return particles;
}
        
        // Start pour animation using state snapshots (game state already updated)
        function startPourAnimation(fromTube, toTube, color, layerCount, snapshots) {
            // Add tubes to pouring set
            pouringTubes.add(fromTube);
            pouringTubes.add(toTube);

            const fromPos = tubePositions[fromTube];
            const toPos = tubePositions[toTube];

            // Read current lift offset to start animation from lifted position
            const currentLiftOffset = tubeLiftOffsets.get(fromTube) || 0;

            // Determine tilt direction based on relative positions
            const isTargetOnLeft = toPos.x < fromPos.x;
            const tiltDirection = isTargetOnLeft ? -1 : 1; // -1 for left tilt, 1 for right tilt

            // Position source bottle closer and directly above destination for vertical water stream
            const horizontalOffset = 90;
            const targetX = isTargetOnLeft
                ? toPos.x + horizontalOffset   // Target on left: offset slightly right
                : toPos.x - horizontalOffset;  // Target on right: offset slightly left
            const targetY = toPos.y - TUBE_HEIGHT * 0.8; // Position closer above destination

            // Adjust duration based on number of layers being poured
            const baseDuration = 1500;
            const adjustedDuration = baseDuration + (layerCount - 1) * 300;

            // Count liquid layers in snapshots for animation
            const sourceInitialCount = snapshots.snapshot_sourceInitial.filter(l => l !== null).length;
            const sourceFinalCount = snapshots.snapshot_sourceFinal.filter(l => l !== null).length;
            const targetInitialCount = snapshots.snapshot_targetInitial.filter(l => l !== null).length;
            const targetFinalCount = snapshots.snapshot_targetFinal.filter(l => l !== null).length;

            // Add animation to array
            pourAnimations.push({
                from: fromTube,
                to: toTube,
                color: color,
                layerCount: layerCount,
                progress: 0,
                duration: adjustedDuration,

                // Bottle movement and tilting properties
                originalPos: { x: fromPos.x, y: fromPos.y + currentLiftOffset },
                targetPos: { x: targetX, y: targetY },
                currentPos: { x: fromPos.x, y: fromPos.y + currentLiftOffset },
                basePos: { x: fromPos.x, y: fromPos.y }, // Base position without lift for return

                tiltAngle: 0,
                maxTiltAngle: Math.PI / 2.5 * tiltDirection, // 72 degrees tilt
                tiltDirection: tiltDirection,

                // Visual liquid level tracking (for rendering only, uses snapshots)
                visual_sourceLiquidLevel: sourceInitialCount,
                visual_sourceFinalLevel: sourceFinalCount,
                visual_targetLiquidLevel: targetInitialCount,
                visual_targetFinalLevel: targetFinalCount,
                visual_liquidFlowRate: 0,

                // State snapshots (for rendering reference, game state already updated)
                snapshots: snapshots,

                // Physics particles for this animation
                physicsParticles: []
            });
        }
        
        // Update pour animation
        // Update physics-based liquid particles for all animations
        function updatePhysicsParticles(deltaTime) {
            if (pourAnimations.length === 0) return;

            // Update particles for each animation
            pourAnimations.forEach(anim => {
                if (!anim.physicsParticles) return;

                anim.physicsParticles = anim.physicsParticles.filter(particle => {
                    particle.life += deltaTime;

                    // Apply gravity and velocity
                    particle.vy += particle.gravity;
                    particle.x += particle.vx;
                    particle.y += particle.vy;

                    // Add air resistance
                    particle.vx *= 0.998;
                    particle.vy *= 0.999;

                    // Fade out over time
                    const lifeRatio = particle.life / particle.maxLife;
                    particle.opacity = Math.max(0, 1 - lifeRatio);

                    // Keep particle if still alive
                    return lifeRatio < 1;
                });
            });
        }
        
        // Update pour animation with physics engine
        // Update all pour animations with realistic bottle movement
        function updatePourAnimation(deltaTime) {
            if (pourAnimations.length === 0) return;

            // Update each animation
            pourAnimations.forEach(anim => {
                if (anim.isComplete) return;

                anim.progress += deltaTime;
                const totalProgress = Math.min(1, anim.progress / anim.duration);

                // Get current phase using helper function
                const { phase, progress: phaseProgress } = getCurrentPhase(totalProgress);

                // Update bottle position based on phase
                switch(phase.name) {
                    case 'MOVE':
                        // Move to target position
                        const moveEase = easeInOutCubic(phaseProgress);
                        anim.currentPos.x = anim.originalPos.x +
                            (anim.targetPos.x - anim.originalPos.x) * moveEase;
                        anim.currentPos.y = anim.originalPos.y +
                            (anim.targetPos.y - anim.originalPos.y) * moveEase;
                        break;

                    case 'TILT':
                        // Hold at target position during tilt
                        break;

                    case 'POUR':
                        // Hold at target position, update visual liquid flow
                        const pourOnlyProgress = Math.min(phaseProgress, 1.0);
                        anim.visual_liquidFlowRate = Math.sin(pourOnlyProgress * Math.PI) * anim.layerCount * 1.5;

                        const flowAmount = anim.visual_liquidFlowRate * deltaTime * 0.0015;
                        anim.visual_sourceLiquidLevel = Math.max(
                            anim.visual_sourceFinalLevel,
                            anim.visual_sourceLiquidLevel - flowAmount
                        );
                        anim.visual_targetLiquidLevel = Math.min(
                            anim.visual_targetFinalLevel,
                            anim.visual_targetLiquidLevel + flowAmount
                        );
                        break;

                    case 'RETURN':
                        // Return to base position (ground level, not lifted)
                        const returnEase = easeInOutCubic(phaseProgress);
                        anim.currentPos.x = anim.targetPos.x +
                            (anim.basePos.x - anim.targetPos.x) * returnEase;
                        anim.currentPos.y = anim.targetPos.y +
                            (anim.basePos.y - anim.targetPos.y) * returnEase;
                        break;
                }

                // Update tilt angle using centralized function
                anim.tiltAngle = calculateTiltAngle(phase.name, phaseProgress, anim.maxTiltAngle);

                // Animation completion
                if (anim.progress >= anim.duration) {
                    // Force visual liquid levels to exact final values
                    anim.visual_sourceLiquidLevel = anim.visual_sourceFinalLevel;
                    anim.visual_targetLiquidLevel = anim.visual_targetFinalLevel;

                    // Mark as complete
                    anim.isComplete = true;

                    // Remove tubes from pouring set
                    pouringTubes.delete(anim.from);
                    pouringTubes.delete(anim.to);

                    // Check for completed tubes and victory
                    checkCompletedTubes();
                    checkVictory();

                    // Check for game over condition after animation completes
                    setTimeout(() => {
                        checkGameOver();
                    }, 500);
                }
            });

            // Remove completed animations
            pourAnimations = pourAnimations.filter(anim => !anim.isComplete);
        }
        
        // Undo last move
        function undoMove() {
            // Wait for all pours to complete before allowing undo
            if (moveHistory.length === 0 || pourAnimations.length > 0) {
                return;
            }
            
            const lastMove = moveHistory.pop();
            const sourceTube = tubes[lastMove.to];
            const destTube = tubes[lastMove.from];
            const layerCount = lastMove.count || 1; // Default to 1 for backward compatibility
            
            // Move back the specified number of layers
            for (let i = 0; i < layerCount; i++) {
                // Find the topmost liquid in source tube
                let sourceTopIndex = -1;
                for (let j = MAX_LAYERS - 1; j >= 0; j--) {
                    if (sourceTube[j] !== null) {
                        sourceTopIndex = j;
                        break;
                    }
                }
                
                if (sourceTopIndex === -1) break; // No more liquid to move back
                
                // Find empty slot in destination tube (from top)
                let destEmptyIndex = -1;
                for (let j = MAX_LAYERS - 1; j >= 0; j--) {
                    if (destTube[j] === null) {
                        destEmptyIndex = j;
                        break;
                    }
                }
                
                if (destEmptyIndex === -1) break; // No space in destination
                
                // Move liquid back
                destTube[destEmptyIndex] = sourceTube[sourceTopIndex];
                sourceTube[sourceTopIndex] = null;
            }
            
            // Update game config
            window.gameConfig.tubes = JSON.parse(JSON.stringify(tubes));
            
            // Decrement step counter for undo
            if (stepCount > 0) {
                stepCount--;
                updateStepCounter();
            }
            
            checkCompletedTubes();
        }
        
        // Restart level
        function restartLevel() {
            if (pourAnimations.length > 0) return;

            // Load preset level data from levelManager
            const currentLevelData = levelManager.levels[levelManager.currentLevelIndex];

            if (currentLevelData && currentLevelData.tubes) {
                // Use preset tubes from level configuration
                tubes = JSON.parse(JSON.stringify(currentLevelData.tubes));

                // Update level metadata for scoring
                currentLevelMetadata = {
                    optimalSteps: currentLevelData.optimalSteps || 20,
                    targetTime: currentLevelData.targetTime || 120,
                    difficulty: currentLevelData.difficulty || 'medium',
                    levelId: currentLevelData.id
                };

                console.log('🔄 Restart Level - Updated metadata:', currentLevelMetadata);
            } else {
                // Fallback: generate random puzzle if no preset data
                tubes = generateLevelPuzzle(currentLevel);

                // Set default metadata
                currentLevelMetadata = {
                    optimalSteps: 20,
                    targetTime: 120,
                    difficulty: 'medium',
                    levelId: currentLevel
                };

                console.log('🔄 Restart Level - Default metadata:', currentLevelMetadata);
            }

            // Update config
            window.gameConfig.tubes = JSON.parse(JSON.stringify(tubes));

            // Recalculate positions for new tube count
            tubePositions = calculateTubePositions(tubes.length);
            
            // Reset game state
            moveHistory = [];
            selectedTube = -1;
            hintDestinationTube = -1;
            pouringTubes.clear();
            pourAnimations = [];
            completedTubes.clear();
            sparkleEffects = [];
            splashEffects = [];
            liquidWobbleEffects = [];
            bottleShakeEffects = [];
            victoryPopupVisible = false;
            victoryPopupOpacity = 0;
            gameOverPopupVisible = false;
            gameOverPopupOpacity = 0;
            gameTimerPopupVisible = false;
            gameTimerPopupOpacity = 0;
            gameTimerFailed = false;
            
            // Reset hint cooldown
            hintCooldownActive = false;
            hintCooldownRemaining = 0;
            hintDestinationTube = -1;
            updateHintButtonState();
            
            // Reset step counter and start time
            stepCount = 0;
            levelStartTime = Date.now();
            levelCompletionTime = 0;
            updateStepCounter();
            
            // Check for initially completed tubes
            checkCompletedTubes();
            
            // Restart timer if in play mode
            if (gameMode === 'play') {
                startGameTimer();
            }
            
            // Check for game over condition after a short delay
            setTimeout(() => {
                checkGameOver();
            }, 1000);

            // Initialize tutorial when entering level (async, doesn't block)
            initializeTutorial();

            // Level restarted - no feedback needed
        }
        
        // Check if any valid moves are available
        function hasValidMoves() {
            for (let from = 0; from < tubes.length; from++) {
                for (let to = 0; to < tubes.length; to++) {
                    if (canPour(from, to)) {
                        return true;
                    }
                }
            }
            return false;
        }
        
        // Show game over popup
        function showGameOverPopup() {
            const modal = document.getElementById('gameOverModal');
            if (modal) {
                modal.style.display = 'flex';
                setTimeout(() => modal.classList.add('show'), 10);
            }
        }
        
        // Render game over popup - No longer needed (using HTML modal)
        function renderGameOverPopup() {
            // Removed - now using HTML modal
        }

        // Handle game over popup click - No longer needed
        function handleGameOverPopupClick(x, y) {
            // Removed - now using HTML modal with button event listeners
            return false;
        }
        
        // Check for game over condition
        function checkGameOver() {
            // Only check in play mode and when not pouring
            if (gameMode !== 'play' || pourAnimations.length > 0) return;
            
            // Check if timer has failed
            if (gameTimerFailed) {
                return; // Timer fail popup is already shown
            }
            
            // Check if victory has been achieved first
            const nonEmptyTubes = tubes.filter(tube => tube.some(layer => layer !== null));
            const completedCount = Array.from(completedTubes).length;
            
            if (completedCount === nonEmptyTubes.length && nonEmptyTubes.length > 0) {
                // Victory achieved, don't check for game over
                return;
            }
            
            // Check if there are any valid moves
            if (!hasValidMoves()) {
                // No valid moves available - game over
                showGameOverPopup();
            }
        }
        
        // Provide hint with cooldown
        function provideHint() {
            if (pourAnimations.length > 0) return;

            // Check if hint is on cooldown
            if (hintCooldownActive) {
                // Hint is on cooldown, just return (countdown is shown on button)
                return;
            }

            // Clear any previous selection first
            selectedTube = -1;
            hintDestinationTube = -1;

            // Simple hint: find a valid move
            for (let from = 0; from < tubes.length; from++) {
                for (let to = 0; to < tubes.length; to++) {
                    if (canPour(from, to)) {
                        // Set both source and destination for highlighting
                        selectedTube = from;
                        hintDestinationTube = to;

                        // Hint will be shown visually with highlighting

                        // Start cooldown
                        startHintCooldown();
                        return;
                    }
                }
            }

            // No valid moves found - just clear the selection
            selectedTube = -1;
            hintDestinationTube = -1;
        }
        
        // Start hint cooldown timer
        function startHintCooldown() {
            hintCooldownActive = true;
            hintCooldownRemaining = hintCooldownTime;
            
            // Update hint button appearance
            updateHintButtonState();
        }

        // Update hint cooldown
        function updateHintCooldown(deltaTime) {
            if (!hintCooldownActive) return;
            
            hintCooldownRemaining -= deltaTime;
            
            if (hintCooldownRemaining <= 0) {
                hintCooldownActive = false;
                hintCooldownRemaining = 0;
                hintDestinationTube = -1; // Clear hint destination when cooldown expires
            }
            
            // Update hint button appearance
            updateHintButtonState();
        }
        
        // Update game countdown timer
        function updateGameTimer(deltaTime) {
            if (!gameTimerActive || gameTimerFailed || gameMode !== 'play') return;
            
            gameTimeRemaining -= deltaTime;
            
            if (gameTimeRemaining <= 0) {
                gameTimeRemaining = 0;
                gameTimerFailed = true;
                gameTimerActive = false;
                showGameTimerFailPopup();
            }
            
            // Update timer display
            updateTimerDisplay();
        }
        
        // Update timer display
        function updateTimerDisplay() {
            const timerElement = document.getElementById('countdownTimer');
            const timerText = timerElement?.querySelector('.timer-text');
            if (!timerElement || !timerText) return;
            
            const minutes = Math.floor(gameTimeRemaining / 60000);
            const seconds = Math.floor((gameTimeRemaining % 60000) / 1000);
            const timeString = `${minutes}:${seconds.toString().padStart(2, '0')}`;
            
            timerText.textContent = timeString;
            
            // Update visual state based on remaining time
            timerElement.classList.remove('warning', 'critical');
            
            if (gameTimeRemaining <= 30000) { // Last 30 seconds
                timerElement.classList.add('critical');
            } else if (gameTimeRemaining <= 60000) { // Last minute
                timerElement.classList.add('warning');
            }
        }
        
        // Start game timer
        function startGameTimer() {
            gameTimeRemaining = gameTimeLimit;
            gameTimerActive = true;
            gameTimerFailed = false;
            updateTimerDisplay();
        }
        
        // Stop game timer
        function stopGameTimer() {
            gameTimerActive = false;
        }
        
        // Show game timer fail popup
        function showGameTimerFailPopup() {
            const modal = document.getElementById('timeUpModal');
            if (modal) {
                modal.style.display = 'flex';
                setTimeout(() => modal.classList.add('show'), 10);
            }
        }

        // Render game timer fail popup - No longer needed (using HTML modal)
        function renderGameTimerFailPopup() {
            // Removed - now using HTML modal
        }

        // Handle game timer fail popup click - No longer needed
        function handleGameTimerFailPopupClick(x, y) {
            // Removed - now using HTML modal with button event listeners
            return false;
        }
        
        // Update hint button visual state
        function updateHintButtonState() {
            const hintBtn = document.getElementById('hintBtn');
            const hintCountdown = document.getElementById('hintCountdown');
            const hintIcon = hintBtn.querySelector('.button-icon');

            if (hintCooldownActive) {
                hintBtn.disabled = true;
                hintBtn.style.opacity = '0.7';

                // Show countdown
                if (hintCountdown) {
                    const secondsRemaining = Math.ceil(hintCooldownRemaining / 1000);
                    hintCountdown.textContent = secondsRemaining + 's';
                    hintCountdown.style.display = 'block';
                }

                // Hide icon when countdown is active
                if (hintIcon) {
                    hintIcon.style.opacity = '0.3';
                }
            } else {
                hintBtn.disabled = false;
                hintBtn.style.opacity = '1';

                // Hide countdown
                if (hintCountdown) {
                    hintCountdown.style.display = 'none';
                }

                // Show icon when ready
                if (hintIcon) {
                    hintIcon.style.opacity = '1';
                }
            }
        }
        
        // Render tube
        // Render tube with enhanced liquid physics
// Render tube with enhanced bottle-like design
// Render tube with enhanced bottle-like design and realistic movement
function renderTube(tubeIndex, x, y) {
    const tube = tubes[tubeIndex];
    const isSelected = selectedTube === tubeIndex;
    const isHintDestination = hintDestinationTube === tubeIndex;
    const isCompleted = completedTubes.has(tubeIndex);
    
    // Apply bottle movement and tilting if this tube is being poured from
    let renderX = x;
    let renderY = y;
    let tiltAngle = 0;

    // Apply lift animation offset
    const liftOffset = tubeLiftOffsets.get(tubeIndex) || 0;
    renderY += liftOffset;

    // Check if this tube is the source of any pour animation
    const tubeAnim = pourAnimations.find(anim => anim.from === tubeIndex);
    if (tubeAnim) {
        // Use the animated position instead of original position
        renderX = tubeAnim.currentPos.x;
        renderY = tubeAnim.currentPos.y;
        tiltAngle = tubeAnim.tiltAngle;
    }
    
    // Apply shake effect if this bottle is completed
    const shakeEffect = bottleShakeEffects.find(effect => effect.tubeIndex === tubeIndex);
    if (shakeEffect) {
        const shakeX = Math.sin(shakeEffect.life * shakeEffect.frequency) * shakeEffect.amplitude;
        const shakeY = Math.cos(shakeEffect.life * shakeEffect.frequency * 1.3) * shakeEffect.amplitude * 0.5;
        renderX += shakeX;
        renderY += shakeY;
    }
    
    // Destination tube remains steady during pouring
    
    // Draw bottle with proper proportions
    ctx.save();

    // Apply rotation for tilting effect around bottle center
    if (Math.abs(tiltAngle) > 0.001) {
        const centerX = renderX + TUBE_WIDTH / 2;
        const centerY = renderY + TUBE_HEIGHT / 2;
        ctx.translate(centerX, centerY);
        ctx.rotate(tiltAngle);
        ctx.translate(-centerX, -centerY);
    }
    
    // Bottle dimensions with enhanced proportions
    const bottleNeckWidth = 22;
    const bottleNeckHeight = 28;
    const bottleBodyWidth = TUBE_WIDTH - 12;
    const bottleBodyHeight = TUBE_HEIGHT - bottleNeckHeight - 12;
    const cornerRadius = 10;
    
    // Bottle body (main container)
    const bodyX = renderX + 6;
    const bodyY = renderY + bottleNeckHeight + 6;
    
    const neckX = renderX + (TUBE_WIDTH - bottleNeckWidth) / 2;
    const neckY = renderY + 6;
    
    const bottleImage = assetCache.glass_test_tube;
    const hasBottleImage = bottleImage && bottleImage.complete && bottleImage.naturalWidth > 0;

    if (hasBottleImage) {
        ctx.imageSmoothingEnabled = true;
        ctx.drawImage(bottleImage, renderX, renderY, TUBE_WIDTH, TUBE_HEIGHT);
    } else {
        // Candy-style glossy bottle body (fallback)
        const bodyGradient = ctx.createLinearGradient(bodyX, bodyY, bodyX + bottleBodyWidth, bodyY);
        bodyGradient.addColorStop(0, 'rgba(255, 255, 255, 0.95)');
        bodyGradient.addColorStop(0.5, 'rgba(240, 248, 255, 0.92)');
        bodyGradient.addColorStop(1, 'rgba(230, 245, 255, 0.9)');

        ctx.fillStyle = bodyGradient;
        ctx.strokeStyle = isSelected ? '#00FF7F' : (isHintDestination ? '#00BFFF' : '#FFFFFF');
        ctx.lineWidth = 6;
        
        // Create rounded rectangle path for bottle body
        ctx.beginPath();
        ctx.moveTo(bodyX + cornerRadius, bodyY);
        ctx.lineTo(bodyX + bottleBodyWidth - cornerRadius, bodyY);
        ctx.quadraticCurveTo(bodyX + bottleBodyWidth, bodyY, bodyX + bottleBodyWidth, bodyY + cornerRadius);
        ctx.lineTo(bodyX + bottleBodyWidth, bodyY + bottleBodyHeight - cornerRadius);
        ctx.quadraticCurveTo(bodyX + bottleBodyWidth, bodyY + bottleBodyHeight, bodyX + bottleBodyWidth - cornerRadius, bodyY + bottleBodyHeight);
        ctx.lineTo(bodyX + cornerRadius, bodyY + bottleBodyHeight);
        ctx.quadraticCurveTo(bodyX, bodyY + bottleBodyHeight, bodyX, bodyY + bottleBodyHeight - cornerRadius);
        ctx.lineTo(bodyX, bodyY + cornerRadius);
        ctx.quadraticCurveTo(bodyX, bodyY, bodyX + cornerRadius, bodyY);
        ctx.closePath();
        
        ctx.fill();
        ctx.stroke();
        
        // Candy-style bottle neck with tapered design
        const neckGradient = ctx.createLinearGradient(neckX, neckY, neckX + bottleNeckWidth, neckY);
        neckGradient.addColorStop(0, 'rgba(255, 255, 255, 0.95)');
        neckGradient.addColorStop(1, 'rgba(240, 248, 255, 0.92)');

        ctx.fillStyle = neckGradient;
        ctx.strokeStyle = isSelected ? '#00FF7F' : (isHintDestination ? '#00BFFF' : '#FFFFFF');
        ctx.lineWidth = 6;
        
        // Draw neck with elegant taper
        ctx.beginPath();
        ctx.moveTo(neckX + 3, neckY);
        ctx.lineTo(neckX + bottleNeckWidth - 3, neckY);
        ctx.lineTo(neckX + bottleNeckWidth + 1, neckY + bottleNeckHeight);
        ctx.lineTo(neckX - 1, neckY + bottleNeckHeight);
        ctx.closePath();
        
        ctx.fill();
        ctx.stroke();
        
        // Enhanced bottle opening (rim) with depth
        const rimGradient = ctx.createLinearGradient(neckX, neckY, neckX, neckY + 4);
        rimGradient.addColorStop(0, '#90A4AE');
        rimGradient.addColorStop(1, '#78909C');
        
        ctx.fillStyle = rimGradient;
        ctx.fillRect(neckX, neckY, bottleNeckWidth, 4);
        
        // Add inner rim shadow for depth
        ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
        ctx.fillRect(neckX + 2, neckY + 1, bottleNeckWidth - 4, 1);
        
        // Enhanced bottle highlight/shine with multiple layers
        const highlight1 = ctx.createLinearGradient(bodyX, bodyY, bodyX + bottleBodyWidth * 0.4, bodyY);
        highlight1.addColorStop(0, 'rgba(255, 255, 255, 0.8)');
        highlight1.addColorStop(0.7, 'rgba(255, 255, 255, 0.3)');
        highlight1.addColorStop(1, 'rgba(255, 255, 255, 0.1)');
        
        ctx.fillStyle = highlight1;
        ctx.fillRect(bodyX + 3, bodyY + 3, bottleBodyWidth * 0.3, bottleBodyHeight - 6);
        
        // Secondary highlight for extra glass effect
        const highlight2 = ctx.createLinearGradient(bodyX + bottleBodyWidth * 0.7, bodyY, bodyX + bottleBodyWidth, bodyY);
        highlight2.addColorStop(0, 'rgba(255, 255, 255, 0.1)');
        highlight2.addColorStop(1, 'rgba(255, 255, 255, 0.4)');
        
        ctx.fillStyle = highlight2;
        ctx.fillRect(bodyX + bottleBodyWidth * 0.8, bodyY + 3, bottleBodyWidth * 0.15, bottleBodyHeight - 6);
    }

    // Selection effect handled by lift animation (see tubeLiftOffsets)
    
    if (isHintDestination) {
        ctx.shadowColor = '#2196F3';
        ctx.shadowBlur = 25;
        
        const pulseIntensity = 0.8 + Math.sin(Date.now() * 0.008) * 0.2;
        ctx.strokeStyle = `rgba(33, 150, 243, ${pulseIntensity})`;
        ctx.lineWidth = 3;
        ctx.setLineDash([12, 6]);
        ctx.strokeRect(renderX - 5, renderY - 5, TUBE_WIDTH + 10, TUBE_HEIGHT + 10);
        ctx.setLineDash([]);
    }
    
    ctx.restore();
    
    // Define liquid container area (inside bottle body) - this moves with the bottle
    const liquidContainer = {
        x: bodyX + 5,
        y: bodyY + 5,
        width: bottleBodyWidth - 10,
        height: bottleBodyHeight - 10
    };
    
    // Draw liquid layers with enhanced physics and movement - liquid moves as one unit with bottle
    ctx.save();
    
    // Apply the same rotation to liquid as the bottle
    if (Math.abs(tiltAngle) > 0.001) {
        const centerX = renderX + TUBE_WIDTH / 2;
        const centerY = renderY + TUBE_HEIGHT / 2;
        ctx.translate(centerX, centerY);
        ctx.rotate(tiltAngle);
        ctx.translate(-centerX, -centerY);
    }
    
    // Universal liquid height calculation function
    // Ensures consistent height calculation across all rendering paths
    // Uses same calculation order as calculateTiltedLiquidHeight to avoid floating point differences
    function calculateLiquidHeight(layerCount, containerHeight) {
        return (layerCount / MAX_LAYERS) * containerHeight;
    }

    // Calculate single layer height
    function getLayerHeight(containerHeight) {
        return containerHeight / MAX_LAYERS;
    }

    // Simple function to adjust liquid height based on tilt
    function calculateTiltedLiquidHeight(liquidVolume, containerHeight, tiltAngle) {
        // Basic liquid height
        const baseHeight = liquidVolume * containerHeight;

        if (Math.abs(tiltAngle) < 0.001) {
            return baseHeight;
        }

        // Simple adjustment: liquid appears slightly higher when tilted
        // This simulates the visual effect of liquid shifting in a tilted container
        const tiltFactor = Math.abs(Math.sin(tiltAngle)) * 0.15; // 15% max adjustment
        const adjustment = baseHeight * tiltFactor;

        // Return adjusted height (liquid rises slightly when tilted)
        return Math.min(containerHeight, baseHeight + adjustment);
    }

    // Calculate dynamic liquid levels during pouring animation
    let liquidLevels = [...tube];
    let animatedTotalLiquidHeight = null;

    // Find animation that involves this tube (for liquid level calculations)
    const liquidAnim = pourAnimations.find(anim => anim.from === tubeIndex || anim.to === tubeIndex);

    // Use animation logic with snapshots during ENTIRE animation (game state already updated)
    if (liquidAnim) {
        const totalProgress = Math.min(1, liquidAnim.progress / liquidAnim.duration);
        const { phase } = getCurrentPhase(totalProgress);

        if (liquidAnim.from === tubeIndex) {
            // Source tube - ALWAYS use initial snapshot during animation
            liquidLevels = [...liquidAnim.snapshots.snapshot_sourceInitial];

            // During POUR/RETURN phases: animate liquid level going DOWN
            if (phase.name === 'POUR' || phase.name === 'RETURN') {
                const currentLayers = liquidAnim.visual_sourceLiquidLevel;
                const volumeRatio = currentLayers / MAX_LAYERS;
                animatedTotalLiquidHeight = calculateTiltedLiquidHeight(
                    volumeRatio,
                    liquidContainer.height,
                    tiltAngle
                );
            }

        } else if (liquidAnim.to === tubeIndex) {
            // Target tube - always show final colors during animation, control visibility via surface height
            // This prevents layer position shifts when switching between snapshots
            liquidLevels = [...liquidAnim.snapshots.snapshot_targetFinal];

            // Calculate animated liquid surface height using universal function
            const currentVisualLayers = liquidAnim.visual_targetLiquidLevel;
            animatedTotalLiquidHeight = calculateLiquidHeight(currentVisualLayers, liquidContainer.height);
        }
    }

    // For static tubes (no animation), also apply tilt adjustment if tilted
    if (animatedTotalLiquidHeight === null && Math.abs(tiltAngle) > 0.001) {
        const filledLayers = liquidLevels.filter(l => l !== null).length;
        const volumeRatio = filledLayers / MAX_LAYERS;
        animatedTotalLiquidHeight = calculateTiltedLiquidHeight(
            volumeRatio,
            liquidContainer.height,
            tiltAngle
        );
    }
    
    // Check if this tube is completed (single color only)
    const nonEmptyLayers = liquidLevels.filter(layer => layer !== null);
    const isCompletedTube = nonEmptyLayers.length > 0 &&
                           nonEmptyLayers.every(layer => layer === nonEmptyLayers[0]) &&
                           nonEmptyLayers.length === MAX_LAYERS;

    if (isCompletedTube) {
        // Render as single unified layer for completed tubes using WebGL
        const color = COLORS[nonEmptyLayers[0]];

        // Use animated height if available, otherwise full height
        let totalHeight;
        if (animatedTotalLiquidHeight !== null) {
            totalHeight = animatedTotalLiquidHeight;
        } else {
            totalHeight = liquidContainer.height;
        }

        const layerY = liquidContainer.y + liquidContainer.height - totalHeight;

        // Apply wobble effect if exists
        let wobbleOffset = 0;
        const wobbleEffect = liquidWobbleEffects.find(w => w.tubeIndex === tubeIndex);
        if (wobbleEffect) {
            wobbleOffset = Math.sin(wobbleEffect.life * 0.01) * wobbleEffect.amplitude;
        }

        // Calculate surface offset for tilt effect (for water surface rendering)
        let surfaceOffset = 0;
        if (Math.abs(tiltAngle) > 0.001) {
            surfaceOffset = Math.sin(tiltAngle) * liquidContainer.width * 0.2;
        }

        // World-space horizontal liquid level
        const bottleCenterX = renderX + TUBE_WIDTH / 2;
        const bottleCenterY = renderY + TUBE_HEIGHT / 2;

        // Offset to align liquid with tube shape (positive = down)
        const liquidYOffset = 7;

        // Liquid level is at the top of the liquid (layerY in canvas coordinates)
        const worldLiquidLevel = layerY + liquidYOffset;

        // Calculate surface tilt based on distance from liquid to bottle opening
        // Maximum tilt is when the edge exactly reaches bottle opening
        const distanceToTop = worldLiquidLevel - liquidContainer.y;
        const halfWidth = liquidContainer.width / 2;
        // Maximum allowed tilt slope (edge reaches bottle opening)
        const maxTiltSlope = distanceToTop / halfWidth;
        // Desired tilt based on bottle angle
        const desiredTilt = Math.sin(tiltAngle) * maxTiltSlope;
        // Clamp to max tilt so edge never exceeds bottle opening
        const surfaceTilt = Math.sign(desiredTilt) * Math.min(Math.abs(desiredTilt), maxTiltSlope);

        // Curved bottom parameters
        const curveHeightPixels = 25; // Matches tube rounded bottom

        // WEBGL LIQUID RENDERING (no upward extension)
        renderLiquidWithWebGL(
            liquidContainer.x,
            worldLiquidLevel,
            liquidContainer.width,
            totalHeight,
            color,
            worldLiquidLevel,
            wobbleOffset * 0.5,
            tiltAngle, // Pass actual tilt angle for rotation
            bottleCenterX,
            bottleCenterY,
            true, // Completed tube has only one layer, show surface effects
            surfaceTilt,
            curveHeightPixels
        );
        
        // Add enhanced bubble effects for completed tube
        if (Math.random() < 0.02) {
            const numBubbles = Math.floor(Math.random() * 2) + 1;
            for (let b = 0; b < numBubbles; b++) {
                const bubbleX = liquidContainer.x + 10 + Math.random() * (liquidContainer.width - 20);
                const bubbleY = layerY + 10 + Math.random() * (totalHeight - 20);
                const bubbleSize = Math.random() * 2.5 + 0.5;
                
                ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
                ctx.shadowColor = 'rgba(255, 255, 255, 0.5)';
                ctx.shadowBlur = 3;
                
                ctx.beginPath();
                ctx.arc(bubbleX, bubbleY, bubbleSize, 0, Math.PI * 2);
                ctx.fill();
                
                ctx.shadowBlur = 0;
            }
        }
        
    } else {
        // OPTIMIZED: Group consecutive same-color layers for merged rendering
        const liquidGroups = [];
        let currentGroup = null;

        for (let i = 0; i < MAX_LAYERS; i++) {
            if (liquidLevels[i] !== null) {
                if (currentGroup && currentGroup.color === liquidLevels[i]) {
                    // Same color as current group - extend it
                    currentGroup.endLayer = i;
                    currentGroup.count++;
                } else {
                    // New color - start new group
                    if (currentGroup) {
                        liquidGroups.push(currentGroup);
                    }
                    currentGroup = {
                        color: liquidLevels[i],
                        startLayer: i,
                        endLayer: i,
                        count: 1
                    };
                }
            }
        }
        // Push last group
        if (currentGroup) {
            liquidGroups.push(currentGroup);
        }

        // Render merged liquid groups FROM TOP TO BOTTOM for correct layering
        const layerHeight = getLayerHeight(liquidContainer.height);

        // Calculate total liquid height for clipping
        let totalLiquidHeight;
        if (animatedTotalLiquidHeight !== null) {
            totalLiquidHeight = animatedTotalLiquidHeight;
        } else {
            // No animation - calculate from actual liquid levels using universal function
            const filledLayers = liquidLevels.filter(l => l !== null).length;
            totalLiquidHeight = calculateLiquidHeight(filledLayers, liquidContainer.height);
        }

        // IMPORTANT: Render from TOP to BOTTOM (reverse order)
        // Each layer renders from its top Y all the way to the bottom of the bottle
        for (let groupIndex = liquidGroups.length - 1; groupIndex >= 0; groupIndex--) {
            const group = liquidGroups[groupIndex];
            const color = COLORS[group.color];

            // Calculate where this layer starts (top of the group)
            const groupTopY = liquidContainer.y + liquidContainer.height - (group.endLayer + 1) * layerHeight;

            // Calculate actual liquid surface position
            const liquidSurfaceY = liquidContainer.y + liquidContainer.height - totalLiquidHeight;

            // Use the liquid surface if it's lower than the group top
            const actualTopY = Math.max(groupTopY, liquidSurfaceY);

            // Skip if this group is completely above the liquid surface
            if (actualTopY >= liquidContainer.y + liquidContainer.height) {
                continue;
            }

            // Each layer renders from its top all the way to the bottom of the container
            // This ensures proper layering as upper layers cover lower ones
            const groupY = actualTopY;
            const groupHeight = liquidContainer.y + liquidContainer.height - actualTopY;

            // Check if this group contains the liquid surface
            // The top group is the one where the liquid surface falls within its range
            const isTopGroup = groupIndex === liquidGroups.length - 1 &&
                              Math.abs(actualTopY - liquidSurfaceY) < 1;

            // Apply wobble effect only to surface
            let wobbleOffset = 0;
            if (isTopGroup) {
                const wobbleEffect = liquidWobbleEffects.find(w => w.tubeIndex === tubeIndex);
                if (wobbleEffect) {
                    wobbleOffset = Math.sin(wobbleEffect.life * 0.01) * wobbleEffect.amplitude;
                }
            }

            // Calculate surface offset for tilt effect (applies to ALL liquid surfaces)
            let surfaceOffset = 0;
            if (Math.abs(tiltAngle) > 0.001) {
                // All liquid surfaces tilt at the same angle for realistic physics
                surfaceOffset = Math.sin(tiltAngle) * liquidContainer.width * 0.2;
            }

            // Skip rendering if group has no height
            if (groupHeight <= 0) continue;

            // WEBGL LIQUID RENDERING - Render entire group as one layer
            const bottleCenterX = renderX + TUBE_WIDTH / 2;
            const bottleCenterY = renderY + TUBE_HEIGHT / 2;

            // Pass the volume-adjusted liquid surface for accurate physics
            // For the top group, use the actual calculated surface position
            // For other groups, use their top position to create parallel surfaces
            let effectiveLiquidLevel;
            if (isTopGroup) {
                // Use the volume-conserved surface position
                effectiveLiquidLevel = liquidSurfaceY;
            } else {
                // Other groups use their top boundary for parallel surfaces
                effectiveLiquidLevel = groupY;
            }

            // Offset to align liquid with tube shape (positive = down)
            const liquidYOffset = 7;
            const adjustedGroupY = groupY + liquidYOffset;
            const adjustedLiquidLevel = effectiveLiquidLevel + liquidYOffset;

            // Calculate surface tilt for top group based on distance to bottle opening
            // Maximum tilt is when the edge exactly reaches bottle opening
            let surfaceTilt = 0;
            if (isTopGroup && Math.abs(tiltAngle) > 0.001) {
                const distanceToTop = adjustedLiquidLevel - liquidContainer.y;
                const halfWidth = liquidContainer.width / 2;
                // Maximum allowed tilt slope (edge reaches bottle opening)
                const maxTiltSlope = distanceToTop / halfWidth;
                // Desired tilt based on bottle angle
                const desiredTilt = Math.sin(tiltAngle) * maxTiltSlope;
                // Clamp to max tilt so edge never exceeds bottle opening
                surfaceTilt = Math.sign(desiredTilt) * Math.min(Math.abs(desiredTilt), maxTiltSlope);
            }

            // Curved bottom parameters - all layers need curve since they all extend to bottle bottom
            const curveHeightPixels = 25; // Matches tube rounded bottom

            renderLiquidWithWebGL(
                liquidContainer.x,
                adjustedGroupY,
                liquidContainer.width,
                groupHeight,
                color,
                adjustedLiquidLevel,
                wobbleOffset * 0.5,
                tiltAngle, // Pass actual tilt angle for rotation
                bottleCenterX,
                bottleCenterY,
                isTopGroup, // Only apply surface effects to top layer
                surfaceTilt,
                curveHeightPixels
            );

            // Bubble effects are now handled in the shader
            // Canvas 2D bubbles removed to avoid rendering on top of upper layers
        }
    }
    
    ctx.restore();
    
    // No visual effects for completed bottles - clean appearance only
}
        
        // Render pour animation
        // Render physics particles for all animations
        function renderPhysicsParticles() {
            if (pourAnimations.length === 0) return;

            pourAnimations.forEach(anim => {
                if (!anim.physicsParticles) return;

                anim.physicsParticles.forEach(particle => {
                    ctx.save();
                    ctx.globalAlpha = particle.opacity;

                    // Create liquid gradient for realistic appearance
                    const gradient = ctx.createRadialGradient(
                        particle.x, particle.y - particle.size * 0.3, 0,
                        particle.x, particle.y, particle.size
                    );
                    gradient.addColorStop(0, COLORS[particle.color] + 'FF');
                    gradient.addColorStop(0.7, COLORS[particle.color] + 'CC');
                    gradient.addColorStop(1, COLORS[particle.color] + '88');

                    ctx.fillStyle = gradient;

                    // Add glow effect
                    ctx.shadowColor = COLORS[particle.color];
                    ctx.shadowBlur = 6;

                    // Draw particle with slight deformation based on velocity
                    const speed = Math.sqrt(particle.vx * particle.vx + particle.vy * particle.vy);
                    const deformation = Math.min(speed * 0.1, 0.3);

                    ctx.beginPath();
                    ctx.ellipse(particle.x, particle.y, particle.size * (1 + deformation), particle.size * (1 - deformation * 0.5),
                               Math.atan2(particle.vy, particle.vx), 0, Math.PI * 2);
                    ctx.fill();

                    ctx.restore();
                });
            });
        }
        
        // Render pour animation with physics engine
        // Render all pour animations with realistic bottle movement and liquid stream
        function renderPourAnimation() {
            if (pourAnimations.length === 0) return;

            pourAnimations.forEach(anim => {
                const toPos = tubePositions[anim.to];
                const totalProgress = Math.min(1, anim.progress / anim.duration);

                // Render liquid stream only during active pouring (before untilt starts at 70%)
                if (totalProgress >= 0.30 && totalProgress < 0.70) {
                    // Calculate pour spout position (source bottle opening)
                    const rotationCenterX = anim.currentPos.x + TUBE_WIDTH / 2;
                    const rotationCenterY = anim.currentPos.y + TUBE_HEIGHT / 2;

                    const tiltSign = (anim.tiltDirection || 1) >= 0 ? 1 : -1;
                    const spoutRelativeX = tiltSign * POUR_STREAM_START_OFFSET_X;
                    const spoutRelativeY = POUR_STREAM_START_OFFSET_Y;

                    const startX = rotationCenterX + spoutRelativeX;
                    const startY = rotationCenterY + spoutRelativeY;

                    // Target position (near bottom of destination bottle interior)
                    const endX = toPos.x + TUBE_WIDTH / 2;
                    const endY = toPos.y + TUBE_HEIGHT - 25;

                    // Simple vertical water stream
                    ctx.save();
                    ctx.strokeStyle = COLORS[anim.color];
                    ctx.lineWidth = 8;
                    ctx.lineCap = 'round';
                    ctx.globalAlpha = 0.9;

                    ctx.beginPath();
                    ctx.moveTo(startX, startY);
                    ctx.lineTo(startX, endY);  // Vertical line
                    ctx.stroke();

                    ctx.restore();
                }
            });
        }
        
        // Main render function
        function render() {
            // Clear canvas
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Reset WebGL clear flag for this frame
            webglNeedsClear = true;

            // Determine which tubes should be rendered on top
            const topLayerTubes = new Set();

            // Add selected tube to top layer
            if (selectedTube !== null) {
                topLayerTubes.add(selectedTube);
            }

            // Add tubes involved in all pouring animations to top layer
            pourAnimations.forEach(anim => {
                topLayerTubes.add(anim.from);
                topLayerTubes.add(anim.to);
            });

            // Render tubes in two passes with separate WebGL flushes:
            // First pass: render all tubes except those in top layer
            tubePositions.forEach((pos, index) => {
                if (!topLayerTubes.has(index)) {
                    renderTube(index, pos.x, pos.y);
                }
            });

            // Flush background tubes' liquids to main canvas
            flushWebGLToCanvas();

            // Render pour stream between bottle background and liquid layers
            renderPourAnimation();

            // Reset WebGL clear flag before second pass
            webglNeedsClear = true;

            // Second pass: render tubes that should be on top layer
            topLayerTubes.forEach(index => {
                const pos = tubePositions[index];
                if (pos) {
                    renderTube(index, pos.x, pos.y);
                }
            });

            // Flush foreground tubes' liquids to main canvas
            // This ensures top layer liquids render on top of everything
            flushWebGLToCanvas();

            // Render sparkle effects
            renderSparkleEffects();
            
            // Render splash effects
            renderSplashEffects();

            // Update tutorial arrow position
            updateTutorialArrowPosition();

            // Victory popup is now HTML modal, no Canvas rendering needed
            // renderVictoryPopup();

            // Render game over popup (on top of everything)
            renderGameOverPopup();
            
            // Render game timer fail popup (on top of everything)
            renderGameTimerFailPopup();
            
            // Valid destination indicators removed for cleaner pouring experience
        }
        
        // Game loop
        function gameLoop(currentTime) {
    const deltaTime = currentTime - lastTime;
    lastTime = currentTime;

    // Update animations
    updatePourAnimation(deltaTime);
    updateSparkleEffects(deltaTime);
    updateSplashEffects(deltaTime);
    updateLiquidWobbleEffects(deltaTime);
    updateBottleShakeEffects(deltaTime);
    updateTubeLiftAnimations(deltaTime);

    // Update hint cooldown
    updateHintCooldown(deltaTime);
    
    // Update game timer
    updateGameTimer(deltaTime);
    
    // Render
    render();

    requestAnimationFrame(gameLoop);
}
        
        // Handle input
        function handleInput(x, y) {
            // Check timer fail popup first
            if (handleGameTimerFailPopupClick(x, y)) {
                return;
            }
            
            // Check game over popup
            if (handleGameOverPopupClick(x, y)) {
                return;
            }
            
            // Victory popup is now HTML modal with button event handlers
            // if (handleVictoryPopupClick(x, y)) {
            //     return;
            // }
            
            if (gameMode === 'edit') {
                handleEditInput(x, y);
            } else {
                handlePlayInput(x, y);
            }
        }
        
        // Handle play mode input (supports parallel pouring)
        function handlePlayInput(x, y) {
            const tubeIndex = getTubeAtPosition(x, y);

            if (tubeIndex === -1) {
                // Clicked empty space - deselect
                if (selectedTube !== -1 && isTubeAvailable(selectedTube)) {
                    startTubeLiftAnimation(selectedTube, 0); // Lower previously selected tube
                }
                selectedTube = -1;
                hintDestinationTube = -1;
                return;
            }

            // Block interaction with tubes currently involved in pouring
            if (!isTubeAvailable(tubeIndex)) {
                return;
            }

            // Tutorial logic - guide player through first pour (non-blocking)
            // Tutorial only provides visual guidance, does not block any clicks
            if (tutorialActive) {
                if (tutorialStep === 0 && selectedTube === -1) {
                    // Player selected a source tube - advance tutorial
                    tutorialStep = 1;
                    // Point arrow to a valid destination (find first tube that can receive)
                    const sourceTube = tubes[tubeIndex];
                    let sourceTopColor = null;
                    for (let i = MAX_LAYERS - 1; i >= 0; i--) {
                        if (sourceTube[i] !== null) {
                            sourceTopColor = sourceTube[i];
                            break;
                        }
                    }
                    // Find a valid destination tube
                    tutorialTargetTube = -1;
                    for (let i = 0; i < tubes.length; i++) {
                        if (i !== tubeIndex && canPour(tubeIndex, i)) {
                            tutorialTargetTube = i;
                            break;
                        }
                    }
                }
                // Tutorial continues with normal gameplay below
            }

            // Normal gameplay (non-tutorial)
            if (selectedTube === -1) {
                // Select source tube and show how many layers will pour
                const sourceTube = tubes[tubeIndex];
                let sourceTopIndex = -1;
                for (let i = MAX_LAYERS - 1; i >= 0; i--) {
                    if (sourceTube[i] !== null) {
                        sourceTopIndex = i;
                        break;
                    }
                }

                if (sourceTopIndex !== -1) {
                    selectedTube = tubeIndex;
                    startTubeLiftAnimation(tubeIndex, -50); // Lift selected tube
                    hintDestinationTube = -1; // Clear hint when selecting manually
                } else {
                    // Empty tube - no feedback needed
                }
            } else if (selectedTube === tubeIndex) {
                // Clicked same tube - deselect
                startTubeLiftAnimation(tubeIndex, 0); // Lower deselected tube
                selectedTube = -1;
                hintDestinationTube = -1;
            } else {
                // Check if destination is already receiving liquid from another pour
                if (isTubeDestination(tubeIndex)) {
                    // Cannot pour into a tube that's already receiving liquid
                    // Select this tube as new source instead
                    const oldSelectedTube = selectedTube;
                    if (isTubeAvailable(oldSelectedTube)) {
                        startTubeLiftAnimation(oldSelectedTube, 0);
                    }
                    selectedTube = tubeIndex;
                    startTubeLiftAnimation(tubeIndex, -50);
                    hintDestinationTube = -1;
                    return;
                }

                // Try to pour
                if (pourLiquid(selectedTube, tubeIndex)) {
                    startTubeLiftAnimation(selectedTube, 0); // Lower source tube after pour
                    selectedTube = -1;
                    hintDestinationTube = -1;

                    // Complete tutorial after first successful pour
                    if (tutorialActive) {
                        completeTutorial();
                    }

                    // Check for game over after a short delay to allow animation to start
                    setTimeout(() => {
                        checkGameOver();
                    }, 1000);
                } else {
                    // Invalid move - select new tube
                    const oldSelectedTube = selectedTube;
                    startTubeLiftAnimation(oldSelectedTube, 0); // Lower old tube
                    selectedTube = tubeIndex;
                    startTubeLiftAnimation(tubeIndex, -50); // Lift new tube
                    hintDestinationTube = -1; // Clear hint when selecting manually
                    // Check for game over immediately since no move was made
                    checkGameOver();
                }
            }
        }
        
        // Handle edit mode input
        function handleEditInput(x, y) {
            const tubeIndex = getTubeAtPosition(x, y);
            if (tubeIndex === -1) return;
            
            const layerIndex = getLayerAtPosition(tubeIndex, x, y);
            if (layerIndex === -1) return;
            
            // Cycle through colors
            const currentColor = tubes[tubeIndex][layerIndex];
            let nextColorIndex = 0;
            
            if (currentColor !== null) {
                const currentIndex = COLOR_NAMES.indexOf(currentColor);
                nextColorIndex = (currentIndex + 1) % (COLOR_NAMES.length + 1);
            }
            
            // Set new color (or null for empty)
            tubes[tubeIndex][layerIndex] = nextColorIndex < COLOR_NAMES.length ? COLOR_NAMES[nextColorIndex] : null;
            
            // Update game config
            window.gameConfig.tubes = JSON.parse(JSON.stringify(tubes));
            
            // Color changed - no feedback needed
        }
        
        // Setup event listeners
        function setupEventListeners() {
            // Track if touch was used to prevent duplicate click events
            let touchHandled = false;
            let touchTimeout = null;

            // Canvas events
            canvas.addEventListener('click', (e) => {
                // Skip click if touch was just handled (prevents double firing on touch devices)
                if (touchHandled) {
                    touchHandled = false;
                    return;
                }

                const rect = canvas.getBoundingClientRect();
                const scaleX = canvas.width / rect.width;
                const scaleY = canvas.height / rect.height;
                const x = (e.clientX - rect.left) * scaleX;
                const y = (e.clientY - rect.top) * scaleY;

                handleInput(x, y);
            });

            // Improved touch handling for immediate response
            canvas.addEventListener('touchstart', (e) => {
                e.preventDefault(); // Prevent default touch behavior (scrolling, zooming)

                // Mark that touch was handled to prevent duplicate click
                touchHandled = true;
                if (touchTimeout) clearTimeout(touchTimeout);
                touchTimeout = setTimeout(() => { touchHandled = false; }, 500);

                const rect = canvas.getBoundingClientRect();
                const scaleX = canvas.width / rect.width;
                const scaleY = canvas.height / rect.height;
                const touch = e.touches[0];
                const x = (touch.clientX - rect.left) * scaleX;
                const y = (touch.clientY - rect.top) * scaleY;

                // Log for debugging
                // console.log('[Touch] Immediate touchstart at:', x, y, 'Time:', Date.now());

                // Handle input immediately on touchstart (not waiting for touchend)
                handleInput(x, y);
            });

            // Add touchend to complete the touch gesture handling
            canvas.addEventListener('touchend', (e) => {
                e.preventDefault(); // Prevent mouse event emulation
                // console.log('[Touch] touchend event, Time:', Date.now());
            });

            // Prevent context menu on long press
            canvas.addEventListener('contextmenu', (e) => {
                e.preventDefault();
                return false;
            });
            
            // Mobile UI events
            document.getElementById('menuButton').addEventListener('click', () => {
                MobileUI.provideTouchFeedback(document.getElementById('menuButton'));
                MobileUI.toggleDrawer();
            });
            
            document.getElementById('closeDrawer').addEventListener('click', () => {
                MobileUI.closeDrawer();
            });
            
            document.getElementById('drawerBackdrop').addEventListener('click', () => {
                MobileUI.closeDrawer();
            });
            
            // Action bar buttons
            document.getElementById('undoBtn').addEventListener('click', (e) => {
                MobileUI.provideTouchFeedback(e.target);
                undoMove();
            });
            
            document.getElementById('restartBtn').addEventListener('click', (e) => {
                MobileUI.provideTouchFeedback(e.target);
                restartLevel();
            });
            
            document.getElementById('hintBtn').addEventListener('click', (e) => {
                if (!hintCooldownActive) {
                    MobileUI.provideTouchFeedback(e.target);
                }
                provideHint();
            });
            
            // Drawer buttons
            document.getElementById('addTubeBtn').addEventListener('click', () => {
                if (tubes.length < 8) {
                    const newTube = [null, null, null, null];
                    tubes.push(newTube);
                    window.gameConfig.tubes.push(newTube);
                    tubePositions = calculateTubePositions(tubes.length);
                }
            });
            
            document.getElementById('removeTubeBtn').addEventListener('click', () => {
                if (tubes.length > 3) {
                    tubes.pop();
                    window.gameConfig.tubes.pop();
                    tubePositions = calculateTubePositions(tubes.length);
                    if (selectedTube >= tubes.length) {
                        selectedTube = -1;
                    }
                }
            });
            
            document.getElementById('clearAllBtn').addEventListener('click', () => {
                tubes.forEach(tube => {
                    for (let i = 0; i < MAX_LAYERS; i++) {
                        tube[i] = null;
                    }
                });
                window.gameConfig.tubes = JSON.parse(JSON.stringify(tubes));
                selectedTube = -1;
                hintDestinationTube = -1;
            });
            
            document.getElementById('testPuzzleBtn').addEventListener('click', () => {
                gameMode = 'play';
                selectedTube = -1;
                hintDestinationTube = -1;
                
                MobileUI.updateEditVisibility();
                MobileUI.closeDrawer();
            });
            
            // Settings buttons
            document.getElementById('soundToggle').addEventListener('click', (e) => {
                if (audioManager) {
                    soundEnabled = audioManager.toggleSound();
                    e.target.innerHTML = `<span>🔊</span> Sound: ${soundEnabled ? 'On' : 'Off'}`;
                }
            });

            document.getElementById('musicToggle').addEventListener('click', (e) => {
                if (audioManager) {
                    musicEnabled = audioManager.toggleMusic();
                    e.target.innerHTML = `<span>🎵</span> Music: ${musicEnabled ? 'On' : 'Off'}`;
                }
            });

            document.getElementById('vibrationToggle').addEventListener('click', (e) => {
                vibrationEnabled = !vibrationEnabled;
                e.target.innerHTML = `<span>📳</span> Vibration: ${vibrationEnabled ? 'On' : 'Off'}`;
            });

            // Level navigation
            // Back to menu button
            document.getElementById('levelSelectBtn').addEventListener('click', () => {
                MobileUI.closeDrawer();
                levelManager.backToMenu();
            });

            // Victory modal buttons
            document.getElementById('victoryMenuBtn').addEventListener('click', () => {
                // Hide victory modal and dark overlay
                const modal = document.getElementById('victoryModal');
                const darkOverlay = document.getElementById('victoryDarkOverlay');
                if (modal) modal.classList.remove('show');
                if (darkOverlay) darkOverlay.classList.remove('show');

                // Stop confetti
                stopConfetti();

                // Go back to main menu
                levelManager.backToMenu();
            });

            document.getElementById('victoryNextBtn').addEventListener('click', () => {
                // Hide victory modal and dark overlay
                const modal = document.getElementById('victoryModal');
                const darkOverlay = document.getElementById('victoryDarkOverlay');
                if (modal) modal.classList.remove('show');
                if (darkOverlay) darkOverlay.classList.remove('show');

                // Stop confetti
                stopConfetti();

                // Move to next level
                const nextLevelIndex = levelManager.currentLevelIndex + 1;
                if (nextLevelIndex < levelManager.levels.length) {
                    const nextLevel = levelManager.levels[nextLevelIndex];
                    if (nextLevel.unlocked) {
                        levelManager.selectLevel(nextLevelIndex);
                    } else {
                        // If next level is locked, go back to menu
                        levelManager.backToMenu();
                    }
                } else {
                    // No more levels, go back to menu
                    levelManager.backToMenu();
                }
            });

            // Game Over modal buttons
            document.getElementById('gameOverMenuBtn').addEventListener('click', () => {
                const modal = document.getElementById('gameOverModal');
                if (modal) {
                    modal.classList.remove('show');
                    modal.style.display = 'none';
                }
                levelManager.backToMenu();
            });

            document.getElementById('gameOverRetryBtn').addEventListener('click', () => {
                const modal = document.getElementById('gameOverModal');
                if (modal) {
                    modal.classList.remove('show');
                    modal.style.display = 'none';
                }
                restartLevel();
            });

            // Time's Up modal buttons
            document.getElementById('timeUpMenuBtn').addEventListener('click', () => {
                const modal = document.getElementById('timeUpModal');
                if (modal) {
                    modal.classList.remove('show');
                    modal.style.display = 'none';
                }
                gameTimerFailed = false;
                levelManager.backToMenu();
            });

            document.getElementById('timeUpRetryBtn').addEventListener('click', () => {
                const modal = document.getElementById('timeUpModal');
                if (modal) {
                    modal.classList.remove('show');
                    modal.style.display = 'none';
                }
                gameTimerFailed = false;
                restartLevel();
            });

            // Debug: Press R to reset and show tutorial, Press Q to force show tutorial
            document.addEventListener('keydown', async (e) => {
                if (e.key === 'q' || e.key === 'Q') {
                    if (gameMode === 'play') {
                        // Direct DOM test - bypass all logic
                        const container = document.getElementById('tutorialContainer');
                        const bubble = document.getElementById('tutorialHintBubble');
                        const arrow = document.getElementById('tutorialArrow');

                        if (!container) {
                            alert('ERROR: tutorialContainer not found!');
                            return;
                        }

                        // Force show at center of screen for testing
                        container.style.display = 'block';

                        bubble.style.position = 'fixed';
                        bubble.style.left = '50%';
                        bubble.style.top = '200px';

                        arrow.style.position = 'fixed';
                        arrow.style.left = '50%';
                        arrow.style.top = '260px';

                        alert('Elements found! Check screen for arrow.');
                    }
                }
                if (e.key === 'r' || e.key === 'R') {
                    if (gameMode === 'play') {
                        // Reset tutorial completion
                        try {
                            const userData = await window.lib.getUserGameState();
                            const currentState = userData.state || {};
                            delete currentState.tutorialCompleted;
                            await window.lib.saveUserGameState(currentState);
                            alert('Tutorial reset! Refresh the page to see it.');
                        } catch (error) {
                            console.error('[Tutorial] Failed to reset:', error);
                        }
                    }
                }
                if (e.key === 't' || e.key === 'T') {
                    if (gameMode === 'play') {
                        // Test: Show game over (no moves) modal
                        showGameOverPopup();
                    }
                }
                if (e.key === 'o' || e.key === 'O') {
                    if (gameMode === 'play') {
                        // Test: Show time's up modal
                        showGameTimerFailPopup();
                    }
                }
                if (e.key === 'p' || e.key === 'P') {
                    if (gameMode === 'play') {
                        // Simulate level completion with 3 stars
                        levelCompletionTime = Date.now();
                        stopGameTimer();

                        const timeUsed = 1000; // Fast completion = 3 stars

                        // Create score data for debug completion
                        const debugScoreData = {
                            stars: 3,
                            score: 1000,
                            stepScore: 700,
                            timeScore: 300,
                            stepBreakdown: { actual: stepCount, optimal: 8, diff: 0 },
                            timeBreakdown: { actual: 1, target: 45, diff: 0 }
                        };

                        // Save progress
                        levelManager.completeLevel(debugScoreData);

                        // Play victory sound
                        if (audioManager) {
                            audioManager.playSound('victory_fanfare');
                        }

                        // Show victory popup immediately
                        setTimeout(() => {
                            showVictoryPopup(debugScoreData, timeUsed, stepCount);
                        }, 200);

                        console.log('[DEBUG] Level completed with 3 stars (P key pressed)');
                    }
                }
                if (e.key === 'm' || e.key === 'M') {
                    // Debug: Clear user game state data only
                    try {
                        // Clear user game state via lib API
                        if (window.lib && window.lib.deleteUserGameState) {
                            await window.lib.deleteUserGameState();
                            console.log('[DEBUG] User game state deleted via lib API');
                            alert('User game state cleared!\n\nRefresh the page to start fresh.');
                        } else {
                            alert('lib.deleteUserGameState API not available');
                        }
                        console.log('[DEBUG] User game state cleared (M key pressed)');
                    } catch (error) {
                        console.error('[DEBUG] Failed to clear user game state:', error);
                        alert('Failed to clear user game state: ' + error.message);
                    }
                }
            });
        }
        
        function run(mode) {
            lib.log('run() called. Mode: ' + mode);
            gameMode = mode;
            
            // Show game parameters UI
            lib.showGameParameters({
                name: 'Liquid Sort Settings',
                params: {
                    'Current Level': {
                        key: 'gameConfig.currentLevel',
                        type: 'number',
                        min: 1,
                        max: 10,
                        step: 1,
                        onChange: (value) => {
                            window.gameConfig.currentLevel = value.toString();
                            currentLevel = parseInt(value);
                            document.getElementById('levelInfo').textContent = `Level ${value}`;
                            
                            // Generate new puzzle for the new level
                            restartLevel();
                        }
                    },
                    'Number of Tubes': {
                        key: 'gameConfig.tubes.length',
                        type: 'slider',
                        min: 3,
                        max: 8,
                        step: 1,
                        onChange: (value) => {
                            // Adjust tube count
                            while (tubes.length < value) {
                                const newTube = [null, null, null, null];
                                tubes.push(newTube);
                                window.gameConfig.tubes.push(newTube);
                            }
                            while (tubes.length > value) {
                                tubes.pop();
                                window.gameConfig.tubes.pop();
                            }
                            tubePositions = calculateTubePositions(tubes.length);
                            
                            // Physics will be handled automatically
                        }
                    }
                }
            });
            
            // Initialize level manager
            levelManager.init();

            // Initialize display and assets
            initializeDisplay();
            preloadAssets();
            
            // Initialize game state
            initializeGameState();
            
            // If in play mode, ensure we have a proper puzzle for the current level
            if (mode === 'play') {
                // Always generate a fresh puzzle when starting the game
                restartLevel();
            }
            
            // Initialize physics engine
            initializePhysics();
            
            // Setup controls
            setupEventListeners();
            
            // Update UI for current mode
            MobileUI.updateEditVisibility();
            
            // In play mode, don't start timer yet - wait for level selection
            if (mode === 'play') {
                // Timer will start when a level is selected from menu
                stopGameTimer();
            } else {
                stopGameTimer();
            }
            
            // Start background music in play mode
            if (mode === 'play' && audioManager && musicEnabled) {
                audioManager.playMusic();
            }
            
            // Update level display
            document.getElementById('levelInfo').textContent = `Level ${currentLevel}`;
            
            // Game started - no welcome message needed
            
            // Start game loop
            lastTime = performance.now();
            requestAnimationFrame(gameLoop);
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
