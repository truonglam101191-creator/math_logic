import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/data.dart';

/// Service for loading and caching game assets
class AssetLoaderService {
  final Map<String, ImageProvider> _imageCache = {};
  bool _isLoaded = false;
  double _loadProgress = 0.0;

  bool get isLoaded => _isLoaded;
  double get loadProgress => _loadProgress;

  /// Preload all game images
  Future<void> preloadAssets(BuildContext context) async {
    final assetIds = EvolutionAssetUrls.images.keys.toList();
    final total = assetIds.length;
    var loaded = 0;

    for (final assetId in assetIds) {
      final url = EvolutionAssetUrls.getImageUrl(assetId);
      if (url != null) {
        try {
          final imageProvider = CachedNetworkImageProvider(url);
          await precacheImage(imageProvider, context);
          _imageCache[assetId] = imageProvider;
        } catch (e) {
          debugPrint('Failed to load asset: $assetId - $e');
        }
      }
      loaded++;
      _loadProgress = loaded / total;
    }

    _isLoaded = true;
  }

  /// Get cached image provider
  ImageProvider? getImage(String assetId) {
    return _imageCache[assetId];
  }

  /// Get image URL directly
  String? getImageUrl(String assetId) {
    return EvolutionAssetUrls.getImageUrl(assetId);
  }

  /// Clear cache
  void clearCache() {
    _imageCache.clear();
    _isLoaded = false;
    _loadProgress = 0.0;
  }
}
