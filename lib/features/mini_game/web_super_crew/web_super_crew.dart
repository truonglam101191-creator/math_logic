import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSuperCrew extends StatefulWidget {
  const WebSuperCrew({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebSuperCrew> createState() => _WebSuperCrewState();
}

class _WebSuperCrewState extends State<WebSuperCrew> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

  late final perferen = Shared.instance.sharedPreferences;

  final _kSavedGameStateKey = 'super_crew_saved_game_state';

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
          'assets/super_crew/super_crew.html',
        );

        final config = await rootBundle.loadString(
          'assets/super_crew/config.json',
        );

        html = html.replaceAll('<style id="gameStyle"></style>', style);

        if (config.isNotEmpty) {
          html = html.replaceAll(
            '<script id="gameConfig"></script>',
            '<script id="gameConfig"> window.gameConfig = $config;</script>',
          );
        }

        html = html.replaceAll(
          '<script id="assetsMap" type="application/json"></script>',
          assets,
        );

        html = html.replaceAll('<script id="logic"></script>', config);

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
        /* ===== Splash Screen CSS Start ===== */
        #splash {
            position: fixed;
            inset: 0;
            background: linear-gradient(135deg, #161533 0%, #1e1a3d 50%, #161533 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 999999;
            user-select: none;
            -webkit-user-select: none;
        }

        #splash.hidden {
            opacity: 0;
            pointer-events: none;
            transition: opacity 420ms ease;
        }

        #splash .splash-inner {
            opacity: 0;
            transition: opacity 180ms ease;
        }

        #splash.fonts-ready .splash-inner {
            opacity: 1;
        }

        .splash-inner {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 40px;
        }

        .splash-spinner {
            width: 112px;
            height: 112px;
            border: 8px solid rgba(255, 255, 255, 0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: splash-spin 0.9s linear infinite;
        }

        @keyframes splash-spin {
            to {
                transform: rotate(360deg);
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .splash-spinner {
                animation: none !important;
            }

            #splash.hidden {
                transition: none;
            }
        }

        .splash-loading-text {
            color: #fff;
            font-size: 40px;
            font-weight: 600;
            letter-spacing: 1px;
        }

        .splash-percent {
            color: rgba(255, 255, 255, 0.9);
            font-size: 36px;
            font-weight: 600;
        }

        /* ===== Splash Screen CSS End ===== */

        /* ===== Home Screen (首屏) CSS Start ===== */
        #home-screen {
            position: fixed;
            inset: 0;
            z-index: 999998;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #1a1a2e;
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            opacity: 0;
            pointer-events: none;
            transition: opacity 400ms ease;
        }

        #home-screen.visible {
            opacity: 1;
            pointer-events: auto;
        }

        #home-screen .home-inner {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 48px;
        }

        #home-screen .btn-start {
            position: relative;
            margin-top: 300px;
            font-family: 'Nunito', sans-serif;
            font-size: 106px;
            font-weight: 800;
            width: 450px;
            height: 450px;
            padding: 0;
            border-radius: 50%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 4px;
            color: #fff;
            background: transparent;
            border: none;
            overflow: visible;
            cursor: pointer;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.6);
            transition: transform 0.25s ease;
            animation: btn-start-pulse 2s ease-in-out infinite;
        }

        #home-screen .btn-start::before {
            content: '';
            position: absolute;
            inset: 0;
            border-radius: 50%;
            background-image: var(--btn-bg-url, none);
            background-size: contain;
            background-position: center;
            background-repeat: no-repeat;
            opacity: 0.93;
            z-index: 0;
            pointer-events: none;
        }

        #home-screen .btn-start .btn-start-text,
        #home-screen .btn-start .btn-hand {
            position: relative;
            z-index: 1;
            opacity: 1;
        }

        #home-screen .btn-start:hover {
            transform: scale(1.05);
            animation: none;
        }

        #home-screen .btn-start:active {
            transform: scale(0.95);
        }

        #home-screen .btn-start .btn-hand {
            position: absolute;
            bottom: 50px;
            right: -38px;
            font-size: 144px;
            line-height: 1;
            pointer-events: none;
            transition: transform 0.15s ease;
            transform-origin: center center;
            transform: rotate(-30deg);
            filter: brightness(0) invert(1) drop-shadow(0 2px 4px rgba(0, 0, 0, 0.5));
            animation: btn-hand-tap 2s ease-in-out infinite;
        }

        #home-screen .btn-start:hover .btn-hand {
            animation: none;
            transform: rotate(-30deg) translate(0, 0) scale(1);
        }

        #home-screen .btn-start:active .btn-hand {
            animation: none;
            transform: rotate(-30deg) translate(-8px, -8px) scale(0.85);
        }

        @keyframes btn-hand-tap {

            0%,
            100% {
                transform: rotate(-30deg) translate(0, 0) scale(1);
            }

            45% {
                transform: rotate(-30deg) translate(0, 0) scale(1.02);
            }

            50% {
                transform: rotate(-30deg) translate(-6px, -6px) scale(0.95);
            }

            55% {
                transform: rotate(-30deg) translate(0, 0) scale(1.02);
            }
        }

        @keyframes btn-start-pulse {

            0%,
            100% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.03);
            }
        }

        @media (prefers-reduced-motion: reduce) {
            #home-screen .btn-start {
                animation: none;
            }

            #home-screen .btn-start .btn-hand {
                animation: none;
            }
        }

        /* ===== Home Screen CSS End ===== */

        :root {
            --bg-gradient-top: #E8F4F8;
            --bg-gradient-bottom: #FFFFFF;
            --board-color: #F5F1E8;
            --hole-color: #3A3A3A;
            --valid-highlight: #A8E063;
            --invalid-highlight: #E74C3C;
            --text-dark: #2C3E50;
            --text-light: #7F8C8D;
            --button-bg: #FFFFFF;
            --button-shadow: rgba(0, 0, 0, 0.1);

            --transition-fast: 150ms;
            --transition-normal: 300ms;
            --transition-slow: 500ms;
            --ease-out: cubic-bezier(0.0, 0, 0.2, 1);
            --ease-bounce: cubic-bezier(0.68, -0.6, 0.32, 1.6);

            --space-xs: 8px;
            --space-sm: 16px;
            --space-md: 24px;
            --space-lg: 32px;
            --space-xl: 48px;
        }

        body,
        html {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            touch-action: none;
            -ms-touch-action: none;
            font-family: 'Nunito', sans-serif;
            background: #1a1a2e;
        }

        #game-container {
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        /* Top UI Bar */
        .top-bar {
            width: 100%;
            padding: var(--space-md) var(--space-lg);
            box-sizing: border-box;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 10;
            position: relative;
        }

        .topbar-icon-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background: rgba(255, 255, 255, 0.15);
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            width: 88px;
            height: 88px;
            font-size: 44px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background var(--transition-fast), transform var(--transition-fast);
            padding: 0;
            line-height: 1;
        }

        .topbar-icon-btn:hover {
            background: rgba(255, 255, 255, 0.25);
        }

        .topbar-icon-btn:active {
            transform: translateY(-50%) scale(0.9);
        }

        #btn-settings {
            left: var(--space-lg);
        }

        .topbar-right-btns {
            position: absolute;
            right: var(--space-lg);
            top: 50%;
            transform: translateY(-44px);
            /* 44px = 半按钮高度，使排行榜与设置按钮 y 对齐 */
            display: flex;
            flex-direction: column;
            gap: var(--space-sm);
            align-items: center;
        }

        .topbar-right-btns .topbar-icon-btn {
            position: static;
            transform: none;
        }

        .topbar-right-btns .topbar-icon-btn:active {
            transform: scale(0.9);
        }

        /* Settings Overlay & Panel */
        .settings-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 100;
            opacity: 0;
            pointer-events: none;
            transition: opacity var(--transition-normal) var(--ease-out);
        }

        .settings-overlay.visible {
            opacity: 1;
            pointer-events: auto;
        }

        .settings-panel {
            background: white;
            border-radius: 24px;
            padding: 36px 40px;
            min-width: 380px;
            max-width: 85%;
            text-align: center;
            transform: scale(0.9);
            transition: transform var(--transition-normal) var(--ease-bounce);
        }

        .settings-overlay.visible .settings-panel {
            transform: scale(1);
        }

        .settings-title {
            font-size: 44px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 28px;
        }

        .settings-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 0;
            border-bottom: 2px solid #f0f0f0;
        }

        .settings-row:last-of-type {
            border-bottom: none;
        }

        .settings-label {
            font-size: 30px;
            font-weight: 600;
            color: var(--text-dark);
        }

        /* Toggle Switch */
        .toggle-switch {
            width: 72px;
            height: 40px;
            background: #ccc;
            border-radius: 20px;
            position: relative;
            cursor: pointer;
            transition: background 0.25s ease;
            flex-shrink: 0;
        }

        .toggle-switch.on {
            background: #56AB2F;
        }

        .toggle-knob {
            position: absolute;
            top: 4px;
            left: 4px;
            width: 32px;
            height: 32px;
            background: white;
            border-radius: 50%;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
            transition: left 0.25s ease;
        }

        .toggle-switch.on .toggle-knob {
            left: 36px;
        }

        .level-display {
            font-size: 72px;
            font-weight: 800;
            color: var(--text-dark);
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }

        .moves-display {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-dark);
            background: var(--button-bg);
            padding: var(--space-sm) var(--space-md);
            border-radius: 24px;
            box-shadow: 0 2px 8px var(--button-shadow);
            min-width: 140px;
            text-align: center;
            transition: background var(--transition-normal) var(--ease-out),
                color var(--transition-normal) var(--ease-out);
        }

        .moves-display.warning {
            background: #FFF3E0;
            color: #E65100;
        }

        .moves-display.critical {
            background: #FFEBEE;
            color: #C62828;
            animation: pulse-warning 1s ease-in-out infinite;
        }

        @keyframes pulse-warning {

            0%,
            100% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.05);
            }
        }

        /* Game Canvas */
        #game-canvas {
            flex: 1;
            max-width: 100%;
            touch-action: none;
        }

        /* Bottom UI Bar */
        .bottom-bar {
            width: 100%;
            padding: var(--space-md) var(--space-lg) var(--space-xl);
            box-sizing: border-box;
            display: flex;
            justify-content: center;
            gap: var(--space-lg);
            z-index: 10;
        }

        .ui-button {
            width: 96px;
            height: 96px;
            border-radius: 50%;
            background: var(--button-bg);
            border: none;
            box-shadow: 0 4px 12px var(--button-shadow);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform var(--transition-fast) var(--ease-out),
                box-shadow var(--transition-fast) var(--ease-out),
                background var(--transition-fast) var(--ease-out);
        }

        .ui-button:hover {
            background: #F8F8F8;
            box-shadow: 0 6px 16px var(--button-shadow);
        }

        .ui-button:active {
            transform: scale(0.92);
            box-shadow: 0 2px 6px var(--button-shadow);
            background: #F0F0F0;
        }

        .ui-button:focus-visible {
            outline: 3px solid var(--valid-highlight);
            outline-offset: 2px;
        }

        .ui-button img {
            width: 44px;
            height: 44px;
            object-fit: contain;
        }

        /* 锤子和提示按钮：第一关隐藏，第二关弹出 */
        .bottom-tool-btn.hidden-below {
            transform: translateY(200px);
            opacity: 0;
            pointer-events: none;
        }

        .bottom-tool-btn.slide-up {
            animation: slideUpIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
        }

        @keyframes slideUpIn {
            from {
                transform: translateY(200px);
                opacity: 0;
            }

            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .hammer-icon {
            font-size: 44px;
            line-height: 1;
        }

        .hammer-wrapper {
            position: relative;
        }

        .hammer-countdown {
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            margin-bottom: 6px;
            font-size: 22px;
            font-weight: 700;
            color: #FFD54F;
            text-align: center;
            white-space: nowrap;
            display: none;
        }

        .hammer-countdown.visible {
            display: block;
        }

        #btn-hammer {
            position: relative;
        }

        #btn-hammer.active {
            background: #FFD54F;
            box-shadow: 0 0 16px rgba(255, 213, 79, 0.6), 0 4px 12px var(--button-shadow);
            animation: hammer-pulse 1s ease-in-out infinite;
        }

        #btn-hammer.disabled {
            opacity: 0.45;
            pointer-events: none;
        }

        @keyframes hammer-pulse {

            0%,
            100% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.08);
            }
        }

        .hammer-badge {
            position: absolute;
            top: -12px;
            right: -12px;
            min-width: 45px;
            height: 45px;
            line-height: 45px;
            border-radius: 23px;
            background: #FF5252;
            color: #fff;
            font-size: 30px;
            font-weight: 700;
            text-align: center;
            padding: 0 6px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }

        .hammer-tip {
            position: absolute;
            bottom: calc(100% + 18px);
            left: 50%;
            transform: translateX(-50%);
            white-space: nowrap;
            background: rgba(0, 0, 0, 0.85);
            color: #fff;
            font-size: 28px;
            font-weight: 600;
            line-height: 1.4;
            padding: 20px 32px;
            border-radius: 16px;
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.4);
            pointer-events: auto;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.3s ease;
            z-index: 100;
        }

        .hammer-tip.visible {
            opacity: 1;
        }

        .hammer-tip b {
            color: #FFD54F;
        }

        .hammer-tip-arrow {
            position: absolute;
            bottom: -11px;
            left: 50%;
            transform: translateX(-50%);
            width: 0;
            height: 0;
            border-left: 12px solid transparent;
            border-right: 12px solid transparent;
            border-top: 12px solid rgba(0, 0, 0, 0.85);
        }

        /* Overlay Screens */
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 100;
            opacity: 0;
            pointer-events: none;
            transition: opacity var(--transition-normal) var(--ease-out);
        }

        /* 新手教程全屏遮罩 */
        #tutorial-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 50;
            pointer-events: none;
            display: none;
            /* 使用 radial-gradient 作为 mask 来镂空圆形区域 */
            -webkit-mask-image: radial-gradient(circle 60px at 50% 50%, transparent 100%, black 100%);
            mask-image: radial-gradient(circle 60px at 50% 50%, transparent 100%, black 100%);
        }

        #tutorial-overlay.active {
            display: block;
        }

        /* 教程手指 & 文字容器（在遮罩之上） */
        #tutorial-hand-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 0;
            height: 0;
            z-index: 51;
            pointer-events: none;
            display: none;
        }

        #tutorial-hand-container.active {
            display: block;
        }

        #tutorial-hand {
            position: absolute;
            font-size: 100px;
            line-height: 1;
            transform: translate(-50%, 0);
            filter: drop-shadow(0 2px 6px rgba(0, 0, 0, 0.5));
        }

        #tutorial-text {
            position: absolute;
            font-family: 'Poppins', sans-serif;
            font-size: 40px;
            font-weight: 700;
            color: #FFFFFF;
            text-shadow: 0 1px 4px rgba(0, 0, 0, 0.8), 0 0 10px rgba(255, 215, 0, 0.6);
            white-space: nowrap;
            transform: translate(-50%, 0);
        }

        .overlay.visible {
            opacity: 1;
            pointer-events: auto;
        }

        /* 死关锤子提示条 */
        .dead-hint-banner {
            position: fixed;
            left: 50%;
            top: 40px;
            transform: translateX(-50%);
            z-index: 60;
            padding: 28px 48px;
            background: linear-gradient(135deg, #E65100 0%, #BF360C 100%);
            color: #fff;
            font-size: 32px;
            font-weight: 800;
            font-family: 'Nunito', sans-serif;
            border-radius: 24px;
            box-shadow: 0 6px 32px rgba(230, 81, 0, 0.5);
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s ease;
            max-width: 90vw;
            text-align: center;
        }

        .dead-hint-banner.visible {
            opacity: 1;
        }

        .overlay-content {
            background: white;
            border-radius: 24px;
            padding: var(--space-xl);
            text-align: center;
            transform: scale(0.9);
            transition: transform var(--transition-normal) var(--ease-bounce);
            max-width: 80%;
            position: relative;
            z-index: 1;
        }

        .overlay.visible .overlay-content {
            transform: scale(1);
        }

        .overlay-title {
            font-size: 44px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: var(--space-md);
            line-height: 1.2;
        }

        .overlay-subtitle {
            font-size: 26px;
            font-weight: 600;
            color: var(--text-light);
            margin-bottom: var(--space-lg);
            line-height: 1.4;
        }

        .overlay-button {
            background: linear-gradient(135deg, #A8E063 0%, #56AB2F 100%);
            color: white;
            border: none;
            padding: var(--space-md) var(--space-xl);
            font-size: 28px;
            font-weight: 700;
            border-radius: 32px;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(86, 171, 47, 0.4);
            transition: transform var(--transition-fast) var(--ease-out),
                box-shadow var(--transition-fast) var(--ease-out);
            font-family: 'Nunito', sans-serif;
            min-width: 200px;
            min-height: 64px;
        }

        .overlay-button:hover {
            box-shadow: 0 6px 20px rgba(86, 171, 47, 0.5);
        }

        .overlay-button:active {
            transform: scale(0.95);
            box-shadow: 0 2px 10px rgba(86, 171, 47, 0.4);
        }

        .overlay-button:focus-visible {
            outline: 3px solid white;
            outline-offset: 2px;
        }

        .victory-title {
            color: #56AB2F;
        }

        .victory-praise {
            font-size: 2.2rem;
            font-weight: 800;
            letter-spacing: 0.05em;
            margin: 0.4em 0 0.2em;
            color: #FFD700;
            animation: victory-praise-pulse 1.2s ease-in-out infinite;
        }

        @keyframes victory-praise-pulse {

            0%,
            100% {
                transform: scale(1);
                opacity: 1;
            }

            50% {
                transform: scale(1.05);
                opacity: 0.95;
            }
        }

        /* Victory overlay 容纳双按钮，增加最小高度 */
        #victory-overlay .overlay-content {
            min-height: 280px;
        }

        #victory-overlay .victory-buttons {
            display: flex;
            flex-direction: column;
            gap: var(--space-md);
            margin-top: var(--space-md);
            width: 100%;
        }

        /* 胜利弹窗重玩按钮：蓝色，与 Next Level 区分 */
        .overlay-button.replay {
            background: linear-gradient(135deg, #3498DB 0%, #2874A6 100%);
            box-shadow: 0 4px 15px rgba(52, 152, 219, 0.4);
        }

        .overlay-button.replay:hover {
            box-shadow: 0 6px 20px rgba(52, 152, 219, 0.5);
        }

        .overlay-button.replay:active {
            box-shadow: 0 2px 10px rgba(52, 152, 219, 0.4);
        }

        /* 胜利彩带容器 */
        #victory-confetti-container {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: visible;
            pointer-events: none;
            z-index: 0;
        }

        .victory-confetti {
            position: absolute;
            pointer-events: none;
            will-change: transform;
        }

        /* Edit Mode Indicator / Toolbar */
        .edit-indicator {
            position: absolute;
            top: 100px;
            left: 50%;
            transform: translateX(-50%);
            background: #3498DB;
            color: white;
            padding: var(--space-xs) var(--space-md);
            border-radius: 20px;
            font-size: 18px;
            font-weight: 600;
            z-index: 50;
            display: none;
            align-items: center;
            gap: 12px;
            white-space: nowrap;
        }

        .edit-indicator.visible {
            display: flex;
        }

        /* Unscrew Progress Ring */
        .progress-ring {
            position: absolute;
            pointer-events: none;
            z-index: 20;
        }

        /* Leaderboard Styles */
        .button-group {
            display: flex;
            gap: var(--space-md);
            margin-top: var(--space-md);
            flex-wrap: wrap;
            justify-content: center;
        }

        .overlay-button.secondary {
            background: linear-gradient(135deg, #3498DB 0%, #2874A6 100%);
            box-shadow: 0 4px 15px rgba(52, 152, 219, 0.4);
        }

        .overlay-button.secondary:hover {
            box-shadow: 0 6px 20px rgba(52, 152, 219, 0.5);
        }

        .overlay-button.secondary:active {
            box-shadow: 0 2px 10px rgba(52, 152, 219, 0.4);
        }

        .leaderboard-container {
            max-height: 500px;
            overflow-y: auto;
            margin-top: var(--space-md);
        }

        /* Level Select Overlay */
        #level-select-overlay .overlay-content {
            max-height: 85vh;
            display: flex;
            flex-direction: column;
            min-width: 360px;
            max-width: 90%;
        }

        .level-select-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: var(--space-md);
            overflow-y: auto;
            padding: var(--space-sm);
            margin-top: var(--space-md);
            max-height: 60vh;
        }

        .level-select-btn {
            aspect-ratio: 1;
            border: 4px solid rgba(0, 0, 0, 0.2);
            border-radius: 16px;
            font-size: 24px;
            font-weight: 700;
            font-family: 'Nunito', sans-serif;
            cursor: pointer;
            background: linear-gradient(135deg, #A8E063 0%, #56AB2F 100%);
            color: white;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
            transition: transform var(--transition-fast), box-shadow var(--transition-fast);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .level-select-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .level-select-btn:active {
            transform: scale(0.98);
        }

        .level-select-btn.current {
            border-color: #F39C12;
            box-shadow: 0 0 0 3px rgba(243, 156, 18, 0.5);
        }

        .level-select-btn.locked {
            background: linear-gradient(135deg, #BDC3C7 0%, #95A5A6 100%);
            color: rgba(255, 255, 255, 0.8);
            cursor: not-allowed;
            pointer-events: none;
        }

        .leaderboard-entry {
            display: flex;
            align-items: center;
            padding: var(--space-sm) var(--space-md);
            background: #F8F9FA;
            border-radius: 12px;
            margin-bottom: var(--space-sm);
            gap: var(--space-md);
        }

        .leaderboard-entry.user-entry {
            background: linear-gradient(135deg, #E8F5E9 0%, #C8E6C9 100%);
            border: 2px solid #66BB6A;
        }

        .leaderboard-rank {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-dark);
            min-width: 50px;
            text-align: center;
        }

        .leaderboard-rank.gold {
            color: #FFD700;
        }

        .leaderboard-rank.silver {
            color: #C0C0C0;
        }

        .leaderboard-rank.bronze {
            color: #CD7F32;
        }

        .leaderboard-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            object-fit: cover;
            background: #DDD;
        }

        .leaderboard-info {
            flex: 1;
            text-align: left;
        }

        .leaderboard-name {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 2px;
        }

        .leaderboard-score {
            font-size: 32px;
            font-weight: 800;
            color: #56AB2F;
            min-width: 100px;
            text-align: right;
        }

        .user-rank-display {
            font-size: 24px;
            font-weight: 600;
            color: var(--text-light);
            margin-top: var(--space-sm);
            padding: var(--space-sm);
            background: #F0F0F0;
            border-radius: 8px;
        }

        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {

            .overlay-content,
            .ui-button,
            .overlay-button,
            .moves-display {
                transition: none;
            }

            .moves-display.critical {
                animation: none;
            }
        }
    </style>
  ''';

  String get config => '''    <script id="gameConfig">
        window.gameConfig = {
            "currentLevel": 4,
            "screwBoltRadius": 21,
            "screwAnim": {
                "unscrewDuration": 200,
                "unscrewRotation": 720,
                "unscrewLift": 30,
                "screwInDuration": 150,
                "screwInRotation": 720,
                "screwInDrop": 30,
                "screwMoveDuration": 300,
                "screwIdleSwing": 8,
                "screwIdleDelay": 500,
                "emptyHoleHitScale": 2
            },
            "playArea": {
                "x": 0,
                "y": 160,
                "w": 720,
                "h": 1030
            },
            "parts": [
                {
                    "id": "part_circle_150",
                    "shapeType": "circle",
                    "partImgName": "part_metal_small",
                    "w": 225,
                    "h": 75
                },
                {
                    "id": "part_blue_box_450_150",
                    "shapeType": "square",
                    "partImgName": "part_wood_medium",
                    "w": 375,
                    "h": 75
                },
                {
                    "id": "part_green_box_450_150",
                    "shapeType": "square",
                    "partImgName": "part_plastic_red_small",
                    "w": 150,
                    "h": 150
                },
                {
                    "id": "part_brown_L_300_300",
                    "shapeType": "square",
                    "partImgName": "part_plastic_green_small",
                    "w": 75,
                    "h": 75
                },
                {
                    "id": "part_new_1",
                    "shapeType": "square",
                    "partImgName": "part_new_1",
                    "w": 225,
                    "h": 75
                },
                {
                    "id": "part_new_1g",
                    "shapeType": "square",
                    "partImgName": "part_new_1g",
                    "w": 225,
                    "h": 75
                },
                {
                    "id": "part_new_1r",
                    "shapeType": "square",
                    "partImgName": "part_new_1_1r",
                    "w": 225,
                    "h": 75
                },
                {
                    "id": "part_new_2",
                    "shapeType": "square",
                    "partImgName": "part_new_2",
                    "w": 375,
                    "h": 75
                },
                {
                    "id": "part_new_2g",
                    "shapeType": "square",
                    "partImgName": "part_new_2g",
                    "w": 375,
                    "h": 75
                },
                {
                    "id": "part_new_2r",
                    "shapeType": "square",
                    "partImgName": "part_new_2r",
                    "w": 375,
                    "h": 75
                },
                {
                    "id": "part_new_3",
                    "shapeType": "square",
                    "partImgName": "part_new_3",
                    "w": 75,
                    "h": 75
                },
                {
                    "id": "part_new_3g",
                    "shapeType": "square",
                    "partImgName": "part_new_3g",
                    "w": 75,
                    "h": 75
                },
                {
                    "id": "part_new_3r",
                    "shapeType": "square",
                    "partImgName": "part_new_3r",
                    "w": 75,
                    "h": 75
                },
                {
                    "id": "part_new_4",
                    "shapeType": "square",
                    "partImgName": "part_new_4",
                    "w": 150,
                    "h": 150
                },
                {
                    "id": "part_new_4g",
                    "shapeType": "square",
                    "partImgName": "part_new_4g",
                    "w": 150,
                    "h": 150
                },
                {
                    "id": "part_new_4r",
                    "shapeType": "square",
                    "partImgName": "part_new_4r",
                    "w": 150,
                    "h": 150
                },
                {
                    "id": "part_new_5",
                    "shapeType": "square",
                    "partImgName": "part_new_5",
                    "w": 525,
                    "h": 75
                },
                {
                    "id": "part_new_5g",
                    "shapeType": "square",
                    "partImgName": "part_new_5g",
                    "w": 525,
                    "h": 75
                },
                {
                    "id": "part_new_5r",
                    "shapeType": "square",
                    "partImgName": "part_new_5r",
                    "w": 525,
                    "h": 75
                },
                {
                    "id": "part_new_6",
                    "shapeType": "square",
                    "partImgName": "part_new_6",
                    "w": 150,
                    "h": 150
                },
                {
                    "id": "part_new_6g",
                    "shapeType": "square",
                    "partImgName": "part_new_6g",
                    "w": 150,
                    "h": 150
                },
                {
                    "id": "part_new_6r",
                    "shapeType": "square",
                    "partImgName": "part_new_6r",
                    "w": 150,
                    "h": 150
                },
                {
                    "id": "part_new_7",
                    "shapeType": "square",
                    "partImgName": "part_new_7g",
                    "w": 525,
                    "h": 75
                },
                {
                    "id": "part_new_8r",
                    "shapeType": "square",
                    "partImgName": "part_new_8r",
                    "w": 225,
                    "h": 75
                },
                {
                    "id": "part_new_9r",
                    "shapeType": "square",
                    "partImgName": "part_new_9r",
                    "w": 375,
                    "h": 75
                },
                {
                    "id": "part_new_10",
                    "shapeType": "square",
                    "partImgName": "part_new_10",
                    "w": 375,
                    "h": 75
                }
            ],
            "levels": [
                {
                    "id": "level_1",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_blue_box_450_150",
                                    "x": 357,
                                    "y": 315,
                                    "rotation": 0
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 352,
                            "y": 462,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 207,
                            "y": 315,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 507,
                            "y": 315,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_2",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_2",
                                    "x": 440,
                                    "y": 343,
                                    "rotation": 60
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_2",
                                    "x": 365,
                                    "y": 473,
                                    "rotation": 0
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 520,
                            "y": 473,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 215,
                            "y": 473,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 366,
                            "y": 212,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 380,
                            "y": 719,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_3",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 290,
                                    "y": 440,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 440,
                                    "y": 260,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": []
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 520,
                            "y": 260,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 370,
                            "y": 260,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 370,
                            "y": 440,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 220,
                            "y": 440,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 377,
                            "y": 640,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_4",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 350,
                                    "y": 350,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 462,
                                    "y": 312,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 238,
                                    "y": 312,
                                    "rotation": 180
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 296,
                            "y": 570,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 420,
                            "y": 570,
                            "type": "empty"
                        },
                        {
                            "id": "hole_4",
                            "x": 425,
                            "y": 350,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 275,
                            "y": 350,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 502,
                            "y": 273,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 203,
                            "y": 273,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_5",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_9r",
                                    "x": 350,
                                    "y": 350,
                                    "rotation": 45
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_9r",
                                    "x": 350,
                                    "y": 350,
                                    "rotation": 315
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 300,
                            "y": 700,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 400,
                            "y": 700,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 350,
                            "y": 350,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 455,
                            "y": 245,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 245,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 245,
                            "y": 245,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 455,
                            "y": 450,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_6",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_blue_box_450_150",
                                    "x": 355,
                                    "y": 405,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_blue_box_450_150",
                                    "x": 355,
                                    "y": 405,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_4",
                            "x": 358,
                            "y": 695,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 355,
                            "y": 255,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 355,
                            "y": 555,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 505,
                            "y": 405,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 205,
                            "y": 405,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_7",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 290,
                                    "y": 412,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 440,
                                    "y": 260,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 365,
                                    "y": 335,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 520,
                            "y": 260,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 370,
                            "y": 260,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 370,
                            "y": 410,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 220,
                            "y": 410,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 356,
                            "y": 577,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_8",
                    "layers": [
                        {
                            "id": "layer_1",
                            "parts": [
                                {
                                    "partId": "part_blue_box_450_150",
                                    "x": 350,
                                    "y": 450,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_blue_box_450_150",
                                    "x": 350,
                                    "y": 300,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "parts": [
                                {
                                    "partId": "part_circle_150",
                                    "x": 200,
                                    "y": 375,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 500,
                                    "y": 375,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 200,
                            "y": 300,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 500,
                            "y": 300,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 500,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 200,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 267,
                            "y": 556,
                            "type": "empty"
                        },
                        {
                            "id": "hole_6",
                            "x": 398,
                            "y": 556,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_9",
                    "layers": [
                        {
                            "id": "layer_1",
                            "parts": [
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 335,
                                    "y": 315,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "parts": [
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 334,
                                    "y": 390,
                                    "rotation": 270
                                },
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 335,
                                    "y": 240,
                                    "rotation": 270
                                }
                            ],
                            "zIndex": 1
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 335,
                                    "y": 465,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_4",
                            "zIndex": 3,
                            "parts": [
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 335,
                                    "y": 540,
                                    "rotation": 270
                                }
                            ]
                        },
                        {
                            "id": "layer_",
                            "zIndex": 4,
                            "parts": [
                                {
                                    "partId": "part_green_box_450_150",
                                    "x": 335,
                                    "y": 615,
                                    "rotation": 0
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 308,
                            "y": 755,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 377,
                            "y": 756,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 300,
                            "y": 577,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 298,
                            "y": 427,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 298,
                            "y": 277,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 373,
                            "y": 652,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_13",
                            "x": 373,
                            "y": 352,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_14",
                            "x": 373,
                            "y": 502,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_15",
                            "x": 375,
                            "y": 202,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_10",
                    "layers": [
                        {
                            "id": "layer_3",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_circle_150",
                                    "x": 190,
                                    "y": 183,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 488,
                                    "y": 183,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 190,
                                    "y": 633,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 488,
                                    "y": 633,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_4",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_circle_150",
                                    "x": 117,
                                    "y": 258,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 117,
                                    "y": 558,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 563,
                                    "y": 258,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 563,
                                    "y": 558,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_5",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_circle_150",
                                    "x": 338,
                                    "y": 183,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 338,
                                    "y": 633,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 117,
                                    "y": 408,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_circle_150",
                                    "x": 563,
                                    "y": 408,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 331,
                            "y": 773,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 117,
                            "y": 182,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 117,
                            "y": 332,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 117,
                            "y": 633,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 263,
                            "y": 633,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 414,
                            "y": 633,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 563,
                            "y": 633,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 563,
                            "y": 483,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 563,
                            "y": 332,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_12",
                            "x": 563,
                            "y": 182,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_13",
                            "x": 414,
                            "y": 182,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_14",
                            "x": 263,
                            "y": 182,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_15",
                            "x": 400,
                            "y": 772,
                            "type": "empty"
                        },
                        {
                            "id": "hole_16",
                            "x": 117,
                            "y": 483,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_11",
                    "layers": [
                        {
                            "id": "layer_1",
                            "parts": [
                                {
                                    "partId": "part_new_7",
                                    "x": 342,
                                    "y": 480,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_8r",
                                    "x": 341,
                                    "y": 218,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_3",
                                    "x": 336,
                                    "y": 395,
                                    "rotation": 0
                                }
                            ],
                            "zIndex": 2
                        },
                        {
                            "id": "layer_2",
                            "parts": [
                                {
                                    "partId": "part_new_7",
                                    "x": 266,
                                    "y": 349,
                                    "rotation": 120
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_7",
                                    "x": 416,
                                    "y": 349,
                                    "rotation": 240
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 310,
                            "y": 688,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 266,
                            "y": 216,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 341,
                            "y": 216,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 416,
                            "y": 216,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 336,
                            "y": 394,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 494,
                            "y": 479,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 191,
                            "y": 479,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 372,
                            "y": 688,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_12",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_7",
                                    "x": 344,
                                    "y": 609,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_4",
                                    "x": 350,
                                    "y": 375,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_7",
                                    "x": 120,
                                    "y": 386,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_7",
                                    "x": 570,
                                    "y": 386,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_new_4r",
                                    "x": 534,
                                    "y": 198,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_4r",
                                    "x": 532,
                                    "y": 572,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_4r",
                                    "x": 156,
                                    "y": 572,
                                    "rotation": 180
                                },
                                {
                                    "partId": "part_new_4r",
                                    "x": 157,
                                    "y": 198,
                                    "rotation": 270
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 120,
                            "y": 533,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 193,
                            "y": 533,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 193,
                            "y": 611,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 195,
                            "y": 161,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 120,
                            "y": 233,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 195,
                            "y": 233,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 495,
                            "y": 160,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 495,
                            "y": 233,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 570,
                            "y": 233,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 495,
                            "y": 533,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 570,
                            "y": 533,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_12",
                            "x": 495,
                            "y": 609,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_13",
                            "x": 313,
                            "y": 336,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_14",
                            "x": 312,
                            "y": 410,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_15",
                            "x": 387,
                            "y": 411,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_16",
                            "x": 262,
                            "y": 771,
                            "type": "empty"
                        },
                        {
                            "id": "hole_17",
                            "x": 378,
                            "y": 770,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_13",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_9r",
                                    "x": 170,
                                    "y": 365,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 430,
                                    "y": 515,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_2",
                                    "x": 300,
                                    "y": 288,
                                    "rotation": 30
                                },
                                {
                                    "partId": "part_new_2",
                                    "x": 300,
                                    "y": 589,
                                    "rotation": 30
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 300,
                                    "y": 440,
                                    "rotation": 30
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_new_9r",
                                    "x": 300,
                                    "y": 438,
                                    "rotation": 330
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 170,
                            "y": 213,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 170,
                            "y": 365,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 169,
                            "y": 512,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 431,
                            "y": 361,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 430,
                            "y": 517,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 430,
                            "y": 663,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 299,
                            "y": 786,
                            "type": "empty"
                        },
                        {
                            "id": "hole_8",
                            "x": 303,
                            "y": 437,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 362,
                            "y": 785,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_14",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_10",
                                    "x": 334,
                                    "y": 466,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_10",
                                    "x": 334,
                                    "y": 167,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_2g",
                                    "x": 334,
                                    "y": 315,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 410,
                                    "y": 615,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_10",
                                    "x": 186,
                                    "y": 316,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_10",
                                    "x": 484,
                                    "y": 316,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_2",
                                    "x": 334,
                                    "y": 316,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1g",
                                    "x": 484,
                                    "y": 540,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 484,
                            "y": 166,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 484,
                            "y": 314,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 484,
                            "y": 465,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 484,
                            "y": 614,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 335,
                            "y": 614,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 335,
                            "y": 465,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 334,
                            "y": 165,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 186,
                            "y": 165,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 183,
                            "y": 313,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 184,
                            "y": 465,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 219,
                            "y": 739,
                            "type": "empty"
                        },
                        {
                            "id": "hole_12",
                            "x": 331,
                            "y": 739,
                            "type": "empty"
                        },
                        {
                            "id": "hole_13",
                            "x": 438,
                            "y": 739,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_15",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_7",
                                    "x": 338,
                                    "y": 620,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_7",
                                    "x": 338,
                                    "y": 168,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 414,
                                    "y": 316,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 414,
                                    "y": 469,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_5",
                                    "x": 188,
                                    "y": 394,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 488,
                                    "y": 242,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 488,
                                    "y": 546,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 339,
                                    "y": 392,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": []
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 188,
                            "y": 167,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_2",
                            "x": 190,
                            "y": 618,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 489,
                            "y": 167,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 489,
                            "y": 316,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 338,
                            "y": 316,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 338,
                            "y": 466,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 488,
                            "y": 468,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 488,
                            "y": 620,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 258,
                            "y": 325,
                            "type": "empty"
                        },
                        {
                            "id": "hole_10",
                            "x": 259,
                            "y": 434,
                            "type": "empty"
                        }
                    ]
                },
                {
                    "id": "level_16",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_2",
                                    "x": 335,
                                    "y": 183,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_2",
                                    "x": 335,
                                    "y": 633,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 335,
                                    "y": 332,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 335,
                                    "y": 482,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_1g",
                                    "x": 186,
                                    "y": 257,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1g",
                                    "x": 487,
                                    "y": 257,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1g",
                                    "x": 335,
                                    "y": 407,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1g",
                                    "x": 186,
                                    "y": 556,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1g",
                                    "x": 483,
                                    "y": 558,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 263,
                            "y": 739,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 366,
                            "y": 739,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 487,
                            "y": 183,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 187,
                            "y": 183,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 187,
                            "y": 332,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 334,
                            "y": 332,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 487,
                            "y": 332,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 187,
                            "y": 484,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 334,
                            "y": 484,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 487,
                            "y": 484,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 187,
                            "y": 632,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_12",
                            "x": 487,
                            "y": 632,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_17",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 165,
                                    "y": 180,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 500,
                                    "y": 179,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 165,
                                    "y": 330,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 500,
                                    "y": 330,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 335,
                                    "y": 481,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_2",
                                    "x": 336,
                                    "y": 611,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_1r",
                                    "x": 90,
                                    "y": 255,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 240,
                                    "y": 255,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 425,
                                    "y": 255,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 575,
                                    "y": 255,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 447,
                                    "y": 546,
                                    "rotation": 60
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 224,
                                    "y": 546,
                                    "rotation": 300
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 272,
                            "y": 750,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 387,
                            "y": 750,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 90,
                            "y": 179,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 90,
                            "y": 330,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 240,
                            "y": 330,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 240,
                            "y": 179,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 425,
                            "y": 179,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 425,
                            "y": 330,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 575,
                            "y": 330,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 575,
                            "y": 179,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 261,
                            "y": 480,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_12",
                            "x": 409,
                            "y": 480,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_13",
                            "x": 185,
                            "y": 610,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_14",
                            "x": 484,
                            "y": 610,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_18",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_1g",
                                    "x": 225,
                                    "y": 160,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1g",
                                    "x": 225,
                                    "y": 310,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 300,
                                    "y": 460,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 300,
                                    "y": 610,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 300,
                                    "y": 760,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 150,
                                    "y": 235,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 150,
                                    "y": 535,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 450,
                                    "y": 535,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 300,
                                    "y": 685,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 300,
                                    "y": 310,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 455,
                            "y": 155,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 455,
                            "y": 310,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 150,
                            "y": 160,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 300,
                            "y": 160,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 300,
                            "y": 310,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 150,
                            "y": 310,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 300,
                            "y": 460,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 150,
                            "y": 460,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 450,
                            "y": 460,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 450,
                            "y": 610,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 450,
                            "y": 760,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_12",
                            "x": 300,
                            "y": 610,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_13",
                            "x": 150,
                            "y": 610,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_14",
                            "x": 300,
                            "y": 760,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_15",
                            "x": 150,
                            "y": 760,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_19",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 345,
                                    "y": 165,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 345,
                                    "y": 315,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 345,
                                    "y": 465,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_9r",
                                    "x": 270,
                                    "y": 315,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 420,
                                    "y": 315,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_new_9r",
                                    "x": 270,
                                    "y": 465,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 270,
                                    "y": 615,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_4",
                            "zIndex": 3,
                            "parts": [
                                {
                                    "partId": "part_new_8r",
                                    "x": 120,
                                    "y": 540,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_8r",
                                    "x": 420,
                                    "y": 540,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 200,
                            "y": 745,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 300,
                            "y": 745,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 400,
                            "y": 745,
                            "type": "empty"
                        },
                        {
                            "id": "hole_4",
                            "x": 420,
                            "y": 165,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 270,
                            "y": 165,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 270,
                            "y": 315,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 420,
                            "y": 315,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 120,
                            "y": 465,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 270,
                            "y": 465,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 420,
                            "y": 465,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 120,
                            "y": 540,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_12",
                            "x": 420,
                            "y": 540,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_13",
                            "x": 120,
                            "y": 615,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_14",
                            "x": 270,
                            "y": 615,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_15",
                            "x": 420,
                            "y": 615,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_20",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 150,
                                    "y": 150,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 150,
                                    "y": 300,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 150,
                                    "y": 450,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 150,
                                    "y": 600,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 150,
                                    "y": 750,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 545,
                                    "y": 750,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 545,
                                    "y": 600,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 545,
                                    "y": 450,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 545,
                                    "y": 300,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 545,
                                    "y": 150,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_1r",
                                    "x": 225,
                                    "y": 225,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 470,
                                    "y": 225,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 75,
                                    "y": 675,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 620,
                                    "y": 675,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_new_1r",
                                    "x": 225,
                                    "y": 375,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 420,
                                    "y": 354,
                                    "rotation": 313
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 75,
                                    "y": 525,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 620,
                                    "y": 525,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_4",
                            "zIndex": 3,
                            "parts": [
                                {
                                    "partId": "part_new_1r",
                                    "x": 75,
                                    "y": 375,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 620,
                                    "y": 375,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 298,
                                    "y": 431,
                                    "rotation": 345
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 470,
                                    "y": 375,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_5",
                            "zIndex": 4,
                            "parts": [
                                {
                                    "partId": "part_new_1r",
                                    "x": 75,
                                    "y": 225,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 225,
                                    "y": 525,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 470,
                                    "y": 525,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 620,
                                    "y": 225,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_6",
                            "zIndex": 5,
                            "parts": [
                                {
                                    "partId": "part_new_1r",
                                    "x": 225,
                                    "y": 675,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_1r",
                                    "x": 470,
                                    "y": 675,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 338,
                            "y": 760,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 75,
                            "y": 150,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 75,
                            "y": 300,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 75,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 75,
                            "y": 600,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 75,
                            "y": 750,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 225,
                            "y": 150,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 225,
                            "y": 300,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 225,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 225,
                            "y": 600,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 225,
                            "y": 750,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_12",
                            "x": 365,
                            "y": 410,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_13",
                            "x": 475,
                            "y": 150,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_14",
                            "x": 470,
                            "y": 300,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_15",
                            "x": 470,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_16",
                            "x": 470,
                            "y": 600,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_17",
                            "x": 470,
                            "y": 750,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_18",
                            "x": 620,
                            "y": 150,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_19",
                            "x": 620,
                            "y": 300,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_20",
                            "x": 620,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_21",
                            "x": 620,
                            "y": 600,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_22",
                            "x": 620,
                            "y": 750,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_21",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_2",
                                    "x": 375,
                                    "y": 600,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_7",
                                    "x": 375,
                                    "y": 150,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_2r",
                                    "x": 225,
                                    "y": 300,
                                    "rotation": 90
                                },
                                {
                                    "partId": "part_new_2r",
                                    "x": 525,
                                    "y": 300,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 300,
                                    "y": 450,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 525,
                                    "y": 525,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_4",
                            "zIndex": 3,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 450,
                                    "y": 450,
                                    "rotation": 0
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 225,
                                    "y": 525,
                                    "rotation": 90
                                }
                            ]
                        },
                        {
                            "id": "layer_5",
                            "zIndex": 4,
                            "parts": [
                                {
                                    "partId": "part_new_8r",
                                    "x": 375,
                                    "y": 450,
                                    "rotation": 90
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 286,
                            "y": 772,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 433,
                            "y": 769,
                            "type": "empty"
                        },
                        {
                            "id": "hole_3",
                            "x": 525,
                            "y": 600,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 225,
                            "y": 600,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 225,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 225,
                            "y": 150,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 525,
                            "y": 150,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 525,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 375,
                            "y": 375,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 377,
                            "y": 450,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 375,
                            "y": 525,
                            "type": "bolt"
                        }
                    ]
                },
                {
                    "id": "level_22",
                    "layers": [
                        {
                            "id": "layer_1",
                            "zIndex": 0,
                            "parts": [
                                {
                                    "partId": "part_new_9r",
                                    "x": 243,
                                    "y": 291,
                                    "rotation": 282
                                },
                                {
                                    "partId": "part_new_9r",
                                    "x": 457,
                                    "y": 291,
                                    "rotation": 78
                                },
                                {
                                    "partId": "part_new_1",
                                    "x": 338,
                                    "y": 568,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_2",
                            "zIndex": 1,
                            "parts": [
                                {
                                    "partId": "part_new_1",
                                    "x": 350,
                                    "y": 145,
                                    "rotation": 0
                                }
                            ]
                        },
                        {
                            "id": "layer_3",
                            "zIndex": 2,
                            "parts": [
                                {
                                    "partId": "part_new_1g",
                                    "x": 295,
                                    "y": 345,
                                    "rotation": 45
                                }
                            ]
                        },
                        {
                            "id": "layer_4",
                            "zIndex": 3,
                            "parts": [
                                {
                                    "partId": "part_new_1g",
                                    "x": 402,
                                    "y": 345,
                                    "rotation": 315
                                },
                                {
                                    "partId": "part_new_1g",
                                    "x": 450,
                                    "y": 502,
                                    "rotation": 300
                                }
                            ]
                        }
                    ],
                    "holes": [
                        {
                            "id": "hole_1",
                            "x": 338,
                            "y": 800,
                            "type": "empty"
                        },
                        {
                            "id": "hole_2",
                            "x": 280,
                            "y": 141,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_3",
                            "x": 243,
                            "y": 288,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_4",
                            "x": 350,
                            "y": 395,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_5",
                            "x": 458,
                            "y": 288,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_6",
                            "x": 494,
                            "y": 434,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_7",
                            "x": 415,
                            "y": 565,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_8",
                            "x": 430,
                            "y": 142,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_9",
                            "x": 266,
                            "y": 565,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_10",
                            "x": 212,
                            "y": 434,
                            "type": "bolt"
                        },
                        {
                            "id": "hole_11",
                            "x": 410,
                            "y": 799,
                            "type": "empty"
                        }
                    ]
                }
            ],
            "_editor": {
                "subMode": "level",
                "currentPart": "",
                "levelNum": 5,
                "currentLayer": "1",
                "visibleLayers": [
                    "layer_6",
                    "layer_5",
                    "layer_4",
                    "layer_3",
                    "layer_2",
                    "layer_1"
                ],
                "_deleteLayerAction": "__none__",
                "brushType": "hole",
                "placingPartId": "__none__",
                "placingHoleType": "bolt"
            }
        }
    </script>
    ''';
  String get assets => '''    <script id="assetsMap" type="application/json">
       {
  "robot_screw_king": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_115111021931251906261/1770893281469_01KH8QE25XV886TJKH18A2RSXH.SeaTalk_IMG_20260212_180107.png",
    "type": "image"
  },
  "bolt_hex_head": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/0e947f36-9383-4185-85c6-e3c35f5bdd13.webp",
    "type": "image",
    "aspect_ratio": [
      861,
      809
    ]
  },
  "bolt_shaft_threaded": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/0e01acde-df8c-4c26-a449-e34d3e4fef19.webp",
    "type": "image",
    "aspect_ratio": [
      289,
      858
    ]
  },
  "part_metal_small": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770627427913_01KH0SWVJ9TT2TA1WN5DR7X5C8.part_1_1.png",
    "type": "image"
  },
  "part_wood_medium": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770628978205_01KH0VC5GX4XCWB8SPGE5A6MAR.part_3_3.png",
    "type": "image"
  },
  "part_plastic_red_small": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770629868392_01KH0W7AV85DSC798FB2R0MRDJ.part_4_3.png",
    "type": "image"
  },
  "part_plastic_blue_small": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/054bf3ef-edf5-4ec5-8373-263d310f7c3c.webp",
    "type": "image",
    "aspect_ratio": [
      1024,
      856
    ]
  },
  "part_plastic_green_small": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770628519579_01KH0TY5MVNG096QRH2DH1ADP7.part_2_4.png",
    "type": "image"
  },
  "icon_restart": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/cb5b3ca8-f314-4fa1-b99f-0b79e2e9787f.webp",
    "type": "image",
    "aspect_ratio": [
      694,
      695
    ]
  },
  "icon_hint": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/1365b1ea-05eb-4b69-ac93-6783b97fa624.webp",
    "type": "image",
    "aspect_ratio": [
      575,
      843
    ]
  },
  "icon_undo": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/33852468-7d0c-468e-8998-ab03955f5fdb.webp",
    "type": "image",
    "aspect_ratio": [
      584,
      597
    ]
  },
  "sfx_unscrew_ratchet": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/a9fd5cec-1be5-406b-9e8f-58ee572845dd.mp3",
    "type": "audio"
  },
  "sfx_bolt_place": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/e8ab1101-9cdd-4c32-95fe-751d75dfafce.mp3",
    "type": "audio"
  },
  "sfx_part_drop": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/ae05dcbd-41b1-48fc-a51b-4be3901a41f0.mp3",
    "type": "audio"
  },
  "sfx_invalid_action": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/809c2931-67c1-4e3f-a74d-6908e21276e4.mp3",
    "type": "audio"
  },
  "sfx_level_complete": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/87824a67-0753-4a27-a680-4cc17543cae5.mp3",
    "type": "audio"
  },
  "music_background_ambient": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/music/b3621ee4-317d-420d-9c71-c31b91544db9.mp3",
    "type": "audio"
  },
  "board_red_450": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/board_red_450_4f73f3e0-ba51-4e83-8711-ff513917125e.webp",
    "type": "image",
    "aspect_ratio": [
      1272,
      591
    ]
  },
  "board_yellow_450": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/board_yellow_450_62135cea-3735-420a-9be8-a393045563d0.webp",
    "type": "image",
    "aspect_ratio": [
      791,
      1511
    ]
  },
  "board_green_450": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/board_green_450_f2724987-2cf6-479f-a18b-3b611690524d.webp",
    "type": "image",
    "aspect_ratio": [
      690,
      1514
    ]
  },
  "board_green_750": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/board_green_750_22337f31-48d6-4ec8-99a4-11f8b5f612da.webp",
    "type": "image",
    "aspect_ratio": [
      429,
      1505
    ]
  },
  "board_red_450_v2": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/board_red_450_v2_fb85cb56-afb4-488c-82f3-a5c5c93b5f5d.webp",
    "type": "image",
    "aspect_ratio": [
      580,
      1404
    ]
  },
  "board_blue_450": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/board_blue_450_8f903216-82f0-4247-a7c7-5312bca5e2e3.webp",
    "type": "image",
    "aspect_ratio": [
      699,
      1402
    ]
  },
  "part_hole": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709371176_01KH381J98B7DYE5A6NPAXTYVB.hole_white.png",
    "type": "image"
  },
  "part_new_1": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709409780_01KH382QZM70C7J9H56QKFMQMZ.part_new_1.png",
    "type": "image"
  },
  "part_new_1g": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709560821_01KH387BFNJCAY6259S01CVNPE.part_new_1_1.png",
    "type": "image"
  },
  "part_new_1_1r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709582422_01KH3880JP6WHX19FV11BQZ132.part_new_1_2.png",
    "type": "image"
  },
  "part_new_2": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709618220_01KH3893HCXT65CWVYRP2BGSJW.part_new_2.png",
    "type": "image"
  },
  "part_new_2g": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709647098_01KH389ZQT2R8XZ2SXP850TYFT.part_new_2_1.png",
    "type": "image"
  },
  "part_new_2r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709670346_01KH38APEAP3HCPPWPX44F84DK.part_new_2_2.png",
    "type": "image"
  },
  "part_new_3": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709707187_01KH38BTDKYM62FRG6JM4N8H01.part_new_3.png",
    "type": "image"
  },
  "part_new_3g": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709737982_01KH38CRFYV2EZ7R5BTCCRSNH5.part_new_3_1.png",
    "type": "image"
  },
  "part_new_3r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709767446_01KH38DN8P89QQTE5KN6S4TCF8.part_new_3_2.png",
    "type": "image"
  },
  "part_new_4": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709796802_01KH38EHY2WGDDWR5EGZ22DMZR.part_new_4.png",
    "type": "image"
  },
  "part_new_4g": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709822860_01KH38FBCC5XFMK0NJ7PEYAEX4.part_new_4_1.png",
    "type": "image"
  },
  "part_new_4r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709913688_01KH38J42RWRMDK0S85C3Q3BNW.part_new_4_2.png",
    "type": "image"
  },
  "part_new_5": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770709992308_01KH38MGVMNDK0HDWNGT7JQ9JE.part_new_5.png",
    "type": "image"
  },
  "part_new_5g": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770710072886_01KH38PZHPYGPGWFJ7T0T4ER30.part_new_5_1.png",
    "type": "image"
  },
  "part_new_5r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770710133674_01KH38RTXABY14HGK53TQY4C9Q.part_new_5_2.png",
    "type": "image"
  },
  "part_new_6": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770710169146_01KH38SXHT6QSQS28VMVVXTSFB.part_new_6.png",
    "type": "image"
  },
  "part_new_6g": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770710226044_01KH38VN3WS7E4VPHN00F0KFVP.part_new_6_1.png",
    "type": "image"
  },
  "part_new_6r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770710266179_01KH38WWA34FNT5BTHACC87V49.part_new_6_2.png",
    "type": "image"
  },
  "part_new_7g": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770806880318_01KH651A1Y8NJQ4CHMSWV5J76F.part_new_7_1.png",
    "type": "image"
  },
  "part_new_8r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770806996709_01KH654VQ5Y5QF6D81P0151AT2.part_new_8_2.png",
    "type": "image"
  },
  "part_new_9r": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770807041998_01KH6567YEDA0640KW4K1ESFYK.part_new_9_2.png",
    "type": "image"
  },
  "part_new_10": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770807041998_01KH6567YEDA0640KW4K1ESFYK.part_new_9_2.png",
    "type": "image"
  },
  "main_screw": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770892664648_01KH8PV7T8PKJP5QD365VR8DRJ.main_screw.png",
    "type": "image"
  },
  "part_new_11": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_117678079947000687441/1770892849848_01KH8Q0WNRRTCF6ZE3MFFX9GE6.part_new_11.png",
    "type": "image"
  },
  "sfx_human_cheer": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/sfx_human_cheer_fa16bae7-05c8-4c81-a290-7726c18d7e64.mp3",
    "type": "audio"
  },
  "sfx_button_press": {
    "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/sfx_button_press_b203e726-8c27-4214-9826-cd1aa73938e0.mp3",
    "type": "audio"
  },
  "ScrewKingThumnail": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_115111021931251906261/1772088300936_01KJCB35C8REA1MJK4R3MB8QX3.ScrewKingThumnail.webp",
    "type": "image"
  },
  "ScrewKingGameBgWEBP.webp": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_115111021931251906261/1772088893707_01KJCBN88B6RNGZHTVTR9ST2GM.ScrewKingGameBgWEBP.webp",
    "type": "image"
  },
  "music_easy_lemon": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_115111021931251906261/1772160345639_01KJEFSSH7SF96DVFRN2JA1HKD.EasyLemon.mp3",
    "type": "audio"
  },
  "super_screw_thumbnail": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_115111021931251906261/1772166334251_01KJENGHSBB438NP45V4P7KNYZ.thumbnail_small.webp",
    "type": "image"
  },
  "thumbnail_new": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_115111021931251906261/1772173269540_01KJEW46H41C0B9081073FSJJE.thumbnail_new_small.webp",
    "type": "image"
  },
  "orange_button_ui": {
    "url": "https://dzmv1mxivz48k.cloudfront.net/images/Google_115111021931251906261/1772175388982_01KJEY4W9P4MHQPS76V2WDCS0M.橙色长方形按钮最终.webp",
    "type": "image"
  }
}
    </script>
  ''';
}
