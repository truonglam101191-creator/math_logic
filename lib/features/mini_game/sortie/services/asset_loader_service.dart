import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../data/repositories/game_config_repository.dart';

/// Service for loading and caching game assets
class AssetLoaderService {
  final GameConfigRepository _repository;
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, Uint8List> _audioCache = {};

  final _loadingProgress = ValueNotifier<double>(0.0);
  ValueNotifier<double> get loadingProgress => _loadingProgress;

  AssetLoaderService({GameConfigRepository? repository})
    : _repository = repository ?? GameConfigRepository();

  /// Get cached image
  ui.Image? getImage(String assetId) => _imageCache[assetId];

  /// Get cached audio data
  Uint8List? getAudio(String assetId) => _audioCache[assetId];

  /// Check if image is cached
  bool hasImage(String assetId) => _imageCache.containsKey(assetId);

  /// Check if audio is cached
  bool hasAudio(String assetId) => _audioCache.containsKey(assetId);

  /// Get all cached images
  Map<String, ui.Image> get imageCache => Map.unmodifiable(_imageCache);

  /// Preload all assets for a theme
  Future<void> preloadThemeAssets(String themeName) async {
    _loadingProgress.value = 0.0;

    try {
      final assetMap = await _repository.loadAssetMap();
      final themeAssets = <String, dynamic>{};

      // Filter assets for the theme
      for (final entry in assetMap.entries) {
        final assetId = entry.key;
        if (assetId.contains(themeName) || _isCommonAsset(assetId)) {
          themeAssets[assetId] = entry.value;
        }
      }

      if (themeAssets.isEmpty) {
        _loadingProgress.value = 1.0;
        return;
      }

      int loaded = 0;
      final total = themeAssets.length;

      for (final entry in themeAssets.entries) {
        try {
          await _loadAsset(entry.key, entry.value as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Failed to load asset ${entry.key}: $e');
        }
        loaded++;
        _loadingProgress.value = loaded / total;
      }
    } catch (e) {
      debugPrint('Failed to preload theme assets: $e');
      _loadingProgress.value = 1.0;
    }
  }

  /// Check if asset is a common asset (used across themes)
  bool _isCommonAsset(String assetId) {
    return assetId.contains('common') ||
        assetId.contains('ui_') ||
        assetId.contains('sound_') ||
        assetId.contains('tray') || // Load tray images
        assetId.contains('compartment'); // Load compartment images
  }

  /// Load a single asset
  Future<void> _loadAsset(
    String assetId,
    Map<String, dynamic> assetData,
  ) async {
    final url = assetData['url'] as String;
    final type = assetData['type'] as String;

    if (type == 'audio') {
      await _loadAudio(assetId, url);
    } else {
      await _loadImage(assetId, url);
    }
  }

  /// Load image from URL
  Future<void> _loadImage(String assetId, String url) async {
    if (_imageCache.containsKey(assetId)) return;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final image = await _decodeImage(response.bodyBytes);
        if (image != null) {
          _imageCache[assetId] = image;
        }
      }
    } catch (e) {
      debugPrint('Failed to load image $assetId: $e');
    }
  }

  /// Load audio from URL
  Future<void> _loadAudio(String assetId, String url) async {
    if (_audioCache.containsKey(assetId)) return;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _audioCache[assetId] = response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Failed to load audio $assetId: $e');
    }
  }

  /// Decode image bytes to ui.Image
  Future<ui.Image?> _decodeImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('Failed to decode image: $e');
      return null;
    }
  }

  /// Load image from local asset
  Future<ui.Image?> loadLocalImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      return _decodeImage(bytes);
    } catch (e) {
      debugPrint('Failed to load local image $assetPath: $e');
      return null;
    }
  }

  /// Clear all caches
  void clearCache() {
    _imageCache.clear();
    _audioCache.clear();
    _loadingProgress.value = 0.0;
  }

  /// Get asset URL by assetId
  Future<String?> getAssetUrl(String assetId) async {
    try {
      final assetMap = await _repository.loadAssetMap();
      final asset = assetMap[assetId] as Map<String, dynamic>?;
      return asset?['url'] as String?;
    } catch (e) {
      debugPrint('Failed to get asset URL for $assetId: $e');
      return null;
    }
  }

  /// Clear theme-specific cache
  void clearThemeCache(String themeName) {
    _imageCache.removeWhere((key, _) => key.contains(themeName));
    _audioCache.removeWhere((key, _) => key.contains(themeName));
  }

  /// Dispose resources
  void dispose() {
    clearCache();
    _loadingProgress.dispose();
  }
}
