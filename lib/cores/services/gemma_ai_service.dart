import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class GemmaAIService {
  static bool _isInitialized = false;
  static String? _currentModelPath;

  // Prevent multiple initializations
  static Future<bool> initializeModel(String modelPath) async {
    try {
      if (_isInitialized && _currentModelPath == modelPath) {
        return true; // Already initialized with same model
      }

      // Cleanup previous model if exists
      if (_isInitialized) {
        await cleanupModel();
      }

      // Validate model file exists and is complete
      final file = File(modelPath);
      if (!await file.exists()) {
        debugPrint('Model file not found: $modelPath');
        return false;
      }

      final fileSize = await file.length();
      if (fileSize < 1024 * 1024) {
        // Less than 1MB
        debugPrint('Model file too small, likely corrupted: $modelPath');
        return false;
      }

      // Check available RAM
      if (!await _hasEnoughRAM()) {
        debugPrint('Not enough RAM for AI model');
        return false;
      }

      _currentModelPath = modelPath;
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing AI model: $e');
      _isInitialized = false;
      _currentModelPath = null;
      return false;
    }
  }

  static Future<bool> _hasEnoughRAM() async {
    // Simple heuristic: assume we need at least 2GB free RAM
    // In production, you might want to check actual available memory
    return true; // Placeholder
  }

  static Future<void> cleanupModel() async {
    try {
      if (_isInitialized) {
        // Cleanup native resources here
        // FlutterGemmaPlugin.instance.cleanup(); // if available
        _isInitialized = false;
        _currentModelPath = null;

        // Force garbage collection
        await Future.delayed(Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('Error cleaning up AI model: $e');
    }
  }

  static bool get isInitialized => _isInitialized;
  static String? get currentModelPath => _currentModelPath;
}
