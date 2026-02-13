import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebGardenGulp extends StatefulWidget {
  const WebGardenGulp({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebGardenGulp> createState() => _WebPackPalStubState();
}

class _WebPackPalStubState extends State<WebGardenGulp> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

  late final perferen = Shared.instance.sharedPreferences;

  final _kSavedGameStateKey = 'garden_gulp_game_state';

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
          'assets/garden_gulp/garden_gulp.html',
        );

        if (config.isNotEmpty) {
          html = html.replaceAll('<script id="gameConfig"></script>', config);
        }

        if (assets.isNotEmpty) {
          html = html.replaceAll(
            '<script id="assetsMap" type="application/json"></script>',
            assets,
          );
        }

        html = html.replaceAll('<script id="logic"></script>', loadLogicGame);

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

    return PopScope(
      canPop: false,
      child: ColoredBox(
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

  String get config => '''
   <script id="gameConfig">
        window.gameConfig = {
    "currentLevel": 1,
    "theme": "fruit",
    "objects": [
        {
            "id": "obj_1",
            "type": "apple",
            "x": 650,
            "y": 500,
            "size": "small"
        },
        {
            "id": "obj_2",
            "type": "orange",
            "x": 850,
            "y": 550,
            "size": "tiny"
        },
        {
            "id": "obj_3",
            "type": "banana",
            "x": 750,
            "y": 700,
            "size": "small"
        },
        {
            "id": "obj_4",
            "type": "watermelon",
            "x": 950,
            "y": 800,
            "size": "large"
        },
        {
            "id": "obj_5",
            "type": "strawberry",
            "x": 550,
            "y": 650,
            "size": "tiny"
        },
        {
            "id": "obj_6",
            "type": "pineapple",
            "x": 1050,
            "y": 650,
            "size": "medium"
        },
        {
            "id": "obj_7",
            "type": "apple",
            "x": 700,
            "y": 900,
            "size": "small"
        },
        {
            "id": "obj_8",
            "type": "orange",
            "x": 900,
            "y": 950,
            "size": "tiny"
        },
        {
            "id": "obj_9",
            "type": "banana",
            "x": 600,
            "y": 800,
            "size": "small"
        },
        {
            "id": "obj_10",
            "type": "strawberry",
            "x": 800,
            "y": 600,
            "size": "tiny"
        },
        {
            "id": "obj_11",
            "type": "apple",
            "x": 1100,
            "y": 750,
            "size": "small"
        },
        {
            "id": "obj_12",
            "type": "watermelon",
            "x": 650,
            "y": 1050,
            "size": "large"
        },
        {
            "id": "obj_13",
            "type": "pineapple",
            "x": 850,
            "y": 1100,
            "size": "medium"
        },
        {
            "id": "obj_14",
            "type": "orange",
            "x": 1000,
            "y": 550,
            "size": "tiny"
        },
        {
            "id": "obj_15",
            "type": "banana",
            "x": 550,
            "y": 900,
            "size": "small"
        },
        {
            "id": "obj_16",
            "type": "apple",
            "x": 1000,
            "y": 900,
            "size": "small"
        },
        {
            "id": "obj_17",
            "type": "strawberry",
            "x": 700,
            "y": 650,
            "size": "tiny"
        },
        {
            "id": "obj_18",
            "type": "pineapple",
            "x": 950,
            "y": 450,
            "size": "medium"
        },
        {
            "id": "obj_19",
            "type": "watermelon",
            "x": 600,
            "y": 1150,
            "size": "large"
        },
        {
            "id": "obj_20",
            "type": "orange",
            "x": 1100,
            "y": 1000,
            "size": "small"
        }
    ],
    "holeStartSize": 80,
    "holeMaxMultiplier": 3,
    "gardenSize": 1500,
    "musicVolume": 50,
    "levelTimeLimit": 60,
    "soundVolume": 68,
    "musicEnabled": true,
    "soundEnabled": true
};
     </script>
  ''';

  String get assets => '''<script id="assetsMap" type="application/json">
    {
    "hole_texture": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/521ac6c3-9533-4abf-90af-9a7aa526d55e.webp",
        "type": "image",
        "aspect_ratio": [
            910,
            735
        ]
    },
    "grass_texture": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/6079bf63-50d2-45f1-b965-ca9d5aba4dee.webp",
        "type": "image",
        "aspect_ratio": [
            1024,
            1024
        ]
    },
    "apple": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/f37c1ae2-8999-4087-bfe7-5ac4fae2dd30.webp",
        "type": "image",
        "aspect_ratio": [
            639,
            747
        ]
    },
    "orange": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/0fab65d6-4104-4b2f-ba13-661176159452.webp",
        "type": "image",
        "aspect_ratio": [
            712,
            800
        ]
    },
    "banana": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/8f77823c-973e-4f49-8968-39d83a2b7796.webp",
        "type": "image",
        "aspect_ratio": [
            794,
            846
        ]
    },
    "watermelon": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/789ddcc6-6a2c-4a69-882e-0894439c2890.webp",
        "type": "image",
        "aspect_ratio": [
            789,
            862
        ]
    },
    "strawberry": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/ad13c641-9e57-43b6-9711-9f791ef9ca8b.webp",
        "type": "image",
        "aspect_ratio": [
            685,
            809
        ]
    },
    "pineapple": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/4fb62dde-e678-4300-a785-37d406c85fef.webp",
        "type": "image",
        "aspect_ratio": [
            621,
            916
        ]
    },
    "teddy_bear": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/75534300-92b7-451f-952c-38a4c66ee20c.webp",
        "type": "image",
        "aspect_ratio": [
            723,
            848
        ]
    },
    "toy_car": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/f361c45e-7a87-436c-aeb7-041ab97192d9.webp",
        "type": "image",
        "aspect_ratio": [
            818,
            747
        ]
    },
    "building_block": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/754cbd97-1d7e-41cc-b70b-d5a65396483f.webp",
        "type": "image",
        "aspect_ratio": [
            866,
            835
        ]
    },
    "rubber_duck": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/4a13efb1-14c0-4a8f-8d50-300299111eb4.webp",
        "type": "image",
        "aspect_ratio": [
            655,
            801
        ]
    },
    "ball": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/d04a9d1d-7ec9-4197-b8c4-ebe8c07b799e.webp",
        "type": "image",
        "aspect_ratio": [
            779,
            848
        ]
    },
    "toy_robot": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/1abac181-0542-48e9-a999-b13da522c0fa.webp",
        "type": "image",
        "aspect_ratio": [
            630,
            939
        ]
    },
    "carrot": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/82b4b665-dd1a-4cda-b40a-69e89ebf91ef.webp",
        "type": "image",
        "aspect_ratio": [
            624,
            848
        ]
    },
    "tomato": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/677d6082-376e-4d61-b029-7d62e07a5a94.webp",
        "type": "image",
        "aspect_ratio": [
            746,
            846
        ]
    },
    "pumpkin": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/0ce0a780-90f9-43e8-9367-aba4b515530e.webp",
        "type": "image",
        "aspect_ratio": [
            872,
            865
        ]
    },
    "corn": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/fd8afd1f-a71c-4433-96c2-27e3c280a125.webp",
        "type": "image",
        "aspect_ratio": [
            776,
            829
        ]
    },
    "broccoli": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/96bc0a29-55d0-4446-9b5b-0a350803125a.webp",
        "type": "image",
        "aspect_ratio": [
            691,
            835
        ]
    },
    "eggplant": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/660536db-4289-4b5e-9881-cebae024ed22.webp",
        "type": "image",
        "aspect_ratio": [
            706,
            832
        ]
    },
    "sandwich": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/aa1ce7d9-a774-409b-a659-374c75c17573.webp",
        "type": "image",
        "aspect_ratio": [
            787,
            691
        ]
    },
    "cupcake": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/7a6c07ae-a237-414b-a5dc-96acc9abd4d7.webp",
        "type": "image",
        "aspect_ratio": [
            685,
            842
        ]
    },
    "pizza_slice": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/f6fa97ac-5bf3-4d30-962d-ddd792b1ad91.webp",
        "type": "image",
        "aspect_ratio": [
            938,
            865
        ]
    },
    "hot_dog": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/fbf0065b-2f2e-4a4e-b8e1-036af05a56da.webp",
        "type": "image",
        "aspect_ratio": [
            885,
            742
        ]
    },
    "ice_cream_cone": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/3154438b-2ce7-422d-b16f-bfb13a44f208.webp",
        "type": "image",
        "aspect_ratio": [
            526,
            868
        ]
    },
    "donut": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/bdddbbe7-65c1-49db-a957-d9835c6b3a76.webp",
        "type": "image",
        "aspect_ratio": [
            1008,
            835
        ]
    },
    "small_dog": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/a3e2b6cb-1265-4746-9989-acf5083d3167.webp",
        "type": "image",
        "aspect_ratio": [
            741,
            791
        ]
    },
    "cat": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/3932d380-4447-4e30-ad93-3abeb5b0044e.webp",
        "type": "image",
        "aspect_ratio": [
            746,
            846
        ]
    },
    "bunny": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/06467371-f8a2-4065-b499-1c49b68a066c.webp",
        "type": "image",
        "aspect_ratio": [
            613,
            913
        ]
    },
    "hamster": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/082577cb-e193-4907-ac66-23ed0bade0dc.webp",
        "type": "image",
        "aspect_ratio": [
            792,
            842
        ]
    },
    "bird": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/5d2222a5-81fa-4999-a156-619bd20b2eb7.webp",
        "type": "image",
        "aspect_ratio": [
            731,
            891
        ]
    },
    "turtle": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/9b710a63-a9c6-4e93-8cb6-93a5e2dc8b6b.webp",
        "type": "image",
        "aspect_ratio": [
            927,
            803
        ]
    },
    "lollipop": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/bc56fedb-dae8-4c9c-b871-d377626f114f.webp",
        "type": "image",
        "aspect_ratio": [
            687,
            887
        ]
    },
    "gummy_bear": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/5ec7c8fe-b5d9-4ae6-b8fa-bcffd1f44a5d.webp",
        "type": "image",
        "aspect_ratio": [
            516,
            826
        ]
    },
    "candy_cane": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/fabe4cac-cbd1-4db3-9118-cc2dec4a87c1.webp",
        "type": "image",
        "aspect_ratio": [
            750,
            819
        ]
    },
    "chocolate_bar": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/97a8b823-dcf9-4034-b1a1-8a845ba669b6.webp",
        "type": "image",
        "aspect_ratio": [
            909,
            834
        ]
    },
    "jellybeans": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/86914d98-9ffa-4969-a4bd-fdef421c7cef.webp",
        "type": "image",
        "aspect_ratio": [
            842,
            677
        ]
    },
    "beach_ball": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/4fbee7c9-2996-444c-813a-ca8a57e5e491.webp",
        "type": "image",
        "aspect_ratio": [
            698,
            738
        ]
    },
    "sandcastle": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/1612552a-39d9-417c-9149-b7f4560d9b74.webp",
        "type": "image",
        "aspect_ratio": [
            652,
            844
        ]
    },
    "seashell": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/33b437a9-95b6-47de-8ec6-854d71f3493d.webp",
        "type": "image",
        "aspect_ratio": [
            695,
            712
        ]
    },
    "starfish": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/0dffcd1b-f766-4c6b-aa23-36e77995d5c8.webp",
        "type": "image",
        "aspect_ratio": [
            835,
            861
        ]
    },
    "flip_flops": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/08f8de1f-b726-4a18-a043-31a9606405ae.webp",
        "type": "image",
        "aspect_ratio": [
            866,
            705
        ]
    },
    "sunglasses": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/924de52e-cace-4f37-8ccc-509bd0d230c3.webp",
        "type": "image",
        "aspect_ratio": [
            862,
            502
        ]
    },
    "mushroom": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/6becd2ae-1d3a-442a-b0b7-1ed74cd6cf92.webp",
        "type": "image",
        "aspect_ratio": [
            818,
            854
        ]
    },
    "pinecone": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/4ac00a50-b998-4ae2-9052-0d7254da1134.webp",
        "type": "image",
        "aspect_ratio": [
            746,
            845
        ]
    },
    "acorn": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/3eb70829-0c10-4dfb-8db0-d44ceb5b47ef.webp",
        "type": "image",
        "aspect_ratio": [
            682,
            888
        ]
    },
    "flower": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/c65360a8-0153-49d1-9ff8-0e9e1120bd79.webp",
        "type": "image",
        "aspect_ratio": [
            640,
            860
        ]
    },
    "butterfly": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/36b1019b-420d-4489-b247-1973d368fa49.webp",
        "type": "image",
        "aspect_ratio": [
            856,
            776
        ]
    },
    "ladybug": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/images/bff3fd57-4491-4b72-9db4-8c9f277942c9.webp",
        "type": "image",
        "aspect_ratio": [
            872,
            799
        ]
    },
    "gulp_sound": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/daec00c6-d9d8-4a83-9720-174bf44b7e9b.mp3",
        "type": "audio"
    },
    "level_complete": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/music/94de87eb-d751-4b04-af00-179dd3ba82bd.mp3",
        "type": "audio"
    },
    "background_music": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/music/2eb5438d-baec-4379-bf2d-283d74c54fa1.mp3",
        "type": "audio"
    },
    "hole_grow_sound": {
        "url": "https://d2oir5eh8rty2e.cloudfront.net/assets/sounds/effect/7cea8d9f-00e1-4253-969c-dac129366bde.mp3",
        "type": "audio"
    }
}
   </script>''';

  String get loadLogicGame => r'''
    <script>
        /* ==================================================
         * GAME OVERVIEW: Garden Gulp - A satisfying hole-swallowing game where players control
         * a growing 3D hole that consumes objects in themed garden levels. Objects fall into
         * the hole with physics, causing it to grow. Complete levels by consuming all objects.
         * Features unlimited procedurally-generated levels with 8 rotating themes.
         * 
         * Edit mode allows theme selection, object placement, and level parameter adjustment.
         * 
         * GAME STATE SHAPE: window.gameConfig = {
         *   currentLevel: number,
         *   theme: string ('fruit'|'toy'|'vegetable'|'picnic'|'pet'|'candy'|'beach'|'forest'),
         *   objects: [{id: string, type: string, x: number, y: number, size: string}],
         *   holeStartSize: number (60-100),
         *   holeMaxMultiplier: number (2-4),
         *   gardenSize: number (1000-2000)
         * }
         * ==================================================
         */

        // Minimal host `lib` shim for standalone usage (only created if host doesn't provide it)
        if (!window.lib) {
            window.lib = (function () {
                let _assets = null;
                function _ensureAssets() {
                    if (_assets) return _assets;
                    const el = document.getElementById('assetsMap');
                    if (el) {
                        try {
                            _assets = JSON.parse(el.textContent || el.innerText || '{}');
                        } catch (e) {
                            _assets = {};
                        }
                    } else {
                        _assets = {};
                    }
                    return _assets;
                }

                return {
                    log: (...args) => console.log('[garden_gulp]', ...args),
                    getAsset: (id) => {
                        const assets = _ensureAssets();
                        return assets[id] || null;
                    },
                    showGameParameters: () => {},
                    getUserGameState: () => {
                        try { return JSON.parse(localStorage.getItem('garden_gulp_user')); } catch (e) { return null; }
                    },
                    saveUserGameState: (obj) => {
                        try { localStorage.setItem('garden_gulp_user', JSON.stringify(obj)); } catch (e) {}
                    },
                    editMenu: {
                        open: (opts) => { console.log('editMenu.open', opts); },
                        close: () => { console.log('editMenu.close'); }
                    }
                };
            })();
        }

        // Asset cache
        const assetCache = {};
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        const audioBuffers = {};
        let audioInitialized = false;
        
                // Load external config: supports URL string, File object, or reading from localStorage/URL param
                async function loadConfig(source) {
                    try {
                        let fetched = null;

                        // If a File object is provided (e.g. via file input), read it
                        if (source && typeof File !== 'undefined' && source instanceof File) {
                            fetched = await new Promise((res, rej) => {
                                const reader = new FileReader();
                                reader.onload = () => {
                                    try { res(JSON.parse(reader.result)); } catch (e) { rej(e); }
                                };
                                reader.onerror = rej;
                                reader.readAsText(source);
                            });
                        } else if (typeof source === 'string' && source.length > 0) {
                            // Treat source as URL
                            const resp = await fetch(source, { cache: 'no-store' });
                            if (!resp.ok) throw new Error('Failed to fetch config: ' + resp.status);
                            fetched = await resp.json();
                        } else {
                            throw new Error('Unsupported config source');
                        }

                        if (fetched && typeof fetched === 'object') {
                            window.gameConfig = Object.assign({}, window.gameConfig || {}, fetched);
                            if (window.lib && window.lib.log) window.lib.log('Config loaded and merged successfully');
                            return window.gameConfig;
                        }
                    } catch (err) {
                        console.warn('loadConfig error:', err);
                        throw err;
                    }
                }

                // Try to load a config from URL param `configUrl`, or localStorage key `garden_gulp_config`.
                // Returns a promise that resolves when attempt finishes (even if nothing loaded).
                async function loadConfigFromLocation() {
                    try {
                        // URL param check
                        const params = new URLSearchParams(window.location.search);
                        const cfgUrl = params.get('configUrl') || params.get('config');
                        if (cfgUrl) {
                            try {
                                await loadConfig(cfgUrl);
                                return;
                            } catch (e) {
                                console.warn('Failed to load config from URL param', cfgUrl, e);
                            }
                        }

                        // localStorage check
                        try {
                            const ls = localStorage.getItem('garden_gulp_config');
                            if (ls) {
                                const parsed = JSON.parse(ls);
                                window.gameConfig = Object.assign({}, window.gameConfig || {}, parsed);
                                if (window.lib && window.lib.log) window.lib.log('Config loaded from localStorage');
                                return;
                            }
                        } catch (e) {
                            console.warn('Failed to parse localStorage config', e);
                        }

                        // Nothing to load
                        return;
                    } catch (e) {
                        console.warn('loadConfigFromLocation error', e);
                    }
                }
        // Theme definitions
        const THEMES = {
            fruit: {
                name: 'Fruit Garden',
                objects: ['apple', 'orange', 'banana', 'watermelon', 'strawberry', 'pineapple'],
                bgColor: '#90EE90'
            },
            toy: {
                name: 'Toy Box',
                objects: ['teddy_bear', 'toy_car', 'building_block', 'rubber_duck', 'ball', 'toy_robot'],
                bgColor: '#FFB6C1'
            },
            vegetable: {
                name: 'Vegetable Patch',
                objects: ['carrot', 'tomato', 'pumpkin', 'corn', 'broccoli', 'eggplant'],
                bgColor: '#98FB98'
            },
            picnic: {
                name: 'Picnic Scene',
                objects: ['sandwich', 'cupcake', 'pizza_slice', 'hot_dog', 'ice_cream_cone', 'donut'],
                bgColor: '#F0E68C'
            },
            pet: {
                name: 'Pet Paradise',
                objects: ['small_dog', 'cat', 'bunny', 'hamster', 'bird', 'turtle'],
                bgColor: '#DDA0DD'
            },
            candy: {
                name: 'Candy Land',
                objects: ['lollipop', 'gummy_bear', 'candy_cane', 'chocolate_bar', 'jellybeans', 'cupcake'],
                bgColor: '#FFB6E1'
            },
            beach: {
                name: 'Beach Day',
                objects: ['beach_ball', 'sandcastle', 'seashell', 'starfish', 'flip_flops', 'sunglasses'],
                bgColor: '#F4A460'
            },
            forest: {
                name: 'Forest Floor',
                objects: ['mushroom', 'pinecone', 'acorn', 'flower', 'butterfly', 'ladybug'],
                bgColor: '#8FBC8F'
            }
        };
        
        // Size categories (in pixels)
        const SIZE_CATEGORIES = {
            tiny: { min: 40, max: 60 },
            small: { min: 60, max: 90 },
            medium: { min: 90, max: 130 },
            large: { min: 130, max: 180 }
        };
        
        // Game state
        let canvas, ctx;
        let currentMode = 'play';
        let gameLoop = null;
        let lastTime = 0;
        
        // Play mode state
        let hole = { x: 360, y: 640, size: 80, targetSize: 80, rotation: 0 };
        let objects = [];
        let consumedCount = 0;
        let levelStartTime = 0;
        let timeRemaining = 60;
        let isLevelComplete = false;
        let isTimeUp = false;
        let backgroundMusicSource = null;
        
        // Edit mode state
        let selectedObject = null;
        let isDragging = false;
        let dragOffset = { x: 0, y: 0 };
        
        // Input state
        let keys = {};
        let touchPos = null;
        let isTouchDevice = false;
        
        // Camera/viewport
        const CANVAS_WIDTH = 720;
        const CANVAS_HEIGHT = 1280;
        const WORLD_SIZE = 1500;
        let camera = { x: 0, y: 0 };
        
        // UI state
        let isEditDrawerOpen = false;
        
        // Preload assets
        function preloadAssets() {
            return new Promise((resolve) => {
                const imageAssets = [
                    'hole_texture', 'grass_texture',
                    'apple', 'orange', 'banana', 'watermelon', 'strawberry', 'pineapple',
                    'teddy_bear', 'toy_car', 'building_block', 'rubber_duck', 'ball', 'toy_robot',
                    'carrot', 'tomato', 'pumpkin', 'corn', 'broccoli', 'eggplant',
                    'sandwich', 'cupcake', 'pizza_slice', 'hot_dog', 'ice_cream_cone', 'donut',
                    'small_dog', 'cat', 'bunny', 'hamster', 'bird', 'turtle',
                    'lollipop', 'gummy_bear', 'candy_cane', 'chocolate_bar', 'jellybeans',
                    'beach_ball', 'sandcastle', 'seashell', 'starfish', 'flip_flops', 'sunglasses',
                    'mushroom', 'pinecone', 'acorn', 'flower', 'butterfly', 'ladybug'
                ];
                
                const audioAssets = ['gulp_sound', 'level_complete', 'background_music', 'hole_grow_sound'];
                
                let loadedCount = 0;
                const totalAssets = imageAssets.length + audioAssets.length;
                
                // Load images
                imageAssets.forEach(id => {
                    const assetInfo = lib.getAsset(id);
                    if (assetInfo) {
                        const img = new Image();
                        img.onload = () => {
                            loadedCount++;
                            if (loadedCount === totalAssets) resolve();
                        };
                        img.onerror = () => {
                            loadedCount++;
                            if (loadedCount === totalAssets) resolve();
                        };
                        img.src = assetInfo.url;
                        assetCache[id] = { img, info: assetInfo };
                    } else {
                        loadedCount++;
                    }
                });
                
                // Load audio
                audioAssets.forEach(id => {
                    const assetInfo = lib.getAsset(id);
                    if (assetInfo) {
                        fetch(assetInfo.url)
                            .then(response => response.arrayBuffer())
                            .then(arrayBuffer => audioContext.decodeAudioData(arrayBuffer))
                            .then(audioBuffer => {
                                audioBuffers[id] = audioBuffer;
                                loadedCount++;
                                if (loadedCount === totalAssets) resolve();
                            })
                            .catch(() => {
                                loadedCount++;
                                if (loadedCount === totalAssets) resolve();
                            });
                    } else {
                        loadedCount++;
                    }
                });
            });
        }
        
        // Initialize audio on user interaction
        function initAudio() {
            if (audioInitialized) return;
            
            lib.log('🎵 Initializing audio...');
            
            if (audioContext.state === 'suspended') {
                audioContext.resume().then(() => {
                    audioInitialized = true;
                    lib.log('🎵 Audio context resumed successfully!');
                    
                    // Start background music if in play mode and not already playing
                    if (currentMode === 'play' && !backgroundMusicSource) {
                        backgroundMusicSource = playSound('background_music', true);
                        lib.log('🎵 Background music started after user interaction!');
                    }
                });
            } else {
                audioInitialized = true;
                lib.log('🎵 Audio context already running!');
                // Start background music if in play mode and not already playing
                if (currentMode === 'play' && !backgroundMusicSource) {
                    backgroundMusicSource = playSound('background_music', true);
                    lib.log('🎵 Background music started immediately!');
                }
            }
        }
        
        // Play audio
        function playSound(id, loop = false) {
            if (!audioBuffers[id]) return null;
            
            // Try to initialize audio if not done yet
            if (!audioInitialized) {
                initAudio();
            }
            
            // Check if music/sound is enabled
            if (id === 'background_music' && !window.gameConfig.musicEnabled) {
                return null;
            }
            if (id !== 'background_music' && !window.gameConfig.soundEnabled) {
                return null;
            }
            
            const source = audioContext.createBufferSource();
            source.buffer = audioBuffers[id];
            source.loop = loop;
            
            const gainNode = audioContext.createGain();
            
            // Use different volume settings for music vs sound effects
            if (id === 'background_music') {
                const musicVolume = (window.gameConfig.musicVolume || 50) / 100;
                gainNode.gain.value = musicVolume * 0.3;
            } else {
                const soundVolume = (window.gameConfig.soundVolume || 50) / 100;
                gainNode.gain.value = soundVolume * 0.5;
            }
            
            source.connect(gainNode);
            gainNode.connect(audioContext.destination);
            source.start(0);
            
            // Store gain node reference for music so we can adjust volume later
            if (id === 'background_music') {
                source.gainNode = gainNode;
            }
            
            return source;
        }
        
        // Generate level objects
        // Generate level objects
        function generateLevelObjects(theme, count) {
            const themeData = THEMES[theme];
            const objects = [];
            const gardenSize = window.gameConfig.gardenSize || 1500;
            
            // Calculate visible viewport bounds (since camera is static and centered)
            const viewportLeft = (gardenSize - CANVAS_WIDTH) / 2;
            const viewportTop = (gardenSize - CANVAS_HEIGHT) / 2;
            const viewportRight = viewportLeft + CANVAS_WIDTH;
            const viewportBottom = viewportTop + CANVAS_HEIGHT;
            
            // Add margin so objects aren't right at edges
            const margin = 60;
            const spawnLeft = viewportLeft + margin;
            const spawnTop = viewportTop + margin;
            const spawnRight = viewportRight - margin;
            const spawnBottom = viewportBottom - margin;
            
            // Size distribution: 50% tiny, 30% small, 15% medium, 5% large
            const sizeDistribution = [];
            for (let i = 0; i < count; i++) {
                const rand = Math.random();
                if (rand < 0.5) sizeDistribution.push('tiny');
                else if (rand < 0.8) sizeDistribution.push('small');
                else if (rand < 0.95) sizeDistribution.push('medium');
                else sizeDistribution.push('large');
            }
            
            // Place objects within visible viewport
            for (let i = 0; i < count; i++) {
                const type = themeData.objects[Math.floor(Math.random() * themeData.objects.length)];
                const size = sizeDistribution[i];
                
                let x, y, attempts = 0;
                let validPosition = false;
                
                // Find non-overlapping position - increased attempts
                while (!validPosition && attempts < 150) {
                    x = spawnLeft + Math.random() * (spawnRight - spawnLeft);
                    y = spawnTop + Math.random() * (spawnBottom - spawnTop);
                    
                    validPosition = true;
                    const objSize = (SIZE_CATEGORIES[size].min + SIZE_CATEGORIES[size].max) / 2;
                    
                    // Check overlap with existing objects - reduced spacing requirement
                    for (const obj of objects) {
                        const otherSize = (SIZE_CATEGORIES[obj.size].min + SIZE_CATEGORIES[obj.size].max) / 2;
                        const dist = Math.sqrt((x - obj.x) ** 2 + (y - obj.y) ** 2);
                        if (dist < (objSize + otherSize) / 2 + 10) {
                            validPosition = false;
                            break;
                        }
                    }
                    
                    // Check distance from hole starting position (center of viewport)
                    const holeX = gardenSize / 2;
                    const holeY = gardenSize / 2;
                    const distFromHole = Math.sqrt((x - holeX) ** 2 + (y - holeY) ** 2);
                    if (distFromHole < 120) {
                        validPosition = false;
                    }
                    
                    attempts++;
                }
                
                if (validPosition) {
                    objects.push({
                        id: `obj_${Date.now()}_${i}`,
                        type,
                        x,
                        y,
                        size,
                        consumed: false,
                        falling: false,
                        fallProgress: 0,
                        vx: 0, // Objects start completely still
                        vy: 0,
                        directionChangeTimer: 0
                    });
                } else {
                    // If we still can't place after many attempts, reduce size and try one more time
                    const smallerSize = size === 'large' ? 'medium' : size === 'medium' ? 'small' : 'tiny';
                    x = spawnLeft + Math.random() * (spawnRight - spawnLeft);
                    y = spawnTop + Math.random() * (spawnBottom - spawnTop);
                    
                    objects.push({
                        id: `obj_${Date.now()}_${i}`,
                        type,
                        x,
                        y,
                        size: smallerSize,
                        consumed: false,
                        falling: false,
                        fallProgress: 0,
                        vx: 0,
                        vy: 0,
                        directionChangeTimer: 0
                    });
                }
            }
            
            return objects;
        }
        
        // Initialize level
        // Initialize level
        function initLevel() {
            const config = window.gameConfig;
            const gardenSize = config.gardenSize || 1500;
            
            // Initialize camera to center of garden (static position)
            camera.x = (gardenSize - CANVAS_WIDTH) / 2;
            camera.y = (gardenSize - CANVAS_HEIGHT) / 2;
            
            // Reset hole to center of visible area
            hole = {
                x: gardenSize / 2,
                y: gardenSize / 2,
                size: config.holeStartSize || 80,
                targetSize: config.holeStartSize || 80,
                rotation: 0
            };
            
            // Initialize objects from config or generate
            if (config.objects && config.objects.length > 0) {
                objects = config.objects.map(obj => ({
                    ...obj,
                    consumed: false,
                    falling: false,
                    fallProgress: 0,
                    vx: 0, // Objects start completely still
                    vy: 0,
                    directionChangeTimer: 0
                }));
            } else {
                const count = 20 + Math.floor(config.currentLevel / 2);
                objects = generateLevelObjects(config.theme, Math.min(count, 40));
                config.objects = objects.map(obj => ({
                    id: obj.id,
                    type: obj.type,
                    x: obj.x,
                    y: obj.y,
                    size: obj.size
                }));
            }
            
            consumedCount = 0;
            isLevelComplete = false;
            isTimeUp = false;
            levelStartTime = Date.now();
            timeRemaining = config.levelTimeLimit || 60;
            
            lib.log(`Level initialized with ${objects.length} objects to consume`);
            
            // Update UI
            updateLevelInfo();
            updateProgress();
            updateTimer();
            
            // Hide level complete screen
            hideModal();
        }
        
        // Update level info display
        function updateLevelInfo() {
            const config = window.gameConfig;
            const themeData = THEMES[config.theme];
            document.getElementById('levelInfo').textContent = 
                `Level ${config.currentLevel} - ${themeData.name}`;
        }
        
        // Update progress bar
        function updateProgress() {
            const total = objects.length;
            const remaining = objects.filter(obj => !obj.consumed).length;
            const consumed = total - remaining;
            
            const progressText = document.getElementById('progressText');
            progressText.textContent = `🍽️ ${consumed} / ${total}`;
            
            // Add pulse animation
            const progressBar = document.getElementById('progressBar');
            progressBar.classList.add('progress-pulse');
            setTimeout(() => progressBar.classList.remove('progress-pulse'), 300);
        }
        
        // Update timer display
        function updateTimer() {
            const timerDisplay = document.getElementById('timerDisplay');
            const seconds = Math.max(0, Math.ceil(timeRemaining));
            timerDisplay.textContent = `⏱️ ${seconds}s`;
            
            // Update color based on remaining time
            timerDisplay.classList.remove('warning', 'danger');
            if (timeRemaining <= 10) {
                timerDisplay.classList.add('danger');
            } else if (timeRemaining <= 20) {
                timerDisplay.classList.add('warning');
            }
        }
        
        // Update camera to follow hole
        // Update camera to follow hole
        function updateCamera() {
            // KEEP CAMERA STATIC - don't follow the hole
            // This keeps the ground still and peaceful
            const gardenSize = window.gameConfig.gardenSize || 1500;
            
            // Center camera on the garden center, not the hole
            camera.x = (gardenSize - CANVAS_WIDTH) / 2;
            camera.y = (gardenSize - CANVAS_HEIGHT) / 2;
            
            // Clamp camera to world bounds
            camera.x = Math.max(0, Math.min(camera.x, gardenSize - CANVAS_WIDTH));
            camera.y = Math.max(0, Math.min(camera.y, gardenSize - CANVAS_HEIGHT));
        }
        
        // Draw ground
        function drawGround() {
            const gardenSize = window.gameConfig.gardenSize || 1500;
            const theme = window.gameConfig.theme;
            const bgColor = THEMES[theme].bgColor;
            
            // Fill background color
            ctx.fillStyle = bgColor;
            ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
            
            // Draw grass texture tiled
            const grassTexture = assetCache['grass_texture'];
            if (grassTexture && grassTexture.img.complete) {
                const tileSize = 256;
                const startX = Math.floor(camera.x / tileSize) * tileSize;
                const startY = Math.floor(camera.y / tileSize) * tileSize;
                
                ctx.globalAlpha = 0.6;
                for (let x = startX; x < camera.x + CANVAS_WIDTH; x += tileSize) {
                    for (let y = startY; y < camera.y + CANVAS_HEIGHT; y += tileSize) {
                        ctx.drawImage(
                            grassTexture.img,
                            x - camera.x,
                            y - camera.y,
                            tileSize,
                            tileSize
                        );
                    }
                }
                ctx.globalAlpha = 1.0;
            }
            
            // Draw world boundary
            ctx.strokeStyle = 'rgba(0, 0, 0, 0.3)';
            ctx.lineWidth = 4;
            ctx.strokeRect(-camera.x, -camera.y, gardenSize, gardenSize);
        }
        
        // Draw object with shadow
        function drawObject(obj) {
    const asset = assetCache[obj.type];
    if (!asset || !asset.img.complete) return;
    
    const sizeRange = SIZE_CATEGORIES[obj.size];
    const objSize = (sizeRange.min + sizeRange.max) / 2;
    
    // Calculate screen position
    const screenX = obj.x - camera.x;
    const screenY = obj.y - camera.y;
    
    // Skip if off screen
    if (screenX < -objSize || screenX > CANVAS_WIDTH + objSize ||
        screenY < -objSize || screenY > CANVAS_HEIGHT + objSize) {
        return;
    }
    
    ctx.save();
    ctx.translate(screenX, screenY);
    
    // Apply falling animation
    if (obj.falling) {
        // Smooth easing for fall
        const easeProgress = obj.fallProgress * obj.fallProgress * (3 - 2 * obj.fallProgress);
        
        // Scale down as it falls
        const scale = 1 - easeProgress * 0.9;
        ctx.scale(scale, scale);
        
        // Fade out
        ctx.globalAlpha = Math.max(0, 1 - easeProgress * 1.5);
        
        // Spin as it falls
        ctx.rotate(easeProgress * Math.PI * 3);
    } else {
        // Draw shadow for non-falling objects - softer for soothing aesthetic
        ctx.fillStyle = 'rgba(0, 0, 0, 0.25)'; // Reduced from 0.4 to 0.25
        ctx.beginPath();
        ctx.ellipse(0, objSize * 0.4, objSize * 0.5, objSize * 0.15, 0, 0, Math.PI * 2);
        ctx.fill();
    }
    
    // Draw object
    const aspectRatio = asset.info.aspect_ratio || [1, 1];
    const imgWidth = objSize;
    const imgHeight = objSize * (aspectRatio[1] / aspectRatio[0]);
    
    ctx.drawImage(
        asset.img,
        -imgWidth / 2,
        -imgHeight / 2,
        imgWidth,
        imgHeight
    );
    
    // Draw selection indicator in edit mode
    if (currentMode === 'edit' && selectedObject === obj && !obj.falling) {
        ctx.strokeStyle = '#4CAF50';
        ctx.lineWidth = 3;
        ctx.strokeRect(-objSize/2 - 5, -objSize/2 - 5, objSize + 10, objSize + 10);
    }
    
    ctx.restore();
}
        
        // Draw hole
        // Draw hole
        function drawHole() {
    const screenX = hole.x - camera.x;
    const screenY = hole.y - camera.y;
    
    ctx.save();
    ctx.translate(screenX, screenY);
    
    // Draw shadow/ground around hole for depth
    ctx.beginPath();
    ctx.arc(0, 0, hole.size / 2 + 12, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
    ctx.fill();
    
    // Draw the hole rim (brown edge)
    ctx.beginPath();
    ctx.arc(0, 0, hole.size / 2 + 6, 0, Math.PI * 2);
    ctx.fillStyle = '#8B4513';
    ctx.fill();
    
    // Draw inner rim gradient for 3D depth
    const rimGradient = ctx.createRadialGradient(0, 0, hole.size / 2 - 5, 0, 0, hole.size / 2 + 6);
    rimGradient.addColorStop(0, '#654321');
    rimGradient.addColorStop(0.5, '#8B4513');
    rimGradient.addColorStop(1, '#A0826D');
    
    ctx.beginPath();
    ctx.arc(0, 0, hole.size / 2 + 6, 0, Math.PI * 2);
    ctx.fillStyle = rimGradient;
    ctx.fill();
    
    // Draw the actual hole (black void with gradient)
    const holeGradient = ctx.createRadialGradient(0, 0, 0, 0, 0, hole.size / 2);
    holeGradient.addColorStop(0, '#000000');
    holeGradient.addColorStop(0.7, '#0a0a0a');
    holeGradient.addColorStop(0.9, '#1a1a1a');
    holeGradient.addColorStop(1, '#2a2a2a');
    
    ctx.beginPath();
    ctx.arc(0, 0, hole.size / 2, 0, Math.PI * 2);
    ctx.fillStyle = holeGradient;
    ctx.fill();
    
    // Draw swirling vortex effect inside
    ctx.save();
    ctx.rotate(hole.rotation);
    ctx.globalAlpha = 0.3;
    
    for (let i = 0; i < 3; i++) {
        const angle = (i * Math.PI * 2 / 3);
        const spiralGradient = ctx.createRadialGradient(0, 0, 0, 0, 0, hole.size / 2);
        spiralGradient.addColorStop(0, 'rgba(60, 60, 60, 0)');
        spiralGradient.addColorStop(0.5, 'rgba(60, 60, 60, 0.5)');
        spiralGradient.addColorStop(1, 'rgba(60, 60, 60, 0)');
        
        ctx.save();
        ctx.rotate(angle);
        ctx.fillStyle = spiralGradient;
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.arc(0, 0, hole.size / 2, 0, Math.PI * 0.8);
        ctx.closePath();
        ctx.fill();
        ctx.restore();
    }
    
    ctx.restore();
    
    // Draw highlight on rim for 3D effect
    ctx.globalAlpha = 0.4;
    ctx.strokeStyle = '#C4A57B';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(-hole.size * 0.1, -hole.size * 0.1, hole.size / 2 + 4, Math.PI, Math.PI * 1.5);
    ctx.stroke();
    
    ctx.restore();
}
        
        // Check collision between hole and object
        function checkCollision(obj) {
    if (obj.consumed || obj.falling) return false;
    
    const sizeRange = SIZE_CATEGORIES[obj.size];
    const objSize = (sizeRange.min + sizeRange.max) / 2;
    
    // Calculate distance from object center to hole center
    const dx = obj.x - hole.x;
    const dy = obj.y - hole.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    
    // Object is consumed when its center gets close enough to hole center
    // The hole needs to be bigger than the object for it to fall in
    const holeRadius = hole.size / 2;
    const objRadius = objSize / 2;
    
    // Object falls in when hole is big enough and object is close to center
    if (holeRadius > objRadius * 0.8) {
        // Hole is big enough - check if object center is inside hole
        return dist < holeRadius * 0.7;
    } else {
        // Hole is too small for this object
        return false;
    }
}
        
        // Consume object
        function consumeObject(obj) {
    // Prevent consuming the same object twice
    if (obj.falling || obj.consumed) {
        return;
    }
    
    obj.falling = true;
    obj.fallProgress = 0;
    obj.startX = obj.x;
    obj.startY = obj.y;
    
    // Play gulp sound
    playSound('gulp_sound');
    
    // Grow hole based on object size
    const sizeRange = SIZE_CATEGORIES[obj.size];
    const objSize = (sizeRange.min + sizeRange.max) / 2;
    
    // Bigger objects make the hole grow more
    let growthAmount;
    switch(obj.size) {
        case 'tiny': growthAmount = hole.size * 0.04; break;
        case 'small': growthAmount = hole.size * 0.05; break;
        case 'medium': growthAmount = hole.size * 0.07; break;
        case 'large': growthAmount = hole.size * 0.10; break;
        default: growthAmount = hole.size * 0.05;
    }
    
    const maxSize = (window.gameConfig.holeStartSize || 80) * (window.gameConfig.holeMaxMultiplier || 3);
    hole.targetSize = Math.min(hole.targetSize + growthAmount, maxSize);
    
    // Play grow sound
    playSound('hole_grow_sound');
    
    lib.log(`Object ${obj.type} consumed. Total: ${consumedCount + 1} / ${objects.length}`);
}
        
        // Update play mode
        function updatePlay(deltaTime) {
    if (isLevelComplete || isTimeUp) return;
    
    // Update timer
    timeRemaining -= deltaTime;
    updateTimer();
    
    // Check if time is up
    if (timeRemaining <= 0) {
        isTimeUp = true;
        timeOut();
        return;
    }
    
    const gardenSize = window.gameConfig.gardenSize || 1500;
    
    // Handle input - DIRECT FOLLOWING for smooth movement
    let targetX = hole.x;
    let targetY = hole.y;
    let hasInput = false;
    
    // Touch/mouse input - direct following
    if (touchPos) {
        targetX = touchPos.x;
        targetY = touchPos.y;
        hasInput = true;
    }
    
    // Keyboard input - velocity-based movement
    if (keys['ArrowUp'] || keys['w'] || keys['W'] || 
        keys['ArrowDown'] || keys['s'] || keys['S'] ||
        keys['ArrowLeft'] || keys['a'] || keys['A'] ||
        keys['ArrowRight'] || keys['d'] || keys['D']) {
        
        const moveSpeed = 600; // pixels per second for keyboard
        let inputX = 0, inputY = 0;
        
        if (keys['ArrowUp'] || keys['w'] || keys['W']) inputY -= 1;
        if (keys['ArrowDown'] || keys['s'] || keys['S']) inputY += 1;
        if (keys['ArrowLeft'] || keys['a'] || keys['A']) inputX -= 1;
        if (keys['ArrowRight'] || keys['d'] || keys['D']) inputX += 1;
        
        // Normalize diagonal movement
        if (inputX !== 0 && inputY !== 0) {
            const len = Math.sqrt(inputX * inputX + inputY * inputY);
            inputX /= len;
            inputY /= len;
        }
        
        targetX = hole.x + inputX * moveSpeed * deltaTime;
        targetY = hole.y + inputY * moveSpeed * deltaTime;
        hasInput = true;
    }
    
    // Smooth interpolation to target position - more responsive for better control
    if (hasInput) {
        const lerpFactor = 0.18; // Reduced from 0.25 for smoother, more zen-like movement
        hole.x += (targetX - hole.x) * lerpFactor;
        hole.y += (targetY - hole.y) * lerpFactor;
    }
    
    // Clamp to world bounds
    const holeRadius = hole.size / 2;
    hole.x = Math.max(holeRadius, Math.min(hole.x, gardenSize - holeRadius));
    hole.y = Math.max(holeRadius, Math.min(hole.y, gardenSize - holeRadius));
    
    // Smooth hole size growth with slower, more satisfying interpolation
    if (hole.size < hole.targetSize) {
        hole.size += (hole.targetSize - hole.size) * 0.08; // Reduced from 0.15 to 0.08 for slower growth
        // Snap to target if very close
        if (Math.abs(hole.targetSize - hole.size) < 0.3) {
            hole.size = hole.targetSize;
        }
    }
    
    // Update hole rotation - slower for calmer feel
    hole.rotation += deltaTime * 1.2; // Reduced from 2 to 1.2
    
    // Update objects
    for (const obj of objects) {
        if (obj.falling) {
            obj.fallProgress += deltaTime * 1.2; // Slightly slower fall for more satisfaction
            
            // Smooth easing function for falling into hole
            const easeProgress = obj.fallProgress * obj.fallProgress * (3 - 2 * obj.fallProgress); // Smoothstep
            
            // Move toward hole center with easing
            obj.x = obj.startX + (hole.x - obj.startX) * easeProgress;
            obj.y = obj.startY + (hole.y - obj.startY) * easeProgress;
            
            if (obj.fallProgress >= 1) {
                obj.consumed = true;
                consumedCount++;
                updateProgress();
            }
        } else if (!obj.consumed) {
            // Calculate distance to hole
            const dx = hole.x - obj.x;
            const dy = hole.y - obj.y;
            const dist = Math.sqrt(dx * dx + dy * dy);
            
            // Define zones
            const panicRadius = hole.size * 3.5; // Close danger zone - objects panic and scatter
            const attractionRadius = hole.size * 8.0; // Medium range - strong magnetic pull
            
            if (dist < panicRadius && dist > 0) {
                // PANIC ZONE: Objects detected the hole is too close, scatter away!
                const angle = Math.atan2(dy, dx);
                const panicStrength = 1 - (dist / panicRadius); // Stronger panic when closer
                const escapeForce = panicStrength * panicStrength * 1200; // Strong escape impulse
                
                // Push away from hole
                obj.vx -= Math.cos(angle) * escapeForce * deltaTime;
                obj.vy -= Math.sin(angle) * escapeForce * deltaTime;
                
                // Add random jitter to create unpredictable scatter
                obj.vx += (Math.random() - 0.5) * 800 * deltaTime;
                obj.vy += (Math.random() - 0.5) * 800 * deltaTime;
                
                // Limit escape velocity
                const maxVel = 900;
                const vel = Math.sqrt(obj.vx * obj.vx + obj.vy * obj.vy);
                if (vel > maxVel) {
                    obj.vx = (obj.vx / vel) * maxVel;
                    obj.vy = (obj.vy / vel) * maxVel;
                }
                
                // Apply drag
                obj.vx *= 0.92;
                obj.vy *= 0.92;
                
                // Update position
                obj.x += obj.vx * deltaTime;
                obj.y += obj.vy * deltaTime;
                
            } else if (dist < attractionRadius && dist > 0) {
                // ATTRACTION ZONE: Initial strong magnetic pull
                const attractionStrength = 1 - (dist / attractionRadius);
                const magneticForce = attractionStrength * attractionStrength * 1600;
                
                const angle = Math.atan2(dy, dx);
                obj.vx += Math.cos(angle) * magneticForce * deltaTime;
                obj.vy += Math.sin(angle) * magneticForce * deltaTime;
                
                // Limit velocity during attraction
                const maxVel = 1200;
                const vel = Math.sqrt(obj.vx * obj.vx + obj.vy * obj.vy);
                if (vel > maxVel) {
                    obj.vx = (obj.vx / vel) * maxVel;
                    obj.vy = (obj.vy / vel) * maxVel;
                }
                
                // Apply drag
                obj.vx *= 0.94;
                obj.vy *= 0.94;
                
                // Update position
                obj.x += obj.vx * deltaTime;
                obj.y += obj.vy * deltaTime;
                
            } else {
                // NEUTRAL ZONE: Objects drift naturally and slow down
                obj.vx *= 0.88; // Natural deceleration
                obj.vy *= 0.88;
                
                // Stop completely if moving very slowly
                if (Math.abs(obj.vx) < 1) obj.vx = 0;
                if (Math.abs(obj.vy) < 1) obj.vy = 0;
                
                // Update position if there's velocity
                if (obj.vx !== 0 || obj.vy !== 0) {
                    obj.x += obj.vx * deltaTime;
                    obj.y += obj.vy * deltaTime;
                }
            }
            
            // Keep objects FULLY visible within viewport - no partial visibility allowed
            const sizeRange = SIZE_CATEGORIES[obj.size];
            const objSize = (sizeRange.min + sizeRange.max) / 2;
            const objRadius = objSize / 2;
            
            // Define visible play area - objects must stay fully within viewport
            // No padding - we want objects to stay completely visible
            const playLeft = camera.x + objRadius;
            const playRight = camera.x + CANVAS_WIDTH - objRadius;
            const playTop = camera.y + objRadius;
            const playBottom = camera.y + CANVAS_HEIGHT - objRadius;
            
            // Strong boundary forces - push objects back firmly when they approach edges
            const boundaryForce = 800; // Strong force to keep objects fully visible
            const boundaryMargin = objRadius + 40; // Start applying force near the edge
            
            // Left boundary
            if (obj.x < playLeft + boundaryMargin) {
                const penetration = Math.max(0, (playLeft + boundaryMargin - obj.x) / boundaryMargin);
                obj.vx += boundaryForce * penetration * deltaTime;
            }
            // Right boundary
            if (obj.x > playRight - boundaryMargin) {
                const penetration = Math.max(0, (obj.x - (playRight - boundaryMargin)) / boundaryMargin);
                obj.vx -= boundaryForce * penetration * deltaTime;
            }
            // Top boundary
            if (obj.y < playTop + boundaryMargin) {
                const penetration = Math.max(0, (playTop + boundaryMargin - obj.y) / boundaryMargin);
                obj.vy += boundaryForce * penetration * deltaTime;
            }
            // Bottom boundary
            if (obj.y > playBottom - boundaryMargin) {
                const penetration = Math.max(0, (obj.y - (playBottom - boundaryMargin)) / boundaryMargin);
                obj.vy -= boundaryForce * penetration * deltaTime;
            }
            
            // Hard clamps to ensure objects never go partially off-screen
            obj.x = Math.max(playLeft, Math.min(obj.x, playRight));
            obj.y = Math.max(playTop, Math.min(obj.y, playBottom));
            
            // Simple collision avoidance with other objects (only when not being sucked)
            if (dist > attractionRadius * 0.5) {
                for (const other of objects) {
                    if (other === obj || other.consumed || other.falling) continue;
                    
                    const otherSize = (SIZE_CATEGORIES[other.size].min + SIZE_CATEGORIES[other.size].max) / 2;
                    const dx2 = other.x - obj.x;
                    const dy2 = other.y - obj.y;
                    const dist2 = Math.sqrt(dx2 * dx2 + dy2 * dy2);
                    const minDist = (objSize + otherSize) / 2 + 10;
                    
                    if (dist2 < minDist && dist2 > 0) {
                        // Push apart gently
                        const angle = Math.atan2(dy2, dx2);
                        const pushForce = (minDist - dist2) * 0.3; // Reduced from 0.5 to 0.3
                        obj.x -= Math.cos(angle) * pushForce;
                        obj.y -= Math.sin(angle) * pushForce;
                    }
                }
            }
            
            // Check collision with hole
            if (checkCollision(obj)) {
                consumeObject(obj);
            }
        }
    }
    
    // Check level completion - verify ALL objects are actually consumed
    if (!isLevelComplete && objects.length > 0) {
        const allConsumed = objects.every(obj => obj.consumed);
        const activeObjects = objects.filter(obj => !obj.consumed);
        
        if (allConsumed && activeObjects.length === 0) {
            lib.log(`Level complete! Consumed ${consumedCount} of ${objects.length} objects`);
            isLevelComplete = true;
            completeLevel();
        }
    }
    
    // Update camera
    updateCamera();
}
        
        // Show modal with animation
        function showModal() {
            const backdrop = document.getElementById('modalBackdrop');
            const modal = document.getElementById('levelComplete');
            
            backdrop.classList.add('visible');
            modal.classList.add('visible');
        }
        
        // Hide modal with animation
        function hideModal() {
            const backdrop = document.getElementById('modalBackdrop');
            const modal = document.getElementById('levelComplete');
            
            backdrop.classList.remove('visible');
            modal.classList.remove('visible');
        }
        
        // Complete level
        function completeLevel() {
            // Play completion sound
            playSound('level_complete');
            
            // Stop background music
            if (backgroundMusicSource) {
                backgroundMusicSource.stop();
                backgroundMusicSource = null;
            }
            
            // Calculate stats
            const timeElapsed = Math.floor((Date.now() - levelStartTime) / 1000);
            const minutes = Math.floor(timeElapsed / 60);
            const seconds = timeElapsed % 60;
            
            // Show completion screen
            document.getElementById('completeStats').textContent = 
                `Time: ${minutes}:${seconds.toString().padStart(2, '0')}`;
            showModal();
            
            // Save progress
            const userData = lib.getUserGameState() || {};
            userData.highestLevel = Math.max(userData.highestLevel || 1, window.gameConfig.currentLevel);
            lib.saveUserGameState(userData);
        }
        
        // Time up - level failed
        function timeOut() {
            // Stop background music
            if (backgroundMusicSource) {
                backgroundMusicSource.stop();
                backgroundMusicSource = null;
            }
            
            // Show time up screen
            document.getElementById('levelComplete').querySelector('h2').textContent = '⏰ Time\'s Up!';
            document.getElementById('completeStats').textContent = 
                `You collected ${consumedCount} / ${objects.length} items`;
            document.getElementById('nextLevelBtn').textContent = 'Try Again';
            showModal();
        }
        
        // Next level
        function nextLevel() {
            // Reset button text in case it was changed to "Try Again"
            document.getElementById('nextLevelBtn').textContent = 'Next Level';
            document.getElementById('levelComplete').querySelector('h2').textContent = '🎉 Level Complete!';
            
            // If time ran out, restart the same level
            if (isTimeUp) {
                initLevel();
            } else {
                // Increment level
                window.gameConfig.currentLevel++;
                
                // Cycle through themes
                const themeKeys = Object.keys(THEMES);
                const themeIndex = (window.gameConfig.currentLevel - 1) % themeKeys.length;
                window.gameConfig.theme = themeKeys[themeIndex];
                
                // Generate new level with more objects - better progression
                const count = 20 + Math.floor(window.gameConfig.currentLevel * 1.5);
                window.gameConfig.objects = generateLevelObjects(
                    window.gameConfig.theme,
                    Math.min(count, 50)
                );
                
                // Restart level
                initLevel();
            }
            
            // Restart background music
            if (currentMode === 'play') {
                backgroundMusicSource = playSound('background_music', true);
            }
        }
        
        // Toggle edit drawer
        function toggleEditDrawer() {
            isEditDrawerOpen = !isEditDrawerOpen;
            
            const backdrop = document.getElementById('editDrawerBackdrop');
            const drawer = document.getElementById('editDrawer');
            
            if (isEditDrawerOpen) {
                backdrop.classList.add('visible');
                drawer.classList.add('visible');
            } else {
                backdrop.classList.remove('visible');
                drawer.classList.remove('visible');
            }
        }
        
        // Update edit mode
        function updateEdit(deltaTime) {
            // Edit mode is mostly event-driven, minimal updates needed
        }
        
        // Render game
        function render() {
    // Clear canvas
    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    
    // Draw ground
    drawGround();
    
    // Draw hole FIRST (so objects appear on top)
    drawHole();
    
    // Sort objects by y position for depth
    const sortedObjects = [...objects].sort((a, b) => {
        // Falling objects should be drawn last (on top)
        if (a.falling && !b.falling) return 1;
        if (!a.falling && b.falling) return -1;
        return a.y - b.y;
    });
    
    // Draw objects
    for (const obj of sortedObjects) {
        if (!obj.consumed) {
            drawObject(obj);
        }
    }
}
        
        // Main game loop
        function gameLoopFunc(timestamp) {
            const deltaTime = Math.min((timestamp - lastTime) / 1000, 0.11);
            lastTime = timestamp;
            
            if (currentMode === 'play') {
                updatePlay(deltaTime);
            } else {
                updateEdit(deltaTime);
            }
            
            render();
            
            gameLoop = requestAnimationFrame(gameLoopFunc);
        }
        
        // Setup edit mode UI
        function setupEditMode() {
            const editFab = document.getElementById('editFab');
            editFab.classList.remove('hidden');
            
            // Theme select
            const themeSelect = document.getElementById('themeSelect');
            themeSelect.value = window.gameConfig.theme;
            themeSelect.onchange = () => {
                window.gameConfig.theme = themeSelect.value;
                updateLevelInfo();
                
                // Regenerate objects with new theme
                const count = window.gameConfig.objects.length;
                window.gameConfig.objects = generateLevelObjects(window.gameConfig.theme, count);
                initLevel();
                setupObjectPalette();
            };
            
            // Object count slider
            const objectCountSlider = document.getElementById('objectCountSlider');
            const objectCountLabel = document.getElementById('objectCountLabel');
            objectCountSlider.value = window.gameConfig.objects.length;
            objectCountLabel.textContent = objectCountSlider.value;
            objectCountSlider.oninput = () => {
                objectCountLabel.textContent = objectCountSlider.value;
            };
            objectCountSlider.onchange = () => {
                const count = parseInt(objectCountSlider.value);
                window.gameConfig.objects = generateLevelObjects(window.gameConfig.theme, count);
                initLevel();
            };
            
            // Hole size slider
            const holeSizeSlider = document.getElementById('holeSizeSlider');
            const holeSizeLabel = document.getElementById('holeSizeLabel');
            holeSizeSlider.value = window.gameConfig.holeStartSize;
            holeSizeLabel.textContent = holeSizeSlider.value;
            holeSizeSlider.oninput = () => {
                holeSizeLabel.textContent = holeSizeSlider.value;
            };
            holeSizeSlider.onchange = () => {
                window.gameConfig.holeStartSize = parseInt(holeSizeSlider.value);
                hole.size = window.gameConfig.holeStartSize;
                hole.targetSize = window.gameConfig.holeStartSize;
            };
            
            // Hole multiplier slider
            const holeMultSlider = document.getElementById('holeMultSlider');
            const holeMultLabel = document.getElementById('holeMultLabel');
            holeMultSlider.value = window.gameConfig.holeMaxMultiplier;
            holeMultLabel.textContent = holeMultSlider.value.toFixed(1);
            holeMultSlider.oninput = () => {
                holeMultLabel.textContent = parseFloat(holeMultSlider.value).toFixed(1);
            };
            holeMultSlider.onchange = () => {
                window.gameConfig.holeMaxMultiplier = parseFloat(holeMultSlider.value);
            };
            
            // Time limit slider
            const timeLimitSlider = document.getElementById('timeLimitSlider');
            const timeLimitLabel = document.getElementById('timeLimitLabel');
            timeLimitSlider.value = window.gameConfig.levelTimeLimit || 60;
            timeLimitLabel.textContent = timeLimitSlider.value;
            timeLimitSlider.oninput = () => {
                timeLimitLabel.textContent = timeLimitSlider.value;
            };
            timeLimitSlider.onchange = () => {
                window.gameConfig.levelTimeLimit = parseInt(timeLimitSlider.value);
                timeRemaining = window.gameConfig.levelTimeLimit;
                updateTimer();
            };
            
            // Random generate button
            document.getElementById('randomGenBtn').onclick = () => {
                const count = parseInt(objectCountSlider.value);
                window.gameConfig.objects = generateLevelObjects(window.gameConfig.theme, count);
                initLevel();
            };
            
            // Test level button
            document.getElementById('testLevelBtn').onclick = () => {
                toggleEditDrawer();
                // Switch to play mode temporarily
                currentMode = 'play';
                setupPlayMode();
            };
            
            // Clear all button
            document.getElementById('clearAllBtn').onclick = () => {
                window.gameConfig.objects = [];
                initLevel();
            };
            
            // Setup object palette
            setupObjectPalette();
        }
        
        // Setup object palette
        function setupObjectPalette() {
            const palette = document.getElementById('objectPalette');
            palette.innerHTML = '';
            
            const themeData = THEMES[window.gameConfig.theme];
            
            for (const objType of themeData.objects) {
                const item = document.createElement('div');
                item.className = 'palette-item';
                
                const asset = assetCache[objType];
                if (asset && asset.img.complete) {
                    const img = document.createElement('img');
                    img.src = asset.img.src;
                    item.appendChild(img);
                }
                
                item.onclick = () => {
                    // Add object at center of screen
                    const gardenSize = window.gameConfig.gardenSize || 1500;
                    const newObj = {
                        id: `obj_${Date.now()}`,
                        type: objType,
                        x: camera.x + CANVAS_WIDTH / 2,
                        y: camera.y + CANVAS_HEIGHT / 2,
                        size: 'small'
                    };
                    
                    window.gameConfig.objects.push(newObj);
                    initLevel();
                };
                
                palette.appendChild(item);
            }
        }
        
        // Cleanup edit mode
        function cleanupEditMode() {
            const editFab = document.getElementById('editFab');
            editFab.classList.add('hidden');
            
            // Close drawer if open
            if (isEditDrawerOpen) {
                toggleEditDrawer();
            }
            
            selectedObject = null;
            isDragging = false;
            lib.editMenu.close();
        }
        
        // Handle canvas click/touch for edit mode
        function handleEditClick(x, y) {
            if (currentMode !== 'edit') return;
            
            // Convert screen to world coordinates
            const worldX = x + camera.x;
            const worldY = y + camera.y;
            
            // Check if clicked on an object
            let clickedObject = null;
            for (const obj of objects) {
                const sizeRange = SIZE_CATEGORIES[obj.size];
                const objSize = (sizeRange.min + sizeRange.max) / 2;
                
                const dx = worldX - obj.x;
                const dy = worldY - obj.y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                
                if (dist < objSize / 2) {
                    clickedObject = obj;
                    break;
                }
            }
            
            if (clickedObject) {
                selectedObject = clickedObject;
                
                // Show edit menu
                lib.editMenu.open({
                    name: clickedObject.type.replace('_', ' ').toUpperCase(),
                    params: {
                        'Size': {
                            key: `gameConfig.objects.${objects.indexOf(clickedObject)}.size`,
                            type: 'dropdown',
                            options: [
                                { label: 'Tiny', value: 'tiny' },
                                { label: 'Small', value: 'small' },
                                { label: 'Medium', value: 'medium' },
                                { label: 'Large', value: 'large' }
                            ],
                            onChange: (value) => {
                                clickedObject.size = value;
                                const idx = objects.indexOf(clickedObject);
                                if (idx >= 0) {
                                    window.gameConfig.objects[idx].size = value;
                                }
                            }
                        }
                    },
                    onCopy: () => {
                        const newObj = {
                            ...clickedObject,
                            id: `obj_${Date.now()}`,
                            x: clickedObject.x + 50,
                            y: clickedObject.y + 50
                        };
                        window.gameConfig.objects.push(newObj);
                        initLevel();
                    },
                    onDelete: () => {
                        const idx = objects.indexOf(clickedObject);
                        if (idx >= 0) {
                            window.gameConfig.objects.splice(idx, 1);
                            initLevel();
                        }
                        lib.editMenu.close();
                        selectedObject = null;
                    }
                });
            } else {
                selectedObject = null;
                lib.editMenu.close();
            }
        }
        
        // Handle canvas drag for edit mode
        function handleEditDrag(x, y) {
            if (currentMode !== 'edit' || !selectedObject) return;
            
            // Convert screen to world coordinates
            const worldX = x + camera.x;
            const worldY = y + camera.y;
            
            // Update object position
            selectedObject.x = worldX;
            selectedObject.y = worldY;
            
            // Update config
            const idx = objects.indexOf(selectedObject);
            if (idx >= 0) {
                window.gameConfig.objects[idx].x = worldX;
                window.gameConfig.objects[idx].y = worldY;
            }
        }
        
        // Setup input handlers
        function setupInput() {
            // Detect touch device
            isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
            
            // Keyboard
            window.addEventListener('keydown', (e) => {
                keys[e.key] = true;
                initAudio(); // Initialize audio on any key press
            });
            
            window.addEventListener('keyup', (e) => {
                keys[e.key] = false;
            });
            
            // Mouse/Touch on canvas
            canvas.addEventListener('mousedown', (e) => {
                // ALWAYS try to initialize audio on ANY interaction
                initAudio();
                
                const rect = canvas.getBoundingClientRect();
                const x = (e.clientX - rect.left) * (CANVAS_WIDTH / rect.width);
                const y = (e.clientY - rect.top) * (CANVAS_HEIGHT / rect.height);
                
                if (currentMode === 'edit') {
                    handleEditClick(x, y);
                    isDragging = true;
                } else {
                    touchPos = { x: x + camera.x, y: y + camera.y };
                }
            });
            
            canvas.addEventListener('mousemove', (e) => {
                const rect = canvas.getBoundingClientRect();
                const x = (e.clientX - rect.left) * (CANVAS_WIDTH / rect.width);
                const y = (e.clientY - rect.top) * (CANVAS_HEIGHT / rect.height);
                
                if (currentMode === 'edit' && isDragging) {
                    handleEditDrag(x, y);
                } else if (currentMode === 'play' && touchPos) {
                    touchPos = { x: x + camera.x, y: y + camera.y };
                }
            });
            
            canvas.addEventListener('mouseup', () => {
                if (currentMode === 'edit') {
                    isDragging = false;
                } else {
                    touchPos = null;
                }
            });
            
            canvas.addEventListener('mouseleave', () => {
                if (currentMode === 'edit') {
                    isDragging = false;
                } else {
                    touchPos = null;
                }
            });
            
            // Touch events
            canvas.addEventListener('touchstart', (e) => {
                e.preventDefault();
                // ALWAYS try to initialize audio on ANY interaction
                initAudio();
                
                const rect = canvas.getBoundingClientRect();
                const touch = e.touches[0];
                const x = (touch.clientX - rect.left) * (CANVAS_WIDTH / rect.width);
                const y = (touch.clientY - rect.top) * (CANVAS_HEIGHT / rect.height);
                
                if (currentMode === 'edit') {
                    handleEditClick(x, y);
                    isDragging = true;
                } else {
                    touchPos = { x: x + camera.x, y: y + camera.y };
                }
            });
            
            canvas.addEventListener('touchmove', (e) => {
                e.preventDefault();
                const rect = canvas.getBoundingClientRect();
                const touch = e.touches[0];
                const x = (touch.clientX - rect.left) * (CANVAS_WIDTH / rect.width);
                const y = (touch.clientY - rect.top) * (CANVAS_HEIGHT / rect.height);
                
                if (currentMode === 'edit' && isDragging) {
                    handleEditDrag(x, y);
                } else if (currentMode === 'play') {
                    touchPos = { x: x + camera.x, y: y + camera.y };
                }
            });
            
            canvas.addEventListener('touchend', (e) => {
                e.preventDefault();
                if (currentMode === 'edit') {
                    isDragging = false;
                } else {
                    touchPos = null;
                }
            });
            
            // Next level button
            document.getElementById('nextLevelBtn').onclick = nextLevel;
            
            // Edit FAB
            document.getElementById('editFab').onclick = toggleEditDrawer;
            
            // Edit drawer backdrop
            document.getElementById('editDrawerBackdrop').onclick = toggleEditDrawer;
            
            // Modal backdrop
            document.getElementById('modalBackdrop').onclick = hideModal;
            
            // Audio toggle buttons
            const musicToggle = document.getElementById('musicToggle');
            const soundToggle = document.getElementById('soundToggle');
            // const loadConfigBtn = document.getElementById('loadConfigBtn');
            const configFileInput = document.getElementById('configFileInput');
            
            // Update button states
            function updateAudioButtons() {
                if (window.gameConfig.musicEnabled) {
                    musicToggle.classList.remove('disabled');
                    musicToggle.textContent = '🎵';
                } else {
                    musicToggle.classList.add('disabled');
                    musicToggle.textContent = '🔇';
                }
                
                if (window.gameConfig.soundEnabled) {
                    soundToggle.classList.remove('disabled');
                    soundToggle.textContent = '🔊';
                } else {
                    soundToggle.classList.add('disabled');
                    soundToggle.textContent = '🔈';
                }
            }
            
            // Music toggle
            musicToggle.onclick = () => {
                window.gameConfig.musicEnabled = !window.gameConfig.musicEnabled;
                updateAudioButtons();
                
                if (currentMode === 'play') {
                    if (window.gameConfig.musicEnabled) {
                        // Start music
                        if (!backgroundMusicSource) {
                            backgroundMusicSource = playSound('background_music', true);
                        }
                    } else {
                        // Stop music
                        if (backgroundMusicSource) {
                            backgroundMusicSource.stop();
                            backgroundMusicSource = null;
                        }
                    }
                }
            };
            
            // Sound toggle
            soundToggle.onclick = () => {
                window.gameConfig.soundEnabled = !window.gameConfig.soundEnabled;
                updateAudioButtons();
            };

            // // Load config button + file input
            // if (loadConfigBtn && configFileInput) {
            //     loadConfigBtn.onclick = () => configFileInput.click();
            //     configFileInput.addEventListener('change', async (e) => {
            //         const file = e.target.files && e.target.files[0];
            //         if (!file) return;
            //         try {
            //             await loadConfig(file);
            //             // Re-initialize level to apply loaded config
            //             initLevel();
            //             setupObjectPalette();
            //             updateLevelInfo();
            //             updateProgress();
            //             updateTimer();
            //             if (window.lib && window.lib.log) window.lib.log('Config loaded from file input');
            //         } catch (err) {
            //             console.warn('Error loading config file', err);
            //             alert('Failed to load config file: ' + (err && err.message ? err.message : err));
            //         } finally {
            //             // Clear input so same file can be re-selected
            //             configFileInput.value = '';
            //         }
            //     });
            // }
            
            // Initialize button states
            updateAudioButtons();
        }
        
        // Main run function
        async function run(mode) {
            lib.log('run() called. Mode: ' + mode);
            currentMode = mode;
            
            // Setup canvas
            canvas = document.getElementById('gameCanvas');
            ctx = canvas.getContext('2d');
            canvas.width = CANVAS_WIDTH;
            canvas.height = CANVAS_HEIGHT;
            
            // Show game parameters
            lib.showGameParameters({
                name: 'Game Settings',
                params: {
                    'Background Music': {
                        key: 'gameConfig.musicVolume',
                        type: 'slider',
                        min: 0,
                        max: 100,
                        step: 1,
                        onChange: (value) => {
                            window.gameConfig.musicVolume = value;
                            if (backgroundMusicSource && backgroundMusicSource.gainNode) {
                                backgroundMusicSource.gainNode.gain.value = value / 100 * 0.3;
                            }
                        }
                    },
                    'Sound Effects': {
                        key: 'gameConfig.soundVolume',
                        type: 'slider',
                        min: 0,
                        max: 100,
                        step: 1,
                        onChange: (value) => {
                            window.gameConfig.soundVolume = value;
                        }
                    }
                }
            });
            
            // Initialize config if needed
            // Attempt to load external config from URL param or localStorage
            await loadConfigFromLocation();
            if (!window.gameConfig.currentLevel) {
                window.gameConfig.currentLevel = 1;
            }
            if (!window.gameConfig.theme) {
                window.gameConfig.theme = 'fruit';
            }
            if (!window.gameConfig.holeStartSize) {
                window.gameConfig.holeStartSize = 80;
            }
            if (!window.gameConfig.holeMaxMultiplier) {
                window.gameConfig.holeMaxMultiplier = 3;
            }
            if (!window.gameConfig.gardenSize) {
                window.gameConfig.gardenSize = 1500;
            }
            if (!window.gameConfig.musicVolume) {
                window.gameConfig.musicVolume = 50;
            }
            if (!window.gameConfig.soundVolume) {
                window.gameConfig.soundVolume = 50;
            }
            if (window.gameConfig.musicEnabled === undefined) {
                window.gameConfig.musicEnabled = true;
            }
            if (window.gameConfig.soundEnabled === undefined) {
                window.gameConfig.soundEnabled = true;
            }
            if (!window.gameConfig.levelTimeLimit) {
                window.gameConfig.levelTimeLimit = 60;
            }
            
            // Preload assets
            await preloadAssets();
            
            // Setup input
            setupInput();
            
            // Initialize level
            initLevel();
            
            // Mode-specific setup
            if (mode === 'edit') {
                setupEditMode();
                cleanupPlayMode();
            } else {
                cleanupEditMode();
                setupPlayMode();
                
                // Try to start audio immediately (will work in most browsers)
                initAudio();
            }
            
            // Start game loop
            lastTime = performance.now();
            if (gameLoop) {
                cancelAnimationFrame(gameLoop);
            }
            gameLoop = requestAnimationFrame(gameLoopFunc);
            
            // Add a one-time click listener to the entire document to ensure audio starts
            const startAudioOnInteraction = () => {
                initAudio();
                document.removeEventListener('click', startAudioOnInteraction);
                document.removeEventListener('touchstart', startAudioOnInteraction);
            };
            document.addEventListener('click', startAudioOnInteraction);
            document.addEventListener('touchstart', startAudioOnInteraction);
        }
        
        // Setup play mode
        // Setup play mode
        function setupPlayMode() {
            // Ensure audio is ready and start background music
            if (audioContext.state === 'suspended') {
                // Audio context is suspended, will resume on first user interaction
                lib.log('🎵 Audio context suspended - will start on first interaction');
            } else {
                // Audio context is already running
                audioInitialized = true;
                if (!backgroundMusicSource) {
                    backgroundMusicSource = playSound('background_music', true);
                    lib.log('🎵 Background music started immediately!');
                }
            }
            
            lib.log('⏱️ Timer started: ' + (window.gameConfig.levelTimeLimit || 60) + ' seconds to complete the level!');
        }
        
        // Cleanup play mode
        function cleanupPlayMode() {
            // Stop background music
            if (backgroundMusicSource) {
                backgroundMusicSource.stop();
                backgroundMusicSource = null;
            }
        }
        
        // Expose run function
        // window.run = run;

        window.onload = function () {
            // Start the game initialization via run()
            try {
                run('play');
            } catch (e) {
                if (window.lib && window.lib.log) window.lib.log('Error during run(): ' + (e && e.message ? e.message : e));
                else console.error(e);
            }
        };


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
