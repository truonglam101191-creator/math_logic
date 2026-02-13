import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSortiePalStub extends StatefulWidget {
  const WebSortiePalStub({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebSortiePalStub> createState() => _WebPackPalStubState();
}

class _WebPackPalStubState extends State<WebSortiePalStub> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

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
        String html = await rootBundle.loadString('assets/sortie/sortie.html');

        final config = await rootBundle.loadString('assets/sortie/config.json');

        if (config.isNotEmpty) {
          html = html.replaceAll(
            '<script id="gameConfig"></script>',
            '<script id="gameConfig"> window.gameConfig = $config ;</script>',
          );
        }

        final assets = await rootBundle.loadString(
          'assets/sortie/assetMap.json',
        );

        if (assets.isNotEmpty) {
          html = html.replaceAll(
            '<script id="assetsMap" type="application/json"></script>',
            '<script id="assetsMap" type="application/json">$assets</script>',
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
        // try {
        //   final sp = SharedPreferences.getInstance();
        //   sp.then((prefs) {
        //     prefs.setString(_kSavedGameStateKey, jsonEncode(stateObj));
        //   });
        // } catch (e) {
        //   debugPrint('Failed to save game state: $e');
        // }

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

    return ColoredBox(
      color: Color(0xff0a1128),
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
                    child: CircularProgressIndicator(color: Color(0xff33f5ff)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
