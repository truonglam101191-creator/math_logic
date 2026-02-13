import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebEvolutionMerge extends StatefulWidget {
  const WebEvolutionMerge({super.key, this.onGameEnd});

  final void Function(int score)? onGameEnd;

  @override
  State<WebEvolutionMerge> createState() => _WebPackPalStubState();
}

class _WebPackPalStubState extends State<WebEvolutionMerge> {
  late InAppWebViewController _controller;
  bool _ready = false;
  bool _error = false;

  late final perferen = Shared.instance.sharedPreferences;

  final _kSavedGameStateKey = 'evolution_merge_game_state';

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
          'assets/evolution_merge/evolution_merge.html',
        );

        final config = await rootBundle.loadString(
          'assets/evolution_merge/config.json',
        );

        if (config.isNotEmpty) {
          html = html.replaceAll(
            '<script id="gameConfig"></script>',
            '<script id="gameConfig"> window.gameConfig = $config;</script>',
          );
        }

        final assets = await rootBundle.loadString(
          'assets/evolution_merge/assetMap.json',
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

  String get morefunctionLoadAniamtion => '''
    <script>
    (function(){
        if (window.lib) return;
        // parse assets map if present
        let _assets = {};
        try {
            const el = document.getElementById('assetsMap');
            _assets = el ? JSON.parse(el.textContent) : {};
        } catch (e) {
            _assets = {};
        }

        const _images = {};
        const _animCache = {};
        const LB_KEY = 'evo_merge_leaderboard_v1';
        const STATE_KEY = 'evo_merge_user_state_v1';

        function _getAsset(id){ return _assets[id] || null; }

        function _preloadAnimation(id){
            const info = _getAsset(id);
            if (!info) return;
            if (info.type === 'image' || info.type === 'animation') {
                const img = new Image();
                img.src = info.url;
                _images[id] = img;
                _animCache[id] = img;
            }
        }

        function _getAnimationPlayer(id, opts){
            const asset = _getAsset(id);
            if (!asset) return null;

            // ensure an Image is cached
            const img = _animCache[id] || (function(){ const a = asset; const i = new Image(); i.src = a.url; _animCache[id] = i; return i; })();
            if (!img) return null;

            function gcd(a,b){ a = Math.abs(a)|0; b = Math.abs(b)|0; while(b){ const t = b; b = a % b; a = t; } return a || 1; }

            // Build player with lazy measurement (wait until image loaded to compute frames)
            const player = {
                __img: img,
                frameWidth: opts && opts.frameWidth || (asset.sprite && asset.sprite.frameWidth) || 0,
                frameHeight: opts && opts.frameHeight || (asset.sprite && asset.sprite.frameHeight) || 0,
                frames: opts && opts.frames || (asset.sprite && asset.sprite.frames) || 0,
                fps: opts && opts.fps || (asset.sprite && asset.sprite.fps) || 12,
                loop: (opts && opts.loop !== undefined) ? opts.loop : ((asset.sprite && asset.sprite.loop !== undefined) ? asset.sprite.loop : true),
                _ready: false,
                _elapsed: 0,
                _current: 0,
                _cols: 1,
                update(dt){
                    // NEW: deterministic playback modes: frame-step or fixed-time with caps
                    if (!this._ready) return;

                    // Config helpers
                    const useFrameSteps = !!(window && window.lib && window.lib.fixedAnimationUseFrameSteps);
                    const frameStepEvery = (window && window.lib && Number(window.lib.fixedAnimationFrameAdvanceEvery)) || 10;
                    const fixedFps = (window && window.lib && typeof window.lib.fixedAnimationFps === 'number') ? window.lib.fixedAnimationFps : 4;
                    const maxDeltaMs = (window && window.lib && typeof window.lib.fixedAnimationMaxDeltaMs === 'number') ? Math.max(0, window.lib.fixedAnimationMaxDeltaMs) : 50;
                    const maxAdvance = (window && window.lib && typeof window.lib.fixedAnimationMaxAdvance === 'number') ? Math.max(1, Math.floor(window.lib.fixedAnimationMaxAdvance)) : 1;
                    const totalFrames = Math.max(1, this.frames || 1);

                    if (useFrameSteps) {
                        // Each call increments a step counter; advance frames only every `frameStepEvery` calls.
                        this._frameStepCounter = (this._frameStepCounter || 0) + 1;
                        const stepsToAdvance = Math.floor(this._frameStepCounter / frameStepEvery);
                        if (stepsToAdvance > 0) {
                            if (this.loop) {
                                this._current = (this._current + stepsToAdvance) % totalFrames;
                            } else {
                                this._current = Math.min(totalFrames - 1, this._current + stepsToAdvance);
                            }
                            this._frameStepCounter = this._frameStepCounter % frameStepEvery;
                        }
                        return;
                    }

                    // Time-based deterministic fallback (fixed FPS, capped delta)
                    let delta = 16;
                    if (typeof dt === 'number') {
                        if (dt > 100000) { // absolute timestamp
                            if (this._lastTimestamp == null) delta = 16;
                            else delta = Math.max(0, dt - this._lastTimestamp);
                            this._lastTimestamp = dt;
                        } else { // delta passed directly
                            delta = dt;
                        }
                    }

                    // Cap delta to avoid huge jumps after tab inactivity
                    const usedDelta = Math.min(delta, maxDeltaMs);
                    this._totalElapsed = (this._totalElapsed || 0) + usedDelta;

                    const frameTime = 1000 / Math.max(0.01, Number(fixedFps));
                    const frameNumber = Math.floor((this._totalElapsed || 0) / frameTime);

                    if (this.loop) {
                        this._current = frameNumber % totalFrames;
                    } else {
                        // clamp to final frame
                        this._current = Math.min(totalFrames - 1, frameNumber);
                    }

                    // Prevent _totalElapsed from growing without bound relative to current frame
                    const maxAllowedAhead = maxAdvance * frameTime;
                    const expectedElapsedForCurrent = frameNumber * frameTime;
                    if ((this._totalElapsed || 0) - expectedElapsedForCurrent > maxAllowedAhead) {
                        this._totalElapsed = expectedElapsedForCurrent + maxAllowedAhead;
                    }
                },
                reset(){ this._current = 0; this._elapsed = 0; this._lastTimestamp = null; },
                getCurrentFrame(){ return { index: this._current, total: Math.max(1,this.frames) }; },
                draw(ctx,x,y,w,h){
                    try {
                        if (!img.complete) return; // wait until loaded

                        if (!this._ready){
                            const iw = img.naturalWidth || (asset.aspect_ratio && asset.aspect_ratio[0]) || 0;
                            const ih = img.naturalHeight || (asset.aspect_ratio && asset.aspect_ratio[1]) || 0;

                            // NEW: support explicit grid via opts.cols/opts.rows or asset.sprite.cols/asset.sprite.rows
                            let cols = (opts && opts.cols) || (asset.sprite && asset.sprite.cols) || 0;
                            let rows = (opts && opts.rows) || (asset.sprite && asset.sprite.rows) || 0;

                            // Default animation assets to 4x4 grid when no cols/rows provided
                            if ((cols === 0 || rows === 0) && asset.type === 'animation') {
                                cols = cols || 4;
                                rows = rows || 4;
                            }

                            if (cols > 0 && rows > 0 && iw > 0 && ih > 0) {
                                // Compute frame dimensions directly from grid specification
                                this.frameWidth = Math.max(1, Math.floor(iw / cols));
                                this.frameHeight = Math.max(1, Math.floor(ih / rows));
                                this.frames = this.frames || (cols * rows);
                                this._cols = cols;
                            }
                            // If explicit sprite metadata present, prefer it
                            else if (asset.sprite && asset.sprite.frameWidth && asset.sprite.frameHeight){
                                this.frameWidth = this.frameWidth || asset.sprite.frameWidth;
                                this.frameHeight = this.frameHeight || asset.sprite.frameHeight;
                                this.frames = this.frames || asset.sprite.frames || (Math.floor(iw / this.frameWidth) * Math.floor(ih / this.frameHeight));
                            } else if (this.frameWidth && this.frameHeight){
                                // already provided via opts
                                this.frames = this.frames || (Math.floor(iw / this.frameWidth) * Math.floor(ih / this.frameHeight));
                            } else if (iw && ih){
                                // try heuristics: if width is multiple of height, horizontal strip
                                if (iw % ih === 0){
                                    this.frameHeight = ih;
                                    this.frameWidth = ih;
                                    this.frames = Math.floor(iw / this.frameWidth);
                                } else if (ih % iw === 0){
                                    this.frameWidth = iw;
                                    this.frameHeight = iw;
                                    this.frames = Math.floor(ih / this.frameHeight);
                                } else {
                                    // fallback: use gcd of dimensions to detect grid cell size
                                    const cell = gcd(iw, ih) || 1;
                                    this.frameWidth = this.frameWidth || cell;
                                    this.frameHeight = this.frameHeight || cell;
                                    const colsAuto = Math.floor(iw / this.frameWidth) || 1;
                                    const rowsAuto = Math.floor(ih / this.frameHeight) || 1;
                                    this.frames = this.frames || (colsAuto * rowsAuto);
                                    this._cols = colsAuto;
                                }
                            } else {
                                // unknown size: treat as single frame
                                this.frameWidth = this.frameWidth || 0;
                                this.frameHeight = this.frameHeight || 0;
                                this.frames = this.frames || 1;
                            }

                            // sanitize / clamp values
                            this.frameWidth = Math.max(0, Math.round(this.frameWidth || 0));
                            this.frameHeight = Math.max(0, Math.round(this.frameHeight || 0));
                            this.frames = Math.max(1, Math.round(this.frames || 1));

                            // compute columns safely if not set by grid
                            if (this.frameWidth > 0 && !this._cols) {
                                this._cols = Math.max(1, Math.floor((img.naturalWidth || iw || 1) / this.frameWidth));
                            } else if (this.frameWidth > 0 && this._cols) {
                                // ensure _cols is integer
                                this._cols = Math.max(1, Math.floor(this._cols));
                            }

                            // ensure frames doesn't exceed cols*rows (if rows computable)
                            const possibleCols = this._cols;
                            const possibleRows = (this.frameHeight > 0) ? Math.max(1, Math.floor((img.naturalHeight || ih || 1) / this.frameHeight)) : 1;
                            const maxPossible = possibleCols * possibleRows;
                            if (this.frames > maxPossible) {
                                // clamp excessive frame count (likely wrong gcd detection)
                                this.frames = Math.min(this.frames, maxPossible);
                            }

                            // guard against absurd frame counts (indicates detection failed)
                            if (this.frames > 200) {
                                // treat as single-frame to avoid random slicing
                                this.frames = 1;
                                this.frameWidth = iw;
                                this.frameHeight = ih;
                                this._cols = 1;
                            }

                            if (!this.frames) this.frames = 1;
                            this._ready = true;

                            // Debug: if layout seems suspicious, log a brief message for debugging
                            if (this.frames === 1 && (iw > 0 && ih > 0 && (iw > this.frameWidth || ih > this.frameHeight))) {
                                // no-op; don't spam logs
                            } else if (this.frames > 1 && (this.frameWidth <= 0 || this.frameHeight <= 0)) {
                                console.warn('[lib] suspicious sprite layout for', id, 'computed', {iw,ih,frameWidth:this.frameWidth,frameHeight:this.frameHeight,frames:this.frames,cols:this._cols});
                            }
                        }

                        if (this.frames <= 1 || this.frameWidth <= 0 || this.frameHeight <= 0){
                            // draw whole image for single-frame assets
                            ctx.drawImage(img, x, y, w, h);
                            return;
                        }

                        const fi = Math.max(0, Math.min(this.frames - 1, this._current));
                        const sx = (fi % this._cols) * this.frameWidth;
                        const sy = Math.floor(fi / this._cols) * this.frameHeight;
                        ctx.drawImage(img, sx, sy, this.frameWidth, this.frameHeight, x, y, w, h);
                    } catch(e){}
                }
            };

            // cache the player object so repeated calls return the same controller
            _animCache[id] = _animCache[id] || img;
            _animCache[id].__player = player;
            return player;
        }

        function _log(){ console.log.apply(console,['[lib]'].concat(Array.from(arguments))); }

        function _loadState(){
            try { const raw = localStorage.getItem(STATE_KEY); return raw ? JSON.parse(raw) : { highScore: 0 }; }
            catch(e){ return { highScore: 0 }; }
        }
        function _saveState(s){
            try { localStorage.setItem(STATE_KEY, JSON.stringify(s)); return true; }
            catch(e){ return false; }
        }

        function _addScoreLocal(entry){
            try {
                const raw = localStorage.getItem(LB_KEY);
                const list = raw ? JSON.parse(raw) : [];
                list.push(entry);
                list.sort((a,b)=> b.score - a.score || a.timestamp - b.timestamp);
                localStorage.setItem(LB_KEY, JSON.stringify(list.slice(0,200)));
                return list;
            } catch(e){ return []; }
        }
        function _getTopN(n){
            try {
                const raw = localStorage.getItem(LB_KEY);
                const list = raw ? JSON.parse(raw) : [];
                return list.slice(0,n);
            } catch(e){ return []; }
        }

        window.lib = {
            log: _log,
            getAsset: function(id){ return _getAsset(id); },
            preloadAnimation: function(id){ _preloadAnimation(id); },
            getAnimationPlayer: function(id){ return _getAnimationPlayer(id); },
            getUserGameState: function(){ return Promise.resolve({ state: _loadState() }); },
            saveUserGameState: function(state){ _saveState(state); return Promise.resolve(true); },
            addPlayerScoreToLeaderboard: function(score, limit){
                return new Promise((resolve)=>{
                    try {
                        const entry = {
                            userId: (window.gameConfig && window.gameConfig.playerId) || ('Player_' + Math.random().toString(36).slice(2,8).toUpperCase()),
                            username: null,
                            profilePicture: null,
                            score: score,
                            timestamp: Date.now()
                        };
                        const all = _addScoreLocal(entry);
                        const rank = all.findIndex(e=> e === entry) + 1 || null;
                        resolve({ success: true, userRank: rank });
                    } catch(e){ resolve({ success: false, userRank: null }); }
                });
            },
            getTopNEntriesFromLeaderboard: function(n){
                return new Promise((resolve)=>{
                    try {
                        const entries = _getTopN(n || 10);
                        const pid = window.gameConfig && window.gameConfig.playerId;
                        const idx = entries.findIndex(e => e.userId === pid);
                        resolve({ entries: entries, userRank: idx === -1 ? null : idx + 1 });
                    } catch(e){ resolve({ entries: [], userRank: null }); }
                });
            }
        };

        // add global animation playback control (multiplies sprite fps)
        try {
            if (!window.lib) window.lib = {};
            // Fixed animation FPS: enforce a single frame rate for all sprite animations
            // Change this number to adjust animation speed globally (frames per second)
            window.lib.fixedAnimationFps = 4; // default fixed FPS (frames per second)
            // Cap how many frames may advance in a single update to avoid spikes
            window.lib.fixedAnimationMaxAdvance = 1; // max frames advanced per update (integer)
            // Cap the maximum delta (ms) we accept per update to avoid huge jumps
            window.lib.fixedAnimationMaxDeltaMs = 50; // milliseconds
            // Optional: use frame-count stepping instead of time-based updates.
            // When true, each call to `update()` increments an internal frame counter
            // and advances the sprite every `fixedAnimationFrameAdvanceEvery` calls.
            window.lib.fixedAnimationUseFrameSteps = true;
            window.lib.fixedAnimationFrameAdvanceEvery = 10;
            // Disable runtime changes — keep values fixed for consistent behavior
            window.lib.setAnimationPlaybackRate = function(rate){
                console.warn('setAnimationPlaybackRate is disabled; change fixedAnimationFps or fixedAnimationMaxAdvance in source.');
                return false;
            };
        } catch(e){}
    })();
    </script>
  ''';

  String get loadLogicGame => r'''
    <script>

        // Game constants
        const CANVAS_WIDTH = 720;
        const CANVAS_HEIGHT = 1280;
        const CONTAINER_WIDTH = 650;
        const CONTAINER_HEIGHT = 940;
        const CONTAINER_X = (CANVAS_WIDTH - CONTAINER_WIDTH) / 2;
        const CONTAINER_Y = 250;
        const DANGER_LINE_Y = CONTAINER_Y + 50;
        const DANGER_TIMEOUT = 2000; // 2 seconds

        // Evolution stages configuration (sizes increased by 25%)
        const FRUIT_TYPES = [
            { name: 'ooze',size: 75,points: 10,assetId: 'evo_ooze' },
            { name: 'cell',size: 94,points: 20,assetId: 'evo_cell' },
            { name: 'bacteria',size: 113,points: 40,assetId: 'evo_bacteria' },
            { name: 'jellyfish',size: 138,points: 80,assetId: 'evo_jellyfish' },
            { name: 'fish',size: 163,points: 160,assetId: 'evo_fish' },
            { name: 'amphibian',size: 188,points: 320,assetId: 'evo_amphibian' },
            { name: 'reptile',size: 219,points: 640,assetId: 'evo_reptile' },
            { name: 'mammal',size: 250,points: 1280,assetId: 'evo_mammal' },
            { name: 'primate',size: 288,points: 2560,assetId: 'evo_primate' },
            { name: 'caveman',size: 325,points: 5120,assetId: 'evo_caveman' },
            { name: 'human',size: 363,points: 10240,assetId: 'evo_human' }
        ];

        // Game state
        let canvas,ctx;
        let engine,world;
        let currentMode = 'play';
        let assetCache = {};
        let audioContext = null;
        let masterGain = null;
        let soundBuffers = {}; // Store decoded AudioBuffers for sound effects
        let startScreenCanvas,startScreenCtx;
        let startScreenBubbles = [];
        let startScreenAnimationId = null;
        let playerHighScore = 0; // Player-specific high score loaded from persistent storage
        let gameState = {
            score: 0,
            fruits: [],
            nextFruit: null,
            dropX: CANVAS_WIDTH / 2,
            isDropping: false,
            gameOver: false,
            gameWon: false,
            dangerTimer: null,
            _gameOverCheckTimer: null,
            particles: [],
            scorePopups: []
        };

        // Particle pool for performance
        const PARTICLE_POOL_SIZE = 200;
        let particlePool = [];
        let activeParticles = [];

        // Initialize particle pool
        function initParticlePool() {
            particlePool = [];
            for (let i = 0; i < PARTICLE_POOL_SIZE; i++) {
                particlePool.push({
                    x: 0,
                    y: 0,
                    vx: 0,
                    vy: 0,
                    life: 0,
                    size: 0,
                    active: false
                });
            }
            activeParticles = [];
        }

        // Get particle from pool
        function getParticle() {
            for (let i = 0; i < particlePool.length; i++) {
                if (!particlePool[i].active) {
                    particlePool[i].active = true;
                    activeParticles.push(particlePool[i]);
                    return particlePool[i];
                }
            }
            return null; // Pool exhausted
        }

        // Return particle to pool
        function releaseParticle(particle) {
            particle.active = false;
            const index = activeParticles.indexOf(particle);
            if (index > -1) {
                activeParticles.splice(index,1);
            }
        }

        // Initialize default config
        if (!window.gameConfig) {
            window.gameConfig = {
                container: {
                    backgroundColor: '#FFEAA7',
                    borderColor: '#8b7355',
                    borderWidth: 4
                },
                visual: {
                    particleColor: '#FF9800',
                    dangerLineColor: '#F44336'
                },
                audio: {
                    musicVolume: 1.0,
                    sfxVolume: 0.7,
                    musicEnabled: true
                },
                background: {
                    assetId: 'background_primordial',
                    blur: 5
                }
            };
        }

        /* ==================================================
         * UI-SPECIFIC JAVASCRIPT
         * Functions for managing UI state and interactions
         * ==================================================
         */

        // Load player's high score from persistent storage
        // async function loadPlayerHighScore() {
        //     try {
        //         lib.log('Loading player high score from persistent storage...');
        //         const response = await lib.getUserGameState();

        //         if (response.state && response.state.highScore !== undefined) {
        //             playerHighScore = response.state.highScore;
        //             lib.log('Loaded player high score: ' + playerHighScore);
        //         } else {
        //             playerHighScore = 0;
        //             lib.log('No saved high score found, starting at 0');
        //         }

        //         updateHighScoreDisplay();
        //     } catch (error) {
        //         lib.log('Failed to load player high score: ' + error.message);
        //         playerHighScore = 0;
        //         updateHighScoreDisplay();
        //     }
        // }

        // Save player's high score to persistent storage
        async function savePlayerHighScore(score) {
            try {
                lib.log('Saving player high score: ' + score);
                await lib.saveUserGameState({ highScore: score });
                lib.log('Player high score saved successfully');
            } catch (error) {
                lib.log('Failed to save player high score: ' + error.message);
            }
        }

        // Leaderboard state (stored in gameConfig)
        // Initialize leaderboard (simplified for global system)
        function initLeaderboard() {
            // Keep playerId for fallback display purposes
            if (!window.gameConfig.playerId) {
                window.gameConfig.playerId = 'Player_' + Math.random().toString(36).substr(2,6).toUpperCase();
            }
            // Note: No longer need local leaderboard array - using global persistence
        }

        // Submit score to leaderboard
        // Submit score to global leaderboard
        async function submitScore(score) {
            try {
                lib.log('Submitting score to global leaderboard: ' + score);

                // Submit to global leaderboard and get top 10 entries
                const response = await lib.addPlayerScoreToLeaderboard(score,10);

                if (response.success) {
                    lib.log('Score submitted successfully. Rank: ' + response.userRank);

                    // Show notification with rank
                    if (response.userRank !== null) {
                        showScoreNotification(response.userRank);
                    }

                    return response.userRank;
                } else {
                    lib.log('Score submission returned success=false');
                    return null;
                }
            } catch (error) {
                lib.log('Failed to submit score to leaderboard: ' + error.message);
                // Game continues even if leaderboard fails
                return null;
            }
        }

        // Show score submission notification
        function showScoreNotification(rank) {
            const notification = document.getElementById('scoreNotification');
            if (!notification) return;

            let message = '';
            if (rank === 1) {
                message = '🎉 #1 on the Leaderboard! 🎉';
            } else if (rank <= 3) {
                message = `🏆 You ranked #${rank}! 🏆`;
            } else if (rank <= 10) {
                message = `🌟 You ranked #${rank}! 🌟`;
            } else {
                message = `Score submitted! You ranked #${rank}`;
            }

            notification.textContent = message;
            notification.classList.add('show');

            setTimeout(() => {
                notification.classList.remove('show');
            },3000);
        }

        // Show leaderboard screen
        // Show global leaderboard screen
        async function showLeaderboard() {
            const leaderboardScreen = document.getElementById('leaderboardScreen');
            const leaderboardList = document.getElementById('leaderboardList');

            if (!leaderboardScreen || !leaderboardList) return;

            // Show loading state
            leaderboardList.innerHTML = '<div style="text-align: center; padding: 40px; color: var(--color-neutral-mid);">Loading leaderboard...</div>';
            leaderboardScreen.classList.add('show');

            try {
                lib.log('Fetching global leaderboard...');

                // Fetch top 10 from global leaderboard
                const response = await lib.getTopNEntriesFromLeaderboard(10);

                lib.log('Leaderboard fetched. Entries: ' + response.entries.length + ', User rank: ' + response.userRank);

                // Clear loading state
                leaderboardList.innerHTML = '';

                if (response.entries.length === 0) {
                    leaderboardList.innerHTML = '<div style="text-align: center; padding: 40px; color: var(--color-neutral-mid);">No scores yet! Be the first to play!</div>';
                } else {
                    response.entries.forEach((entry,index) => {
                        const entryDiv = document.createElement('div');
                        entryDiv.className = 'leaderboard-entry';

                        // Highlight current player's entry
                        // Check if this entry matches the current user (will be highlighted by rank)
                        if (response.userRank !== null && index + 1 === response.userRank) {
                            entryDiv.classList.add('player-entry');
                        }

                        // Rank display with emoji for top 3
                        let rankDisplay = `#${index + 1}`;
                        if (index === 0) rankDisplay = '🥇';
                        else if (index === 1) rankDisplay = '🥈';
                        else if (index === 2) rankDisplay = '🥉';

                        // Use username if available, otherwise use userId
                        const displayName = entry.username || entry.userId || 'Anonymous';

                        // Create entry HTML with optional profile picture
                        let entryHTML = `<div class="leaderboard-rank">${rankDisplay}</div>`;

                        // Add profile picture if available
                        if (entry.profilePicture) {
                            entryHTML += `
                                <img src="${entry.profilePicture}" 
                                     alt="${displayName}" 
                                     style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; margin-right: 8px;">
                            `;
                        }

                        entryHTML += `
                            <div class="leaderboard-name">${displayName}</div>
                            <div class="leaderboard-score">${entry.score}</div>
                        `;

                        entryDiv.innerHTML = entryHTML;
                        leaderboardList.appendChild(entryDiv);
                    });
                }
            } catch (error) {
                lib.log('Failed to fetch leaderboard: ' + error.message);
                leaderboardList.innerHTML = '<div style="text-align: center; padding: 40px; color: var(--color-danger);">Failed to load leaderboard. Please try again later.</div>';
            }
        }

        // Hide leaderboard screen
        function hideLeaderboard() {
            const leaderboardScreen = document.getElementById('leaderboardScreen');
            if (!leaderboardScreen) return;

            leaderboardScreen.classList.remove('show');
        }

        // Update music button appearance
        function updateMusicButton() {
            const btn = document.getElementById('musicBtn');
            if (!btn) return;

            const icon = btn.querySelector('.material-symbols-rounded');
            if (!icon) return;

            const isEnabled = window.gameConfig.audio.musicEnabled;

            if (isEnabled) {
                btn.classList.remove('muted');
                icon.textContent = 'music_note';
            } else {
                btn.classList.add('muted');
                icon.textContent = 'music_off';
            }
        }

        // Toggle music
        function toggleMusic() {
            window.gameConfig.audio.musicEnabled = !window.gameConfig.audio.musicEnabled;
            updateMusicButton();

            const music = assetCache['custom_bgm'];
            if (music) {
                if (window.gameConfig.audio.musicEnabled) {
                    music.play().catch(e => lib.log('Audio play failed: ' + e));
                } else {
                    music.pause();
                }
            }
        }

        // Setup UI event listeners
        function setupUIListeners() {
            // Safe event wiring helper: only add listener if element exists
            function on(id, evt, handler) {
                try {
                    const el = document.getElementById(id);
                    if (el && typeof el.addEventListener === 'function') {
                        el.addEventListener(evt, handler);
                    } else {
                        // non-fatal: log missing UI element for debugging
                        if (window.lib && typeof window.lib.log === 'function') window.lib.log('UI: element not found #' + id);
                    }
                    
                } catch (e) {
                    if (window.lib && typeof window.lib.log === 'function') window.lib.log('UI: failed to attach ' + evt + ' to #' + id + ' - ' + e);
                }
            }

            on('musicBtn','click',toggleMusic);
            on('playAgainBtn','click',restartGame);
            on('playAgainWinBtn','click',restartGame);
            on('playBtn','click',startGame);
            on('leaderboardBtn','click',showLeaderboard);
            on('closeLeaderboardBtn','click',hideLeaderboard);
            on('viewLeaderboardBtn','click',showLeaderboard);
            on('viewLeaderboardWinBtn','click',showLeaderboard);

            // Unlock/resume audio on first user interaction and attempt to play BGM if enabled
            function unlockAudioOnce() {
                try {
                    document.removeEventListener('pointerdown', unlockAudioOnce);
                    initWebAudio();

                    // Ensure custom_bgm exists in assetCache (use chosen music if not)
                    if (!assetCache['custom_bgm'] || !(assetCache['custom_bgm'] instanceof HTMLAudioElement)) {
                        const candidateIds = ['music_evolution_retro_v2','music_evolution_retro','music_evolution','music_background'];
                        for (const id of candidateIds) {
                            const a = lib.getAsset(id);
                            if (a && a.url) {
                                const audioEl = new Audio(a.url);
                                audioEl.loop = true;
                                audioEl.volume = window.gameConfig.audio.musicVolume || 0.5;
                                assetCache[id] = audioEl;
                                assetCache['custom_bgm'] = audioEl;
                                break;
                            }
                        }
                    }

                    const bg = assetCache['custom_bgm'];
                    if (bg && window.gameConfig.audio.musicEnabled) {
                        // ignore play errors (autoplay policies) but try
                        bg.play().catch(e => { if (window.lib && window.lib.log) window.lib.log('Autoplay failed: ' + e); });
                    }
                } catch (e) {
                    if (window.lib && window.lib.log) window.lib.log('unlockAudioOnce error: ' + e);
                }
            }
            document.addEventListener('pointerdown', unlockAudioOnce, { once: true });
        }

        // Initialize start screen animation
        let splashSceneCanvas,splashSceneCtx;
        function initStartScreen() {
            startScreenCanvas = document.getElementById('startScreenCanvas');
            if (!startScreenCanvas) return;

            startScreenCtx = startScreenCanvas.getContext('2d');
            if (!startScreenCtx) return;

            // Also get splash scene canvas for animation
            splashSceneCanvas = document.getElementById('splashSceneCanvas');
            if (splashSceneCanvas) {
                splashSceneCtx = splashSceneCanvas.getContext('2d');
            }

            // Create bubble particles
            startScreenBubbles = [];
            for (let i = 0; i < 50; i++) {
                startScreenBubbles.push({
                    x: Math.random() * CANVAS_WIDTH,
                    y: Math.random() * CANVAS_HEIGHT,
                    size: 5 + Math.random() * 20,
                    speed: 0.2 + Math.random() * 0.8,
                    opacity: 0.1 + Math.random() * 0.3,
                    wobble: Math.random() * Math.PI * 2,
                    wobbleSpeed: 0.02 + Math.random() * 0.03
                });
            }

            // Start animation
            startScreenAnimationId = requestAnimationFrame((timestamp) => animateStartScreen(timestamp));
        }

        // Animate start screen background
        function animateStartScreen(timestamp) {
            if (!startScreenCtx) return;

            // Update splash scene animation if it exists
            if (window.splashAnimationPlayer && splashSceneCanvas && splashSceneCtx && timestamp) {
                window.splashAnimationPlayer.update(timestamp);

                // Clear and draw animation
                splashSceneCtx.clearRect(0,0,splashSceneCanvas.width,splashSceneCanvas.height);
                window.splashAnimationPlayer.draw(splashSceneCtx,0,0,splashSceneCanvas.width,splashSceneCanvas.height);
            }

            // Draw primordial ooze background with gradient
            const gradient = startScreenCtx.createLinearGradient(0,0,0,CANVAS_HEIGHT);
            gradient.addColorStop(0,'#1a3a2e');
            gradient.addColorStop(0.5,'#0f2d23');
            gradient.addColorStop(1,'#0d1f1a');
            startScreenCtx.fillStyle = gradient;
            startScreenCtx.fillRect(0,0,CANVAS_WIDTH,CANVAS_HEIGHT);

            // Add swirling patterns
            startScreenCtx.globalAlpha = 0.15;
            for (let i = 0; i < 3; i++) {
                const time = Date.now() * 0.0005 + i * 2;
                const centerX = CANVAS_WIDTH / 2 + Math.sin(time * 0.5) * 100;
                const centerY = CANVAS_HEIGHT / 2 + Math.cos(time * 0.3) * 150;
                const swirl = startScreenCtx.createRadialGradient(centerX,centerY,50,centerX,centerY,300);
                swirl.addColorStop(0,'#2d5f4f');
                swirl.addColorStop(1,'transparent');
                startScreenCtx.fillStyle = swirl;
                startScreenCtx.fillRect(0,0,CANVAS_WIDTH,CANVAS_HEIGHT);
            }
            startScreenCtx.globalAlpha = 1;

            // Update and draw bubbles
            for (let i = 0; i < startScreenBubbles.length; i++) {
                const bubble = startScreenBubbles[i];

                // Move bubble up
                bubble.y -= bubble.speed;

                // Add wobble motion
                bubble.wobble += bubble.wobbleSpeed;
                const wobbleX = Math.sin(bubble.wobble) * 15;

                // Reset bubble when it reaches top
                if (bubble.y + bubble.size < 0) {
                    bubble.y = CANVAS_HEIGHT + bubble.size;
                    bubble.x = Math.random() * CANVAS_WIDTH;
                }

                // Draw bubble with glow effect
                startScreenCtx.globalAlpha = bubble.opacity;

                // Outer glow
                const glowGradient = startScreenCtx.createRadialGradient(
                    bubble.x + wobbleX, bubble.y, 0,
                    bubble.x + wobbleX, bubble.y, bubble.size * 1.5
                );
                glowGradient.addColorStop(0,'rgba(100, 200, 150, 0.3)');
                glowGradient.addColorStop(1,'transparent');
                startScreenCtx.fillStyle = glowGradient;
                startScreenCtx.beginPath();
                startScreenCtx.arc(bubble.x + wobbleX,bubble.y,bubble.size * 1.5,0,Math.PI * 2);
                startScreenCtx.fill();

                // Bubble circle
                const bubbleGradient = startScreenCtx.createRadialGradient(
                    bubble.x + wobbleX - bubble.size * 0.3,
                    bubble.y - bubble.size * 0.3,
                    0,
                    bubble.x + wobbleX,
                    bubble.y,
                    bubble.size
                );
                bubbleGradient.addColorStop(0,'rgba(150, 255, 200, 0.4)');
                bubbleGradient.addColorStop(0.6,'rgba(100, 200, 150, 0.2)');
                bubbleGradient.addColorStop(1,'rgba(50, 150, 100, 0.1)');
                startScreenCtx.fillStyle = bubbleGradient;
                startScreenCtx.beginPath();
                startScreenCtx.arc(bubble.x + wobbleX,bubble.y,bubble.size,0,Math.PI * 2);
                startScreenCtx.fill();

                // Highlight
                startScreenCtx.fillStyle = 'rgba(255, 255, 255, 0.3)';
                startScreenCtx.beginPath();
                startScreenCtx.arc(
                    bubble.x + wobbleX - bubble.size * 0.3,
                    bubble.y - bubble.size * 0.3,
                    bubble.size * 0.3,
                    0,
                    Math.PI * 2
                );
                startScreenCtx.fill();
            }
            startScreenCtx.globalAlpha = 1;

            // Continue animation
            startScreenAnimationId = requestAnimationFrame((timestamp) => animateStartScreen(timestamp));
        }

        // Stop start screen animation
        function stopStartScreenAnimation() {
            if (startScreenAnimationId) {
                cancelAnimationFrame(startScreenAnimationId);
                startScreenAnimationId = null;
            }
        }

        // Start the game from the start screen
        function startGame() {
            // Hide start screen if present (defensive)
            const startScreen = document.getElementById('startScreen');
            if (startScreen && startScreen.classList) {
                startScreen.classList.add('hidden');
            }

            // Stop start screen animation if running
            try { stopStartScreenAnimation(); } catch (e) { /* ignore */ }

            // Initialize Web Audio safely
            try { initWebAudio(); } catch (e) { lib.log && lib.log('initWebAudio error: ' + e); }

            // Start background music if enabled and available
            try {
                if (window.gameConfig && window.gameConfig.audio && window.gameConfig.audio.musicEnabled) {
                    const music = assetCache['custom_bgm'];
                    if (music && typeof music.play === 'function') {
                        music.play().catch(err => lib.log && lib.log('Audio play failed: ' + err));
                    }
                }
            } catch (e) { lib.log && lib.log('startGame music error: ' + e); }
        }

        // Initialize evolution legend
        function initializeLegend() {
            FRUIT_TYPES.forEach((fruitType,index) => {
                const legendItem = document.getElementById(`legend-${index}`);
                if (!legendItem) return;

                // Clear any existing content
                legendItem.innerHTML = '';

                const cachedAsset = assetCache[fruitType.assetId];
                if (cachedAsset && cachedAsset.complete && cachedAsset.naturalWidth > 0) {
                    // Image is fully loaded
                    const img = document.createElement('img');
                    img.src = cachedAsset.src;
                    img.style.width = '100%';
                    img.style.height = 'auto';
                    img.style.maxWidth = '50px';
                    img.style.maxHeight = '50px';
                    img.style.objectFit = 'contain';
                    legendItem.appendChild(img);
                } else if (cachedAsset) {
                    // Image exists but might not be loaded yet - wait for it
                    const img = document.createElement('img');
                    img.src = cachedAsset.src;
                    img.style.width = '100%';
                    img.style.height = 'auto';
                    img.style.maxWidth = '50px';
                    img.style.maxHeight = '50px';
                    img.style.objectFit = 'contain';
                    legendItem.appendChild(img);
                } else {
                    // Fallback: show colored circle
                    const fallback = document.createElement('div');
                    fallback.style.width = '40px';
                    fallback.style.height = '40px';
                    fallback.style.borderRadius = '50%';
                    fallback.style.backgroundColor = '#ff6b6b';
                    fallback.style.margin = '0 auto';
                    legendItem.appendChild(fallback);
                }
            });
        }

        /* ==================================================
         * GAME LOGIC (PRESERVED FROM ORIGINAL)
         * ==================================================
         */

        // Initialize Web Audio API
        function initWebAudio() {
            if (audioContext) return; // Already initialized

            try {
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
                masterGain = audioContext.createGain();
                masterGain.gain.value = 0.35; // Master volume control
                masterGain.connect(audioContext.destination);

                lib.log('Web Audio API initialized - Context state: ' + audioContext.state);

                // Decode all sound effect buffers
                const soundIds = ['sound_drop','sound_evolve','sound_gameover'];
                soundIds.forEach(id => {
                    const arrayBuffer = assetCache[id];
                    if (arrayBuffer && arrayBuffer instanceof ArrayBuffer) {
                        audioContext.decodeAudioData(
                            arrayBuffer,
                            (decodedBuffer) => {
                                soundBuffers[id] = decodedBuffer;
                                lib.log('Decoded audio buffer: ' + id);
                            },
                            (error) => {
                                lib.log('Failed to decode audio: ' + id + ' - ' + error);
                            }
                        );
                    }
                });
            } catch (error) {
                lib.log('Failed to initialize Web Audio API: ' + error);
            }
        }

        // Preload assets
        function preloadAssets(callback) {
            const assetIds = [
                'evo_ooze','evo_cell','evo_bacteria','evo_jellyfish','evo_fish',
                'evo_amphibian','evo_reptile','evo_mammal','evo_primate','evo_caveman','evo_human',
                'background_primordial','sound_drop','sound_evolve','sound_gameover',
                'logo_evolution_merge','splash_scene_animated'
            ];

            // Preload animation assets
            lib.preloadAnimation('splash_scene_animated');
            lib.preloadAnimation('evo_ooze_grumpy');
            lib.preloadAnimation('evo_cell_smile');
            lib.preloadAnimation('evo_bacteria_wink');
            lib.preloadAnimation('evo_jellyfish_sad');
            lib.preloadAnimation('evo_fish_bubble');
            lib.preloadAnimation('evo_amphibian_lick');
            lib.preloadAnimation('evo_reptile_yawn');
            lib.preloadAnimation('evo_mammal_shiver');
            lib.preloadAnimation('evo_primate_ooo');
            lib.preloadAnimation('evo_caveman_sleep');
            lib.preloadAnimation('evo_human_phone');

            lib.log('Preloading animations including caveman sleep and human phone');

            let loadedCount = 0;
            const totalAssets = assetIds.length + 1; // +1 for custom music
            let callbackFired = false;

            // Update loading progress UI
            function updateLoadingProgress() {
                const progress = Math.round((loadedCount / totalAssets) * 100);
                const loadingBarFill = document.getElementById('loadingBarFill');
                const loadingProgress = document.getElementById('loadingProgress');

                if (loadingBarFill) {
                    loadingBarFill.style.width = progress + '%';
                }
                if (loadingProgress) {
                    loadingProgress.textContent = progress + '%';
                }
            }

            // Safety timeout - if assets don't load in 10 seconds, proceed anyway
            const safetyTimeout = setTimeout(() => {
                if (!callbackFired) {
                    lib.log('Asset loading timeout - proceeding with available assets');
                    callbackFired = true;
                    callback();
                }
            },10000);

            function checkComplete() {
                updateLoadingProgress();

                if (!callbackFired && loadedCount >= totalAssets) {
                    callbackFired = true;
                    clearTimeout(safetyTimeout);

                    // Small delay to show 100% before transitioning
                    setTimeout(() => {
                        // Hide loading screen
                        const loadingScreen = document.getElementById('loadingScreen');
                        if (loadingScreen) {
                            loadingScreen.classList.add('hidden');
                        }

                        callback();
                    },300);
                }
            }

            // Load custom background music from external URL
            // Prefer in-package music assets when available, otherwise fallback to bundled URL
            // Force the background music to the provided external BGM URL
            const chosenMusicUrl = 'https://cdn.jsdelivr.net/gh/blackwidowink/assets@main/Retro%20Relaxing%20Merge%20Puzzle%20BGM.mp3';
            if (window.lib && typeof window.lib.log === 'function') window.lib.log('Using forced BGM URL: ' + chosenMusicUrl);
            const customMusic = new Audio(chosenMusicUrl);
            customMusic.preload = 'auto';
            customMusic.loop = true;
            customMusic.volume = window.gameConfig.audio && window.gameConfig.audio.musicVolume != null ? window.gameConfig.audio.musicVolume : 0.5;

            assetCache['custom_bgm'] = customMusic;
            customMusic.load(); // Explicitly trigger load

            // Ensure we count the custom music towards loadedCount (totalAssets includes it).
            // Increment once on canplaythrough or on error; remove listeners afterwards.
            (function registerMusicCountListeners() {
                let handled = false;
                function markLoaded() {
                    if (handled) return;
                    handled = true;
                    loadedCount++;
                    try { checkComplete(); } catch(e){}
                    customMusic.removeEventListener('canplaythrough', markLoaded);
                    customMusic.removeEventListener('error', markLoaded);
                }
                customMusic.addEventListener('canplaythrough', markLoaded, { once: true });
                customMusic.addEventListener('error', markLoaded, { once: true });
                // Fallback: if music doesn't fire events within safety window, ensure mark after safety timeout already exists — no further action needed here.
            })();

            assetIds.forEach(id => {
                const assetInfo = lib.getAsset(id);
                if (assetInfo) {
                    if (assetInfo.type === 'audio') {
                        // For sound effects, fetch and decode into AudioBuffer for Web Audio API
                        fetch(assetInfo.url)
                            .then(response => response.arrayBuffer())
                            .then(arrayBuffer => {
                                // Decode will happen when Web Audio context is initialized
                                assetCache[id] = arrayBuffer;
                                loadedCount++;
                                checkComplete();
                            })
                            .catch(error => {
                                lib.log('Failed to fetch audio: ' + id + ' - ' + error);
                                loadedCount++;
                                checkComplete();
                            });
                    } else {
                        const img = new Image();
                        let imgLoaded = false;
                        const markImgLoaded = () => {
                            if (!imgLoaded) {
                                imgLoaded = true;
                                loadedCount++;
                                checkComplete();
                            }
                        };

                        img.onload = markImgLoaded;
                        img.onerror = () => {
                            lib.log('Image failed to load: ' + id);
                            markImgLoaded();
                        };

                        // Fallback timeout for each image (3 seconds)
                        setTimeout(markImgLoaded,3000);

                        img.src = assetInfo.url;
                        assetCache[id] = img;
                    }
                } else {
                    lib.log('Asset not found: ' + id);
                    loadedCount++;
                    checkComplete();
                }
            });
        }

        // Initialize Matter.js physics
        function initPhysics() {
            // Create engine with optimized settings for fast but stable physics
            engine = Matter.Engine.create({
                constraintIterations: 3,
                positionIterations: 10, // Increased for better collision detection
                velocityIterations: 6,   // Increased for stability
                enableSleeping: false
            });
            world = engine.world;
            world.gravity.y = 2.5; // Faster gravity for quicker drops

            // Create container walls with tight collision detection
            const wallOptions = {
                isStatic: true,
                friction: 0.8,
                restitution: 0.15, // Slightly less bouncy
                slop: 0.01 // Tighter collision tolerance
            };

            // Floor positioned AT the visual container bottom (moved down 5%)
            const floorThickness = 60;
            const containerBottom = CONTAINER_Y + CONTAINER_HEIGHT; // Visual bottom at 1180
            const floorOffset = CONTAINER_HEIGHT * 0.05; // 5% offset downward
            const floorY = containerBottom + floorOffset - floorThickness / 2; // Center of floor body
            const floorBody = Matter.Bodies.rectangle(
                CONTAINER_X + CONTAINER_WIDTH / 2,
                floorY,
                CONTAINER_WIDTH + 100, // Extra wide for edge cases
                floorThickness,
                wallOptions
            );
            Matter.World.add(world,floorBody);
            world.floorBody = floorBody;

            lib.log('Floor created at Y: ' + floorY + ', Container bottom: ' + containerBottom + ', Floor top edge: ' + (floorY - floorThickness / 2));

            // Left wall - full height
            const wallThickness = 60;
            const wallHeight = CONTAINER_HEIGHT + 100;
            const leftWallBody = Matter.Bodies.rectangle(
                CONTAINER_X - wallThickness / 2,
                CONTAINER_Y + CONTAINER_HEIGHT / 2,
                wallThickness,
                wallHeight,
                wallOptions
            );
            Matter.World.add(world,leftWallBody);

            // Right wall - full height
            const rightWallBody = Matter.Bodies.rectangle(
                CONTAINER_X + CONTAINER_WIDTH + wallThickness / 2,
                CONTAINER_Y + CONTAINER_HEIGHT / 2,
                wallThickness,
                wallHeight,
                wallOptions
            );
            Matter.World.add(world,rightWallBody);

            // Collision detection for merging
            Matter.Events.on(engine,'collisionStart',handleCollision);

            lib.log('Physics initialized - Floor Y: ' + floorY + ', Gravity: ' + world.gravity.y);
        }

        // Handle collisions for merging
        // Handle collisions for merging
        function handleCollision(event) {
            if (currentMode !== 'play' || gameState.gameOver || gameState.gameWon) return;

            event.pairs.forEach(pair => {
                const bodyA = pair.bodyA;
                const bodyB = pair.bodyB;

                // Check if both bodies are fruits
                const fruitA = gameState.fruits.find(f => f.body === bodyA);
                const fruitB = gameState.fruits.find(f => f.body === bodyB);

                // Ignore collisions if either fruit is marked for deletion or on cooldown
                if (!fruitA || !fruitB || fruitA.markedForDeletion || fruitB.markedForDeletion) return;
                if (fruitA.mergeCooldown > 0 || fruitB.mergeCooldown > 0) return;

                // Mark both fruits as having touched another fruit (settled-by-collision)
                // This ensures falling fruits are not counted until they've contacted another fruit.
                try {
                    fruitA.hasTouchedAnother = true;
                    fruitB.hasTouchedAnother = true;
                    // if (window.lib && typeof window.lib.log === 'function') {
                    //     window.lib.log('collision: yA=' + (fruitA.body && fruitA.body.position ? fruitA.body.position.y : 'na') +
                    //         ' yB=' + (fruitB.body && fruitB.body.position ? fruitB.body.position.y : 'na'));
                    // }
                } catch (e) {
                    // ignore logging errors
                }
                // After collision, schedule a quick check of game-over conditions
                try {
                    scheduleGameOverCheck(100);
                } catch (e) {
                    // ignore
                }

                // Check if fruits are same type and can merge
                if (fruitA.type === fruitB.type && fruitA.type < FRUIT_TYPES.length - 1) {
                    // Mark for deletion and merge
                    fruitA.markedForDeletion = true;
                    fruitB.markedForDeletion = true;

                    // Process merge
                    mergeFruits(fruitA,fruitB);
                }
            });
        }


        // Merge two fruits
        function mergeFruits(fruitA,fruitB) {
            // CRITICAL SAFETY CHECKS
            if (!gameState.fruits.includes(fruitA) || !gameState.fruits.includes(fruitB)) {
                return;
            }

            if (!fruitA.markedForDeletion || !fruitB.markedForDeletion) {
                return;
            }

            if (!fruitA.body || !fruitB.body) {
                return;
            }

            // No explicit win condition: merging proceeds normally even for cavemen -> human.

            // Calculate midpoint for new fruit
            const midX = (fruitA.body.position.x + fruitB.body.position.x) / 2;
            const midY = (fruitA.body.position.y + fruitB.body.position.y) / 2;

            // Calculate mass-weighted average velocity (damped for stability)
            const totalMass = fruitA.body.mass + fruitB.body.mass;
            const avgVelX = (fruitA.body.velocity.x * fruitA.body.mass + fruitB.body.velocity.x * fruitB.body.mass) / totalMass;
            const avgVelY = (fruitA.body.velocity.y * fruitA.body.mass + fruitB.body.velocity.y * fruitB.body.mass) / totalMass;

            lib.log('Merging fruits #' + fruitA.id + ' and #' + fruitB.id + ' at (' + midX.toFixed(1) + ', ' + midY.toFixed(1) + ')');

            // Remove old fruits from game state FIRST
            const indexA = gameState.fruits.indexOf(fruitA);
            const indexB = gameState.fruits.indexOf(fruitB);

            if (indexA > -1) gameState.fruits.splice(indexA,1);
            if (indexB > -1) {
                const newIndexB = gameState.fruits.indexOf(fruitB);
                if (newIndexB > -1) gameState.fruits.splice(newIndexB,1);
            }

            // Remove from physics world
            Matter.World.remove(world,fruitA.body);
            Matter.World.remove(world,fruitB.body);

            // Create new fruit
            const newType = fruitA.type + 1;
            const newFruitType = FRUIT_TYPES[newType];
            const radius = (newFruitType.size / 2) * 0.83;
            const baseDensity = 0.001;
            const sizeRatio = newFruitType.size / FRUIT_TYPES[0].size;
            const massMultiplier = Math.pow(sizeRatio,2.5);
            const density = baseDensity * massMultiplier;

            // Ensure spawn position is safe (above floor with clearance)
            const containerBottom = CONTAINER_Y + CONTAINER_HEIGHT;
            const floorOffset = CONTAINER_HEIGHT * 0.05; // 5% offset downward
            const floorTopEdge = containerBottom + floorOffset - 30; // Top edge of floor collision body
            const safeY = Math.min(midY,floorTopEdge - radius - 5);

            const body = Matter.Bodies.circle(midX,safeY,radius,{
                restitution: 0.15,
                friction: 0.8,
                density: density,
                frictionAir: 0.005,
                frictionStatic: 0.8,
                slop: 0.01
            });

            // Set velocity - damped for stability
            Matter.Body.setVelocity(body,{
                x: avgVelX * 0.4,
                y: Math.min(avgVelY * 0.4,3) // Cap downward velocity
            });

            // Add to physics world
            Matter.World.add(world,body);

            // Create new fruit object
            const newFruit = {
                type: newType,
                body: body,
                image: assetCache[newFruitType.assetId],
                visualSize: newFruitType.size,
                    hasTouchedAnother: true,
                canCauseGameOver: false,
                fallTime: 0,
                lastY: safeY,
                markedForDeletion: false,
                mergeCooldown: 100, // Short cooldown to prevent immediate re-merge
                id: Math.random().toString(36).substr(2,9),
                // Animation state (for ooze type 0, cell type 1, bacteria type 2, jellyfish type 3, fish type 4, amphibian type 5, reptile type 6, mammal type 7, primate type 8, caveman type 9, and human type 10)
                animationPlayer: (() => {
                    let player = null;
                    if (newType === 0) player = lib.getAnimationPlayer('evo_ooze_grumpy');
                    else if (newType === 1) player = lib.getAnimationPlayer('evo_cell_smile');
                    else if (newType === 2) player = lib.getAnimationPlayer('evo_bacteria_wink');
                    else if (newType === 3) player = lib.getAnimationPlayer('evo_jellyfish_sad');
                    else if (newType === 4) player = lib.getAnimationPlayer('evo_fish_bubble');
                    else if (newType === 5) player = lib.getAnimationPlayer('evo_amphibian_lick');
                    else if (newType === 6) player = lib.getAnimationPlayer('evo_reptile_yawn');
                    else if (newType === 7) player = lib.getAnimationPlayer('evo_mammal_shiver');
                    else if (newType === 8) {
                        player = lib.getAnimationPlayer('evo_primate_ooo');
                        lib.log('Created monkey animation player for merged type 8: ' + (player ? 'SUCCESS' : 'FAILED'));
                    }
                    else if (newType === 9) {
                        player = lib.getAnimationPlayer('evo_caveman_sleep');
                        lib.log('Created caveman animation player for merged type 9: ' + (player ? 'SUCCESS' : 'FAILED'));
                    }
                    else if (newType === 10) {
                        player = lib.getAnimationPlayer('evo_human_phone');
                        lib.log('Created human animation player for merged type 10: ' + (player ? 'SUCCESS' : 'FAILED'));
                    }
                    return player;
                })(),
                isAnimating: false,
                nextAnimationTime: (newType === 0 || newType === 1 || newType === 2 || newType === 3 || newType === 4 || newType === 5 || newType === 6 || newType === 7 || newType === 8 || newType === 9 || newType === 10) ? Date.now() + 3000 + Math.random() * 5000 : 0 // Random 3-8 seconds
            };

            // Add new fruit to game state
            gameState.fruits.push(newFruit);

            lib.log('Created merged fruit #' + newFruit.id + ' type ' + newType + ' at (' + midX.toFixed(1) + ', ' + safeY.toFixed(1) + ')');

            // Award points
            const points = FRUIT_TYPES[newType].points;
            gameState.score += points;
            updateScoreDisplay();

            // Create effects
            createParticles(midX,safeY,FRUIT_TYPES[newType].size);
            createScorePopup(midX,safeY,points);

            // Play sound
            playSound('sound_evolve');
        }


        // Create a fruit
        // Create a fruit
        // Create a fruit
        // Create a fruit
        function createFruit(type,x,y) {
            const fruitType = FRUIT_TYPES[type];
            const radius = (fruitType.size / 2) * 0.83;

            // Calculate mass based on size
            const baseDensity = 0.001;
            const sizeRatio = fruitType.size / FRUIT_TYPES[0].size;
            const massMultiplier = Math.pow(sizeRatio,2.5);
            const density = baseDensity * massMultiplier;

            const body = Matter.Bodies.circle(x,y,radius,{
                restitution: 0.15,      // Less bouncy for stability
                friction: 0.8,
                density: density,
                frictionAir: 0.005,     // Reduced air resistance for faster fall
                frictionStatic: 0.8,
                slop: 0.01              // Tighter collision tolerance
            });

            Matter.World.add(world,body);

            const fruit = {
                type: type,
                body: body,
                image: assetCache[fruitType.assetId],
                visualSize: fruitType.size,
                canCauseGameOver: false,
                fallTime: 0,
                lastY: y,
                markedForDeletion: false,
                mergeCooldown: 0,
                id: Math.random().toString(36).substr(2,9), // Unique ID for debugging
                // Animation state (for ooze type 0, cell type 1, bacteria type 2, jellyfish type 3, fish type 4, amphibian type 5, reptile type 6, mammal type 7, primate type 8, caveman type 9, and human type 10)
                animationPlayer: (() => {
                    let player = null;
                    if (type === 0) player = lib.getAnimationPlayer('evo_ooze_grumpy');
                    else if (type === 1) player = lib.getAnimationPlayer('evo_cell_smile');
                    else if (type === 2) player = lib.getAnimationPlayer('evo_bacteria_wink');
                    else if (type === 3) player = lib.getAnimationPlayer('evo_jellyfish_sad');
                    else if (type === 4) player = lib.getAnimationPlayer('evo_fish_bubble');
                    else if (type === 5) player = lib.getAnimationPlayer('evo_amphibian_lick');
                    else if (type === 6) player = lib.getAnimationPlayer('evo_reptile_yawn');
                    else if (type === 7) player = lib.getAnimationPlayer('evo_mammal_shiver');
                    else if (type === 8) {
                        player = lib.getAnimationPlayer('evo_primate_ooo');
                        lib.log('Created monkey animation player for type 8: ' + (player ? 'SUCCESS' : 'FAILED'));
                    }
                    else if (type === 9) {
                        player = lib.getAnimationPlayer('evo_caveman_sleep');
                        lib.log('Created caveman animation player for type 9: ' + (player ? 'SUCCESS' : 'FAILED'));
                    }
                    else if (type === 10) {
                        player = lib.getAnimationPlayer('evo_human_phone');
                        lib.log('Created human animation player for type 10: ' + (player ? 'SUCCESS' : 'FAILED'));
                    }
                    return player;
                })(),
                isAnimating: false,
                nextAnimationTime: (type === 0 || type === 1 || type === 2 || type === 3 || type === 4 || type === 5 || type === 6 || type === 7 || type === 8 || type === 9 || type === 10) ? Date.now() + 3000 + Math.random() * 5000 : 0 // Random 3-8 seconds
            };

            lib.log('Created fruit #' + fruit.id + ' type ' + type + ' at (' + x.toFixed(1) + ', ' + y.toFixed(1) + ') radius: ' + radius.toFixed(1));

            return fruit;
        }

        // Generate next life form
        function generateNextFruit() {
            // Only first 4 evolution stages can spawn (up to jellyfish)
            const type = Math.floor(Math.random() * 4);
            const assetId = FRUIT_TYPES[type].assetId;
            const cachedImage = assetCache[assetId];

            gameState.nextFruit = {
                type: type,
                image: cachedImage || null // Use null if asset not loaded yet
            };
        }

        // Drop fruit
        function dropFruit() {
            if (gameState.isDropping || gameState.gameOver || gameState.gameWon) return;

            gameState.isDropping = true;

            // Create fruit at drop position
            const fruit = createFruit(gameState.nextFruit.type,gameState.dropX,CONTAINER_Y - 50);
            gameState.fruits.push(fruit);

            lib.log('Dropped fruit. Total fruits in game: ' + gameState.fruits.length);

            // Play sound
            playSound('sound_drop');

            // Generate next fruit
            generateNextFruit();

            // One second cooldown before next drop
            setTimeout(() => {
                gameState.isDropping = false;
            },1000);

            // Schedule a game-over check after drop (debounced)
            scheduleGameOverCheck(700);
        }

        // Debounced scheduler for running checkGameOver only when needed
        function scheduleGameOverCheck(delay) {
            if (gameState.gameOver) return;
            if (gameState._gameOverCheckTimer) {
                clearTimeout(gameState._gameOverCheckTimer);
            }
            gameState._gameOverCheckTimer = setTimeout(() => {
                try {
                    checkGameOver();
                } catch (e) {
                    if (window.lib && typeof window.lib.log === 'function') window.lib.log('scheduleGameOverCheck error: ' + e);
                }
                gameState._gameOverCheckTimer = null;
            }, delay || 500);
        }

        // Create particle effect using pooled particles
        function createParticles(x,y,size) {
            const particleCount = 15;
            for (let i = 0; i < particleCount; i++) {
                const particle = getParticle();
                if (!particle) break; // Pool exhausted

                const angle = (Math.PI * 2 * i) / particleCount;
                const speed = 3 + Math.random() * 2;

                particle.x = x;
                particle.y = y;
                particle.vx = Math.cos(angle) * speed;
                particle.vy = Math.sin(angle) * speed;
                particle.life = 1.0;
                particle.size = 4 + Math.random() * 4;
            }
        }

        // Create score popup
        function createScorePopup(x,y,points) {
            gameState.scorePopups.push({
                x: x,
                y: y,
                points: points,
                life: 1.0
            });
        }

        // Update particles using pooled system
        function updateParticles(deltaTime) {
            for (let i = activeParticles.length - 1; i >= 0; i--) {
                const p = activeParticles[i];
                p.x += p.vx;
                p.y += p.vy;
                p.life -= deltaTime * 0.001;

                if (p.life <= 0) {
                    releaseParticle(p);
                }
            }
        }

        // Update score popups
        function updateScorePopups(deltaTime) {
            gameState.scorePopups = gameState.scorePopups.filter(p => {
                p.y -= deltaTime * 0.05;
                p.life -= deltaTime * 0.001;
                return p.life > 0;
            });
        }

        // Check game over condition
        function checkGameOver() {
            if (gameState.gameOver) return;

            // Immediate lose rule: if any fruit's center passes below the loss threshold
            // (CONTAINER_Y + 840) the player loses. This replaces the previous
            // danger-line timer/"win" logic.
            // New rule: compute total piled height from the container bottom upward.
            // We consider the topmost occupied pixel of the pile (minimum top edge of fruits)
            // and compute pileHeight = containerBottom - topmostTopEdge. If pileHeight
            // exceeds 840 px then the player loses.
            try {
                // First mark fruits that have 'entered play' so we only count settled/active
                // fruits in the piled height calculation. This prevents counting freshly
                // dropped fruits that are above the danger line.
                for (let fruit of gameState.fruits) {
                    try {
                        if (!fruit || !fruit.body || !fruit.body.position) continue;
                        if (!fruit.canCauseGameOver && fruit.body.position.y > DANGER_LINE_Y) {
                            fruit.canCauseGameOver = true;
                        }
                    } catch (e) {
                        continue;
                    }
                }

                // New rule requested: among fruits that have entered play, find the
                // fruit whose current piled-height (containerBottom - topEdge) is
                // nearest to 840. Only trigger game over if that nearest value is
                // greater than 840. This avoids triggering immediately after a drop
                // while still responding when the stack approaches/exceeds the limit.
                const containerBottom = CONTAINER_Y + CONTAINER_HEIGHT;
                let nearestFruit = null;
                let nearestDiff = Infinity;
                let nearestPileHeight = 0;

                for (let fruit of gameState.fruits) {
                    if (!fruit || !fruit.body || !fruit.body.position) continue;
                    // Only consider fruits that both have entered play and have touched another fruit
                    if (!fruit.canCauseGameOver) continue;
                    if (!fruit.hasTouchedAnother) continue;

                    // Log positions and flags to help debug premature game-over triggers
                    // try {
                    //     if (window.lib && typeof window.lib.log === 'function') {
                    //         window.lib.log('checkGameOver fruit: y=' + fruit.body.position.y +
                    //             ' canCause=' + fruit.canCauseGameOver + ' touched=' + fruit.hasTouchedAnother);
                    //     }
                    // } catch (e) {
                    //     // ignore
                    // }

                    const size = FRUIT_TYPES[fruit.type] ? FRUIT_TYPES[fruit.type].size : 0;
                    const topEdge = fruit.body.position.y - size / 2;
                    const pileHeight = containerBottom - topEdge;
                    const diff = Math.abs(pileHeight - 890);
                    if (diff < nearestDiff) {
                        nearestDiff = diff;
                        nearestFruit = fruit;
                        nearestPileHeight = pileHeight;
                    }
                }

                if (!nearestFruit) return; // nothing to consider yet

                // Trigger only when the nearest pile height is above the threshold (890)

                console.log('Nearest fruit ID: ' + nearestFruit.id + ' pileHeight: ' + nearestPileHeight);
                if (nearestPileHeight > 890) {
                    triggerGameOver();
                    return;
                }
            } catch (e) {
                // defensive: if anything goes wrong, don't crash; log if available
                if (window.lib && typeof window.lib.log === 'function') window.lib.log('checkGameOver error: ' + e);
            }
        }

        // Trigger game over
        function triggerGameOver() {
            gameState.gameOver = true;
            playSound('sound_gameover');

            // Submit score to leaderboard
            submitScore(gameState.score);

            // Update and save high score
            const isNewHighScore = gameState.score > playerHighScore;
            if (isNewHighScore) {
                playerHighScore = gameState.score;
                updateHighScoreDisplay();
                savePlayerHighScore(playerHighScore); // Save to persistent storage
                document.getElementById('newHighScore').classList.add('show');
            } else {
                document.getElementById('newHighScore').classList.remove('show');
            }

            // Show game over screen
            document.getElementById('finalScore').textContent = gameState.score;
            document.getElementById('gameOverScreen').classList.add('show');
        }

        // Trigger win condition
        function triggerWin() {
            gameState.gameWon = true;
            gameState.gameOver = true; // Also set gameOver to stop gameplay

            // Play evolution sound for victory
            playSound('sound_evolve');

            // Submit score to leaderboard
            submitScore(gameState.score);

            // Update and save high score
            if (gameState.score > playerHighScore) {
                playerHighScore = gameState.score;
                updateHighScoreDisplay();
                savePlayerHighScore(playerHighScore); // Save to persistent storage
            }

            // Show win screen
            document.getElementById('winScore').textContent = gameState.score;
            document.getElementById('winScreen').classList.add('show');

            // Create massive particle celebration
            for (let i = 0; i < 100; i++) {
                setTimeout(() => {
                    createParticles(
                        CONTAINER_X + Math.random() * CONTAINER_WIDTH,
                        CONTAINER_Y + Math.random() * CONTAINER_HEIGHT,
                        100
                    );
                },i * 20);
            }
        }

        // Play sound
        function playSound(soundId) {
            if (soundId === 'custom_bgm') {
                // Music - use HTML5 Audio, respect music toggle
                const sound = assetCache[soundId];
                if (!sound) return;
                if (!window.gameConfig.audio.musicEnabled) return;
                sound.volume = window.gameConfig.audio.musicVolume;
                sound.play().catch(e => lib.log('Audio play failed: ' + e));
            } else {
                // Sound effects - use Web Audio API
                // Preferred: WebAudio decoded buffer
                if (audioContext && masterGain) {
                    const buffer = soundBuffers[soundId];
                    if (buffer) {
                        try {
                            const source = audioContext.createBufferSource();
                            source.buffer = buffer;
                            source.connect(masterGain);
                            source.start(0);
                            return;
                        } catch (error) {
                            lib.log('Failed to play WebAudio buffer: ' + soundId + ' - ' + error);
                        }
                    }
                }

                // Fallback: play via HTMLAudio using asset map URL (allows SFX even if WebAudio unavailable)
                try {
                    const assetInfo = lib.getAsset(soundId);
                    const url = assetInfo && assetInfo.url;
                    if (url) {
                        const s = new Audio(url);
                        s.volume = (window.gameConfig && window.gameConfig.audio && typeof window.gameConfig.audio.sfxVolume === 'number') ? window.gameConfig.audio.sfxVolume : 0.7;
                        s.play().catch(err => lib.log('Fallback SFX play failed: ' + err));
                        return;
                    }
                } catch (e) { /* ignore */ }

                lib.log('Sound not played (no WebAudio buffer and no fallback url): ' + soundId);
            }
        }

        // Play sound with custom volume multiplier
        function playSoundWithVolume(soundId,volumeMultiplier) {
            if (soundId === 'custom_bgm') {
                // Music - use HTML5 Audio, respect music toggle
                const sound = assetCache[soundId];
                if (!sound) return;
                if (!window.gameConfig.audio.musicEnabled) return;
                sound.volume = window.gameConfig.audio.musicVolume * volumeMultiplier;
                sound.play().catch(e => lib.log('Audio play failed: ' + e));
            } else {
                // Sound effects - use Web Audio API with volume multiplier
                if (!audioContext || !masterGain) {
                    lib.log('Web Audio not initialized, skipping sound: ' + soundId);
                    return;
                }

                const buffer = soundBuffers[soundId];
                if (!buffer) {
                    lib.log('Sound buffer not found: ' + soundId);
                    return;
                }

                try {
                    // Create source node
                    const source = audioContext.createBufferSource();
                    source.buffer = buffer;

                    // Create gain node for this specific sound with volume multiplier
                    const gainNode = audioContext.createGain();
                    gainNode.gain.value = volumeMultiplier;

                    // Connect: source -> gainNode -> masterGain -> destination
                    source.connect(gainNode);
                    gainNode.connect(masterGain);

                    // Play immediately
                    source.start(0);
                } catch (error) {
                    lib.log('Failed to play sound: ' + soundId + ' - ' + error);
                }
            }
        }

        // Update score display
        function updateScoreDisplay() {
            const scoreElement = document.getElementById('scoreValue');
            if (!scoreElement) return;

            scoreElement.textContent = gameState.score;
            scoreElement.classList.add('highlight');
            setTimeout(() => {
                scoreElement.classList.remove('highlight');
            },300);

            // Update high score in real-time if current score exceeds it
            if (gameState.score > playerHighScore) {
                playerHighScore = gameState.score;
                updateHighScoreDisplay();
                // Save the new high score immediately to persistent storage
                savePlayerHighScore(playerHighScore);
            }
        }

        // Update high score display
        function updateHighScoreDisplay() {
            const highScoreElement = document.getElementById('highScoreValue');
            if (!highScoreElement) return;

            highScoreElement.textContent = playerHighScore;
            highScoreElement.classList.add('highlight');
            setTimeout(() => {
                highScoreElement.classList.remove('highlight');
            },300);
        }

        // Restart game
        function restartGame() {
            // Only clear physics if engine exists
            if (engine && world) {
                Matter.World.clear(world,false);
                Matter.Engine.clear(engine);
            }

            // Reset game state
            gameState = {
                score: 0,
                fruits: [],
                nextFruit: null,
                dropX: CANVAS_WIDTH / 2,
                isDropping: false,
                gameOver: false,
                gameWon: false,
                dangerTimer: null,
                particles: [],
                scorePopups: []
            };

            // Reset particle pool
            for (let i = 0; i < particlePool.length; i++) {
                particlePool[i].active = false;
            }
            activeParticles = [];

            // Hide game over and win screens
            const gameOverScreen = document.getElementById('gameOverScreen');
            const winScreen = document.getElementById('winScreen');
            if (gameOverScreen) gameOverScreen.classList.remove('show');
            if (winScreen) winScreen.classList.remove('show');

            // Reinitialize
            initPhysics();
            generateNextFruit();
            updateScoreDisplay();
            updateHighScoreDisplay();

            // Restart music if enabled
            if (window.gameConfig.audio.musicEnabled) {
                const music = assetCache['custom_bgm'];
                if (music) {
                    music.currentTime = 0;
                    music.play().catch(e => lib.log('Audio play failed: ' + e));
                }
            }
        }

        // Render game
        // Render game
        function render() {
            // Clear canvas
            ctx.clearRect(0,0,CANVAS_WIDTH,CANVAS_HEIGHT);

            // Draw background
            const bgAsset = assetCache[window.gameConfig.background.assetId];
            if (bgAsset && bgAsset.complete && bgAsset.width > 0) {
                ctx.save();
                ctx.filter = `blur(${window.gameConfig.background.blur}px)`;

                // Calculate scale to cover canvas
                const bgAspect = bgAsset.width / bgAsset.height;
                const canvasAspect = CANVAS_WIDTH / CANVAS_HEIGHT;
                let drawWidth,drawHeight,drawX,drawY;

                if (bgAspect > canvasAspect) {
                    drawHeight = CANVAS_HEIGHT;
                    drawWidth = drawHeight * bgAspect;
                    drawX = (CANVAS_WIDTH - drawWidth) / 2;
                    drawY = 0;
                } else {
                    drawWidth = CANVAS_WIDTH;
                    drawHeight = drawWidth / bgAspect;
                    drawX = 0;
                    drawY = (CANVAS_HEIGHT - drawHeight) / 2;
                }

                ctx.drawImage(bgAsset,drawX,drawY,drawWidth,drawHeight);
                ctx.restore();
            } else {
                // Fallback background color while loading
                ctx.fillStyle = '#FFF8E1';
                ctx.fillRect(0,0,CANVAS_WIDTH,CANVAS_HEIGHT);
            }

            // Draw container with subtle texture
            ctx.fillStyle = window.gameConfig.container.backgroundColor;
            ctx.fillRect(CONTAINER_X,CONTAINER_Y,CONTAINER_WIDTH,CONTAINER_HEIGHT);

            // Add subtle inner shadow for depth
            const gradient = ctx.createLinearGradient(CONTAINER_X,CONTAINER_Y,CONTAINER_X,CONTAINER_Y + 100);
            gradient.addColorStop(0,'rgba(0, 0, 0, 0.1)');
            gradient.addColorStop(1,'rgba(0, 0, 0, 0)');
            ctx.fillStyle = gradient;
            ctx.fillRect(CONTAINER_X,CONTAINER_Y,CONTAINER_WIDTH,100);

            ctx.strokeStyle = window.gameConfig.container.borderColor;
            ctx.lineWidth = window.gameConfig.container.borderWidth;
            ctx.strokeRect(CONTAINER_X,CONTAINER_Y,CONTAINER_WIDTH,CONTAINER_HEIGHT);

            // Draw danger line
            const dangerAlpha = gameState.dangerTimer ? 0.8 : 0.3;
            const dangerPulse = gameState.dangerTimer ? Math.sin(Date.now() * 0.01) * 0.2 + 0.8 : 1;
            ctx.strokeStyle = window.gameConfig.visual.dangerLineColor;
            ctx.globalAlpha = dangerAlpha * dangerPulse;
            ctx.lineWidth = 3;
            ctx.setLineDash([10,5]);
            ctx.beginPath();
            ctx.moveTo(CONTAINER_X,DANGER_LINE_Y);
            ctx.lineTo(CONTAINER_X + CONTAINER_WIDTH,DANGER_LINE_Y);
            ctx.stroke();
            ctx.setLineDash([]);
            ctx.globalAlpha = 1;

            // Draw fruits
            gameState.fruits.forEach(fruit => {
                const pos = fruit.body.position;
                const size = FRUIT_TYPES[fruit.type].size;

                ctx.save();
                ctx.translate(pos.x,pos.y);
                ctx.rotate(fruit.body.angle);

                // Check if ooze, cell, bacteria, jellyfish, fish, amphibian, reptile, mammal, primate, caveman, or human should play animation
                if ((fruit.type === 0 || fruit.type === 1 || fruit.type === 2 || fruit.type === 3 || fruit.type === 4 || fruit.type === 5 || fruit.type === 6 || fruit.type === 7 || fruit.type === 8 || fruit.type === 9 || fruit.type === 10) && fruit.animationPlayer) {
                    const currentTime = Date.now();

                    // Check if it's time to start a new animation
                    if (!fruit.isAnimating && currentTime >= fruit.nextAnimationTime) {
                        fruit.isAnimating = true;
                        fruit.animationPlayer.reset();
                    }

                    // If animating, update and draw animation
                    if (fruit.isAnimating) {
                        fruit.animationPlayer.update(performance.now());
                        const frameInfo = fruit.animationPlayer.getCurrentFrame();

                        // Check if animation is complete
                        if (frameInfo.index === frameInfo.total - 1) {
                            fruit.isAnimating = false;
                            // Schedule next animation in 3-8 seconds
                            fruit.nextAnimationTime = currentTime + 3000 + Math.random() * 5000;
                        }

                        // Draw animation - scale based on stage
                        // Stage 2 (bacteria) uses 0.925 to split the difference
                        // Stage 4 (fish) uses expanded width for pufferfish bubble animation
                        let animScale = fruit.type === 2 ? 0.925 : 0.85;
                        let animWidth = FRUIT_TYPES[fruit.type].size * animScale;
                        let animHeight = FRUIT_TYPES[fruit.type].size * animScale;

                        // Expand pufferfish width
                        if (fruit.type === 4) {
                            animWidth = FRUIT_TYPES[fruit.type].size * 0.975;
                        }

                        // Use default scale for amphibian (frog)
                        if (fruit.type === 5) {
                            animWidth = FRUIT_TYPES[fruit.type].size * 0.80;
                            animHeight = FRUIT_TYPES[fruit.type].size * 0.80;
                        }

                        // Use default scale for reptile (dinosaur)
                        if (fruit.type === 6) {
                            animWidth = FRUIT_TYPES[fruit.type].size * 0.85;
                            animHeight = FRUIT_TYPES[fruit.type].size * 0.85;
                        }

                        // Use default scale for mammal (hedgehog)
                        if (fruit.type === 7) {
                            animWidth = FRUIT_TYPES[fruit.type].size * 0.92;
                            animHeight = FRUIT_TYPES[fruit.type].size * 0.85;
                        }

                        // Use default scale for primate (monkey)
                        if (fruit.type === 8) {
                            animWidth = FRUIT_TYPES[fruit.type].size * 0.92;
                            animHeight = FRUIT_TYPES[fruit.type].size * 0.92;
                        }

                        // Use default scale for caveman
                        if (fruit.type === 9) {
                            animWidth = FRUIT_TYPES[fruit.type].size * 0.92;
                            animHeight = FRUIT_TYPES[fruit.type].size * 0.92;
                        }

                        // Use default scale for modern human
                        if (fruit.type === 10) {
                            animWidth = FRUIT_TYPES[fruit.type].size * 0.92;
                            animHeight = FRUIT_TYPES[fruit.type].size * 0.92;
                        }

                        fruit.animationPlayer.draw(ctx,-animWidth / 2,-animHeight / 2,animWidth,animHeight);
                    } else {
                        // Draw static image when not animating
                        if (fruit.image) {
                            ctx.drawImage(fruit.image,-size / 2,-size / 2,size,size);
                        } else {
                            // Fallback circle
                            ctx.fillStyle = '#ff6b6b';
                            ctx.beginPath();
                            ctx.arc(0,0,size / 2,0,Math.PI * 2);
                            ctx.fill();
                        }
                    }
                } else {
                    // Other fruits: draw normally
                    if (fruit.image) {
                        ctx.drawImage(fruit.image,-size / 2,-size / 2,size,size);
                    } else {
                        // Fallback circle
                        ctx.fillStyle = '#ff6b6b';
                        ctx.beginPath();
                        ctx.arc(0,0,size / 2,0,Math.PI * 2);
                        ctx.fill();
                    }
                }

                ctx.restore();
            });


            // Draw drop indicator with next creature preview
            if (gameState.nextFruit && !gameState.gameOver && !gameState.gameWon) {
                const previewSize = FRUIT_TYPES[gameState.nextFruit.type].size;
                const bubbleY = CONTAINER_Y - 30; // Align with top of aim line

                // Draw drop indicator line with shadow
                ctx.strokeStyle = 'rgba(0, 0, 0, 0.2)';
                ctx.lineWidth = 3;
                ctx.setLineDash([8,8]);
                ctx.beginPath();
                ctx.moveTo(gameState.dropX,bubbleY);
                ctx.lineTo(gameState.dropX,CONTAINER_Y + CONTAINER_HEIGHT);
                ctx.stroke();
                ctx.setLineDash([]);

                // Draw bubble background with glow effect
                ctx.save();
                ctx.globalAlpha = 0.9;

                // Outer glow
                const bubbleGradient = ctx.createRadialGradient(
                    gameState.dropX,bubbleY,0,
                    gameState.dropX,bubbleY,previewSize / 2 + 10
                );
                bubbleGradient.addColorStop(0,'rgba(255, 255, 255, 0.8)');
                bubbleGradient.addColorStop(0.7,'rgba(255, 255, 255, 0.4)');
                bubbleGradient.addColorStop(1,'rgba(255, 255, 255, 0)');
                ctx.fillStyle = bubbleGradient;
                ctx.beginPath();
                ctx.arc(gameState.dropX,bubbleY,previewSize / 2 + 10,0,Math.PI * 2);
                ctx.fill();

                // Bubble circle
                ctx.fillStyle = 'rgba(255, 255, 255, 0.95)';
                ctx.strokeStyle = 'rgba(0, 0, 0, 0.2)';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.arc(gameState.dropX,bubbleY,previewSize / 2 + 5,0,Math.PI * 2);
                ctx.fill();
                ctx.stroke();

                ctx.restore();

                // Draw the next creature asset inside the bubble
                if (gameState.nextFruit.image) {
                    ctx.save();
                    ctx.globalAlpha = 1;
                    ctx.drawImage(
                        gameState.nextFruit.image,
                        gameState.dropX - previewSize / 2,
                        bubbleY - previewSize / 2,
                        previewSize,
                        previewSize
                    );
                    ctx.restore();
                }

                // Draw shadow preview at drop position (subtle)
                ctx.globalAlpha = 0.15;
                ctx.fillStyle = '#000';
                ctx.beginPath();
                ctx.arc(gameState.dropX,CONTAINER_Y - 20,previewSize / 2,0,Math.PI * 2);
                ctx.fill();
                ctx.globalAlpha = 1;
            }

            // Draw particles using pooled system
            for (let i = 0; i < activeParticles.length; i++) {
                const p = activeParticles[i];
                ctx.fillStyle = window.gameConfig.visual.particleColor;
                ctx.globalAlpha = p.life;
                ctx.beginPath();
                ctx.arc(p.x,p.y,p.size,0,Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1;

            // Draw score popups
            gameState.scorePopups.forEach(p => {
                ctx.fillStyle = '#FF9800';
                ctx.strokeStyle = '#fff';
                ctx.lineWidth = 5;
                ctx.font = 'bold 56px Poppins';
                ctx.textAlign = 'center';
                ctx.globalAlpha = p.life;
                ctx.strokeText(`+${p.points}`,p.x,p.y);
                ctx.fillText(`+${p.points}`,p.x,p.y);
            });
            ctx.globalAlpha = 1;
        }

        // Game loop
        let lastTime = Date.now();
        function gameLoop() {
            const currentTime = Date.now();
            const deltaTime = currentTime - lastTime;
            lastTime = currentTime;

            // Only update physics if engine is initialized
            if (engine && currentMode === 'play' && !gameState.gameOver) {
                // Update merge cooldowns
                gameState.fruits.forEach(fruit => {
                    if (fruit.mergeCooldown > 0) {
                        fruit.mergeCooldown -= deltaTime;
                    }
                });

                // Update physics with fixed timestep for stability
                const fixedDelta = 16.67; // 60 FPS
                Matter.Engine.update(engine,fixedDelta);

                // CONTINUOUS PROXIMITY-BASED MERGE CHECK
                // Check every frame for fruits that are touching but didn't trigger collision events
                for (let i = 0; i < gameState.fruits.length; i++) {
                    const fruitA = gameState.fruits[i];
                    if (fruitA.markedForDeletion || fruitA.mergeCooldown > 0) continue;

                    for (let j = i + 1; j < gameState.fruits.length; j++) {
                                               const fruitB = gameState.fruits[j];
                        if (fruitB.markedForDeletion || fruitB.mergeCooldown > 0) continue;

                        // Check if same type and close enough to merge
                        if (fruitA.type === fruitB.type && fruitA.type < FRUIT_TYPES.length - 1) {
                            const dx = fruitA.body.position.x - fruitB.body.position.x;
                            const dy = fruitA.body.position.y - fruitB.body.position.y;
                            const distance = Math.sqrt(dx * dx + dy * dy);

                            // Calculate merge threshold (sum of radii with small tolerance)
                            const radiusA = (FRUIT_TYPES[fruitA.type].size / 2) * 0.83;
                            const radiusB = (FRUIT_TYPES[fruitB.type].size / 2) * 0.83;
                            const mergeThreshold = (radiusA + radiusB) * 1.05; // 5% overlap tolerance

                            if (distance < mergeThreshold) {
                                // Fruits are touching! Mark for merge
                                fruitA.markedForDeletion = true;
                                fruitB.markedForDeletion = true;
                                mergeFruits(fruitA,fruitB);
                                break; // Exit inner loop since fruitA is now merged
                            }
                        }
                    }
                }

                // CRITICAL: Safety check for fruits falling through floor
                const containerBottom = CONTAINER_Y + CONTAINER_HEIGHT; // Visual bottom at 1180
                const floorOffset = CONTAINER_HEIGHT * 0.05; // 5% offset downward
                const floorTopEdge = containerBottom + floorOffset - 30; // Top edge of floor collision body
                const maxAllowedY = containerBottom + floorOffset + 10; // Small tolerance below visual bottom

                for (let i = gameState.fruits.length - 1; i >= 0; i--) {
                    const fruit = gameState.fruits[i];

                    // Check if fruit has fallen through the floor

                    if (fruit.body.position.y > maxAllowedY) {
                        lib.log('WARNING: Fruit #' + fruit.id + ' fell through floor! Y: ' + fruit.body.position.y.toFixed(1) + ' (max: ' + maxAllowedY + ')');
                        lib.log('  Velocity: (' + fruit.body.velocity.x.toFixed(2) + ', ' + fruit.body.velocity.y.toFixed(2) + ')');
                        lib.log('  Speed: ' + Matter.Body.getSpeed(fruit.body).toFixed(2));

                        // Emergency teleport back to safe position
                        const radius = (FRUIT_TYPES[fruit.type].size / 2) * 0.83;
                        Matter.Body.setPosition(fruit.body,{
                            x: fruit.body.position.x,
                            y: floorTopEdge - radius - 5
                        });
                        Matter.Body.setVelocity(fruit.body, { x: 0, y: 0 });
                        Matter.Body.setAngularVelocity(fruit.body, 0);

                        lib.log('  Teleported back to Y: ' + fruit.body.position.y.toFixed(1));
                    }
                }

                // Update particles and popups
                updateParticles(deltaTime);
                updateScorePopups(deltaTime);

                // Game-over checks are debounced and triggered on drops/collisions to avoid per-frame work

            } else if (gameState.gameWon) {
                // Still update particles during win celebration
                updateParticles(deltaTime);
                updateScorePopups(deltaTime);
            }

            // Always render
            if (ctx) {
                render();
            }

            requestAnimationFrame(gameLoop);
        }


        // Input handling
        function setupInput() {
            const isTouchDevice = 'ontouchstart' in window;

            if (isTouchDevice) {
                // Touch controls
                canvas.addEventListener('touchmove',(e) => {
                    if (gameState.gameOver || gameState.gameWon || currentMode !== 'play') return;
                    e.preventDefault();
                    const touch = e.touches[0];
                    const rect = canvas.getBoundingClientRect();
                    const x = (touch.clientX - rect.left) * (CANVAS_WIDTH / rect.width);
                    gameState.dropX = Math.max(CONTAINER_X + 50,Math.min(CONTAINER_X + CONTAINER_WIDTH - 50,x));
                });

                canvas.addEventListener('touchend',(e) => {
                    if (gameState.gameOver || gameState.gameWon || currentMode !== 'play') return;
                    e.preventDefault();
                    dropFruit();
                });
            } else {
                // Mouse controls
                canvas.addEventListener('mousemove',(e) => {
                    if (gameState.gameOver || gameState.gameWon || currentMode !== 'play') return;
                    const rect = canvas.getBoundingClientRect();
                    const x = (e.clientX - rect.left) * (CANVAS_WIDTH / rect.width);
                    gameState.dropX = Math.max(CONTAINER_X + 50,Math.min(CONTAINER_X + CONTAINER_WIDTH - 50,x));
                });

                canvas.addEventListener('click',(e) => {
                    if (gameState.gameOver || gameState.gameWon || currentMode !== 'play') return;
                    dropFruit();
                });

                // Keyboard controls
                document.addEventListener('keydown',(e) => {
                    if (gameState.gameOver || gameState.gameWon || currentMode !== 'play') return;

                    if (e.key === 'ArrowLeft') {
                        gameState.dropX = Math.max(CONTAINER_X + 50,gameState.dropX - 10);
                    } else if (e.key === 'ArrowRight') {
                        gameState.dropX = Math.min(CONTAINER_X + CONTAINER_WIDTH - 50,gameState.dropX + 10);
                    } else if (e.key === ' ' || e.key === 'ArrowDown') {
                        e.preventDefault();
                        dropFruit();
                    }
                });
            }
        }

        function run(mode) {
            // Always run in 'play' mode regardless of parameter
            mode = 'play';
            lib.log('run() called. Mode: ' + mode);
            currentMode = mode;

            try {
                // Initialize canvas immediately
                canvas = document.getElementById('gameCanvas');
                if (!canvas) {
                    lib.log('ERROR: Canvas element not found');
                    return;
                }
                ctx = canvas.getContext('2d');
                if (!ctx) {
                    lib.log('ERROR: Could not get canvas context');
                    return;
                }
                // Disable image smoothing so pixel-art sprites scale crisply
                try { ctx.imageSmoothingEnabled = false; ctx.webkitImageSmoothingEnabled = false; } catch(e){}

                // Initialize particle pool early
                initParticlePool();

                // Setup UI listeners immediately
                setupUIListeners();

                // Initialize leaderboard system
                initLeaderboard();

                // Update displays with initial values
                updateScoreDisplay();
                updateHighScoreDisplay();
                updateMusicButton();

                // Start game loop immediately (will render loading state if needed)
                gameLoop();

                // Preload assets in background
                preloadAssets(async () => {
                    lib.log('Assets loaded - initializing game');

                    try {
                        // Initialize evolution legend AFTER assets are loaded
                        initializeLegend();

                        // Load splash screen images and animation
                        const logoImg = document.getElementById('startLogo');

                        if (logoImg && assetCache['logo_evolution_merge']) {
                            logoImg.src = assetCache['logo_evolution_merge'].src;
                        }

                        // Create animation player for splash scene
                        const splashAnimPlayer = lib.getAnimationPlayer('splash_scene_animated');
                        if (splashAnimPlayer) {
                            window.splashAnimationPlayer = splashAnimPlayer;
                            lib.log('Splash scene animation player created');
                        } else {
                            lib.log('Warning: Could not create splash scene animation player');
                        }

                        // Initialize physics engine
                        initPhysics();

                        // Generate first fruit
                        generateNextFruit();

                        // Setup input handlers
                        setupInput();

                        // Load player's high score from persistent storage BEFORE showing start screen
                        await loadPlayerHighScore();

                        // Initialize and show start screen after loading is complete
                        // auto-start gameplay immediately (no start screen)
                        startGame();

                        lib.log('Game initialization complete');
                    } catch (error) {
                        lib.log('ERROR during game initialization: ' + error.message);
                    }
                });
            } catch (error) {
                lib.log('ERROR in run(): ' + error.message);
            }
        }
         // ENTRY POINT
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
