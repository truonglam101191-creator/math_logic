import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebCircuitConnectStub extends StatefulWidget {
  const WebCircuitConnectStub({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebCircuitConnectStub> createState() => _WebCircuitConnectStubState();
}

class _WebCircuitConnectStubState extends State<WebCircuitConnectStub> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    // nothing to initialize here; InAppWebView controller is created in onWebViewCreated
  }

  // Inject locale JSON from Flutter assets into the web page.
  Future<void> _injectLocale() async {
    try {
      // Get current locale code from context (fallback to 'en')
      final locale = (() {
        try {
          return Localizations.localeOf(context).languageCode;
        } catch (e) {
          return 'en';
        }
      })();

      // Try language-specific file, then fallback to generic locale.json, then empty object
      String data = '{}';
      final candidates = [
        'assets/circuit_connect/locale_$locale.json',
        'assets/circuit_connect/locale.json',
      ];
      for (final path in candidates) {
        try {
          data = await rootBundle.loadString(path);
          if (data.trim().isNotEmpty) break;
        } catch (_) {
          // ignore and try next
        }
      }

      // Ensure valid JSON
      Map<String, dynamic> obj;
      try {
        obj = jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        obj = {};
      }

      // Call the page's receiver (receiveLocale or setLocaleStrings)
      final jsPayload = jsonEncode(obj);
      final js =
          '''
        try{
          if (window.receiveLocale) window.receiveLocale($jsPayload);
          else if (window.setLocaleStrings) window.setLocaleStrings($jsPayload);
        }catch(e){}
      ''';
      // Use evaluateJavascript on InAppWebViewController
      await _controller.evaluateJavascript(source: js);
    } catch (e) {
      debugPrint('Locale injection failed: $e');
    }
  }

  @override
  void dispose() {
    // Try to stop webview and clear resources so the web/game stops running.
    try {
      _ready = false;
      // clear cache (best-effort)
      _controller.clearCache();
      // navigate to blank page to stop any running JS
      _controller.loadUrl(urlRequest: URLRequest(url: WebUri('about:blank')));
      _controller.dispose();
    } catch (e) {
      debugPrint('Error while disposing WebViewController: $e');
    } finally {
      super.dispose();
    }
  }

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
              // initialOptions: InAppWebViewGroupOptions(
              //   crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
              //   android: AndroidInAppWebViewOptions(useHybridComposition: true),
              // ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useShouldOverrideUrlLoading: true,
              ),

              onWebViewCreated: (controller) async {
                _controller = controller;

                // register JS handler; web page should call:
                // window.flutter_inappwebview.callHandler('FlutterWebViewChannel', payload)
                _controller.addJavaScriptHandler(
                  handlerName: 'FlutterWebViewChannel',
                  callback: (args) {
                    try {
                      final payload = args.isNotEmpty ? args[0] : '';
                      final Map parsed =
                          (payload is String && payload.startsWith('{'))
                          ? Map.castFrom(jsonDecode(payload))
                          : (payload is Map ? Map.castFrom(payload) : {});

                      if (parsed.isNotEmpty && parsed['type'] == 'game_end') {
                        final s = parsed['score'];
                        final int? score = s is int
                            ? s
                            : int.tryParse(s?.toString() ?? '');
                        if (score != null) widget.onGameEnd?.call(score);
                      } else if (parsed.isNotEmpty &&
                          parsed['type'] == 'exitGame') {
                        Navigator.of(context).pop();
                      } else {
                        // support legacy simple "score:123" messages
                        final asStr = payload?.toString() ?? '';
                        if (asStr.startsWith('score:')) {
                          final val = int.tryParse(asStr.split(':').last);
                          if (val != null) widget.onGameEnd?.call(val);
                        }
                      }
                    } catch (e) {
                      debugPrint('Failed to parse GameChannel message: $e');
                    }
                    return null;
                  },
                );

                // load local HTML asset
                try {
                  final html = await rootBundle.loadString(
                    'assets/circuit_connect/circuit_connect.html',
                  );
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
              },
              onLoadStop: (controller, url) async {
                // ensure page has dark background to avoid white flash
                try {
                  await controller.evaluateJavascript(
                    source:
                        "try{document.documentElement.style.backgroundColor='#0a1128';document.body.style.backgroundColor='#0a1128';}catch(e){}",
                  );
                } catch (e) {
                  debugPrint('Set background JS failed: $e');
                }
                final bridge = r'''
                   (function(){
                     try{
                       // simple debounce to avoid duplicate messages (within 500ms)
                       if(!window.__flutter_bridge_sendOnce){
                         window.__flutter_bridge_lastTime = 0;
                         window.__flutter_bridge_sendOnce = function(payload){
                           try{
                             var now = Date.now();
                             if(now - (window.__flutter_bridge_lastTime || 0) < 500) return;
                             window.__flutter_bridge_lastTime = now;
                             window.flutter_inappwebview.callHandler('FlutterWebViewChannel', payload);
                           }catch(e){}
                         };
                       }

                       if(!window.FlutterWebViewChannel){
                         window.FlutterWebViewChannel = {
                           postMessage: function(msg){
                             try{ window.__flutter_bridge_sendOnce(msg); }catch(e){}
                           }
                         };
                       }
                       if(!window.__flutter_bridge_installed){
                         window.__flutter_bridge_installed = true;
                         window.addEventListener('message', function(e){
                           try{ window.__flutter_bridge_sendOnce(e.data); }catch(e){}
                         });
                       }
                       // override exitGame/onCloseWindow to notify Flutter
                       window.exitGame = window.exitGame || function(arg){
                         try{ window.__flutter_bridge_sendOnce(JSON.stringify({type:'exitGame', payload: arg})); }catch(e){}
                       };
                       window.onCloseWindow = window.onCloseWindow || function(){
                         try{ window.__flutter_bridge_sendOnce(JSON.stringify({type:'exitGame'})); }catch(e){}
                       };
                       // intercept history.back/go(-1) as "back" event
                       (function(){
                         var _origBack = history.back;
                         history.back = function(){
                           try{ window.__flutter_bridge_sendOnce(JSON.stringify({type:'back'})); }catch(e){}
                           try{ _origBack.call(history); }catch(e){}
                         };
                         var _origGo = history.go;
                         history.go = function(delta){
                           if(delta === -1){
                             try{ window.__flutter_bridge_sendOnce(JSON.stringify({type:'back'})); }catch(e){}
                           }
                           try{ _origGo.call(history, delta); }catch(e){}
                         };
                       })();
                     }catch(e){}
                   })();
                 ''';
                try {
                  await controller.evaluateJavascript(source: bridge);
                } catch (e) {
                  debugPrint('Bridge injection failed: $e');
                }

                setState(() => _ready = true);
                _injectLocale();
              },
              onLoadError: (controller, url, code, message) {
                debugPrint('WebView error: $code $message');
                setState(() => _error = true);
              },
            ),
            if (!_ready) const Center(child: CircularProgressIndicator()),
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
