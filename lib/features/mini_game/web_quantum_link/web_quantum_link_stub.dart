import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebQuantumLinkStub extends StatefulWidget {
  const WebQuantumLinkStub({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebQuantumLinkStub> createState() => _WebQuantumLinkStubState();
}

class _WebQuantumLinkStubState extends State<WebQuantumLinkStub> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    // nothing to initialize here; controller created in onWebViewCreated
  }

  // // Inject locale JSON from Flutter assets into the web page.
  // Future<void> _injectLocale() async {
  //   try {
  //     // Get current locale code from context (fallback to 'en')
  //     final locale = (() {
  //       try {
  //         return Localizations.localeOf(context).languageCode;
  //       } catch (e) {
  //         return 'en';
  //       }
  //     })();
  //
  //     // Try language-specific file, then fallback to generic locale.json, then empty object
  //     String data = '{}';
  //     final candidates = [
  //       'assets/circuit_connect/locale_$locale.json',
  //       'assets/circuit_connect/locale.json',
  //     ];
  //     for (final path in candidates) {
  //       try {
  //         data = await rootBundle.loadString(path);
  //         if (data.trim().isNotEmpty) break;
  //       } catch (_) {
  //         // ignore and try next
  //       }
  //     }
  //
  //     // Ensure valid JSON
  //     Map<String, dynamic> obj;
  //     try {
  //       obj = jsonDecode(data) as Map<String, dynamic>;
  //     } catch (_) {
  //       obj = {};
  //     }
  //
  //     // Call the page's receiver (receiveLocale or setLocaleStrings)
  //     final jsPayload = jsonEncode(obj);
  //     final js =
  //         '''
  // 			try{
  // 				if (window.receiveLocale) window.receiveLocale($jsPayload);
  // 				else if (window.setLocaleStrings) window.setLocaleStrings($jsPayload);
  // 			}catch(e){}
  // 		''';
  //     await _controller.runJavaScript(js);
  //   } catch (e) {
  //     debugPrint('Locale injection failed: $e');
  //   }
  // }

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

  // Unified JS message handler: payload may be String JSON or Map or other
  void _handleJsMessage(dynamic payload) {
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
        // leave parsed empty to handle legacy string messages below
        parsed = {};
      }

      if (parsed.isNotEmpty && parsed['type'] == 'game_end') {
        final s = parsed['score'];
        final int? score = s is int ? s : int.tryParse(s?.toString() ?? '');
        if (score != null) widget.onGameEnd?.call(score);
        return;
      }

      if (parsed.isNotEmpty &&
          (parsed['type'] == 'exitGame' || parsed['type'] == 'back')) {
        Navigator.of(context).pop();
        return;
      }

      // support payload that directly contains score
      if (parsed.isNotEmpty && parsed.containsKey('score')) {
        final s = parsed['score'];
        final int? score = s is int ? s : int.tryParse(s?.toString() ?? '');
        if (score != null) widget.onGameEnd?.call(score);
        return;
      }

      // legacy simple string "score:123" or raw "123"
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

                // register multiple handler names (some pages / android may call different names)
                final handlerNames = [
                  'FlutterWebViewChannel',
                  'onBack',
                  'onCloseWindow',
                  'exitGame',
                  'GameChannel',
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
                    // non-fatal: continue registering others
                    debugPrint('Failed to add handler $name: $e');
                  }
                }

                // load local HTML asset
                try {
                  final html = await rootBundle.loadString(
                    'assets/quantum_link/quantum_link.html',
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
                setState(() => _ready = true);
                try {
                  await controller.evaluateJavascript(
                    source:
                        "try{document.documentElement.style.backgroundColor='#0a1128';document.body.style.backgroundColor='#0a1128';}catch(e){}",
                  );
                } catch (e) {
                  debugPrint('Set background JS failed: $e');
                }

                final bridge = '''
                  try {
                    if (window.FlutterWebViewChannel) {
                      window.GameChannel = {
                        postMessage: function(message) {
                          window.FlutterWebViewChannel.postMessage(message);
                        }
                      };
                    }
                  } catch(e) {}
                ''';
                try {
                  await controller.evaluateJavascript(source: bridge);
                } catch (e) {
                  debugPrint('Bridge injection failed: $e');
                }
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
