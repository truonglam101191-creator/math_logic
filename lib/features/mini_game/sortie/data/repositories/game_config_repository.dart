import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_config.dart';

/// Repository for loading game configuration from assets
class GameConfigRepository {
  static const String _configPath = 'assets/sortie/config.json';
  static const String _assetMapPath = 'assets/sortie/assetMap.json';

  GameConfig? _cachedConfig;
  Map<String, dynamic>? _cachedAssetMap;

  /// Load game configuration from assets
  Future<GameConfig> loadConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;

    try {
      final jsonString = await rootBundle.loadString(_configPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      _cachedConfig = GameConfig.fromJson(jsonData);
      return _cachedConfig!;
    } catch (e) {
      throw Exception('Failed to load game config: $e');
    }
  }

  /// Load asset map from assets
  Future<Map<String, dynamic>> loadAssetMap() async {
    if (_cachedAssetMap != null) return _cachedAssetMap!;

    try {
      final jsonString = await rootBundle.loadString(_assetMapPath);
      _cachedAssetMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return _cachedAssetMap!;
    } catch (e) {
      throw Exception('Failed to load asset map: $e');
    }
  }

  /// Get asset info by ID
  Future<AssetInfo?> getAssetInfo(String assetId) async {
    final assetMap = await loadAssetMap();
    final assetData = assetMap[assetId];
    if (assetData == null) return null;
    return AssetInfo.fromJson(assetId, assetData as Map<String, dynamic>);
  }

  /// Get all assets for a specific theme
  Future<List<AssetInfo>> getAssetsForTheme(String themeName) async {
    final assetMap = await loadAssetMap();
    final assets = <AssetInfo>[];

    for (final entry in assetMap.entries) {
      final assetInfo = AssetInfo.fromJson(
        entry.key,
        entry.value as Map<String, dynamic>,
      );
      assets.add(assetInfo);
    }

    return assets;
  }

  /// Clear cache
  void clearCache() {
    _cachedConfig = null;
    _cachedAssetMap = null;
  }
}

/// Asset information
class AssetInfo {
  final String id;
  final String url;
  final AssetType type;
  final List<int>? aspectRatio;
  final bool loop;

  const AssetInfo({
    required this.id,
    required this.url,
    required this.type,
    this.aspectRatio,
    this.loop = false,
  });

  factory AssetInfo.fromJson(String id, Map<String, dynamic> json) {
    return AssetInfo(
      id: id,
      url: json['url'] as String,
      type: _parseType(json['type'] as String),
      aspectRatio: (json['aspect_ratio'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      loop: json['loop'] == 'true' || json['loop'] == true,
    );
  }

  static AssetType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'audio':
        return AssetType.audio;
      default:
        return AssetType.image;
    }
  }

  /// Get aspect ratio as double
  double? get aspectRatioValue {
    if (aspectRatio == null || aspectRatio!.length < 2) return null;
    return aspectRatio![0] / aspectRatio![1];
  }
}

/// Asset type enum
enum AssetType { image, audio }
