import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/models/option_quesion_model.dart';
import 'package:logic_mathematics/cores/models/ai_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Shared {
  static final Shared _singleton = Shared._internal();

  factory Shared() {
    return _singleton;
  }

  Shared._internal();

  static Shared get instance => _singleton;
  late PackageInfo _packageInfo;

  final character = 'data:image/jpeg;base64,';

  bool isShowAds = true;

  String adUnitIdBanner = '';

  String adUnitIdInterstitial = 'ca-app-pub-8031150677135815/4213509223';

  String adOpenAppUnitId = 'ca-app-pub-8031150677135815/3520928322';

  PackageInfo get packageInfo => _packageInfo;

  int cacheUserCoins = 0;

  late final SharedPreferences sharedPreferences;

  OptionQuesionModel numberOfQuestions = OptionQuesionModel(
    option: Difficulty.easy.name,
    numberOfQuestions: 20,
  );

  double get paddingBottom {
    final height = MediaQuery.of(_cacheContext).viewInsets.bottom;
    return height;
  }

  void setPackageInfo(PackageInfo packageInfo) {
    _packageInfo = packageInfo;
  }

  late BuildContext _cacheContext;
  BuildContext get context => _cacheContext;

  void setContext(BuildContext context) {
    _cacheContext = context;
  }

  DateTime lastCheckInDate = DateTime.now();

  ValueNotifier<int> downloadProgress = ValueNotifier<int>(0);
  bool isDownloadingModel = false;
  static const String _progressKey = 'gemma_download_progress';

  // ignore: avoid_init_to_null
  InferenceModel? modelChat = null;

  // ignore: avoid_init_to_null
  ModelAI? modelAI = null;

  bool isInitializedModelAI = false;

  InferenceChat? chat = null;

  void creatModel() {
    // We only initialize the target model here for now
    modelAI = ModelAI.gemma4_mobile;
    isInitializedModelAI = false;
  }

  void clearModel() {
    modelChat?.close();
    modelChat = null;
    isInitializedModelAI = false;
  }

  Future<void> startBackgroundModelDownload() async {
    if (isInitializedModelAI || isDownloadingModel) return;

    creatModel();
    final _modelAI = modelAI;
    if (_modelAI == null) return;

    try {
      // Instant check if already installed
      final isReady = await FlutterGemma.isModelInstalled(_modelAI.filename);

      if (!isReady) {
        // Only delay and restore progress if we actually need to download
        final savedProgress = sharedPreferences.getInt(_progressKey) ?? 0;
        if (savedProgress > 0 && savedProgress < 100) {
          downloadProgress.value = savedProgress;
        }

        // Delay to avoid blocking main thread and UI during app startup
        await Future.delayed(const Duration(seconds: 5));

        isDownloadingModel = true;
        // Using the modern fluent API for download with progress
        await FlutterGemma.installModel(modelType: _modelAI.modelType)
            .fromNetwork(_modelAI.url, token: dotenv.env['HF_TOKEN'])
            .withProgress((progress) {
              downloadProgress.value = progress;
              // Cache progress
              sharedPreferences.setInt(_progressKey, progress);
            })
            .install();
      } else {
        // Set the active model for flutter_gemma unified manager
        FlutterGemmaPlugin.instance.modelManager.setActiveModel(
          InferenceModelSpec.fromLegacyUrl(
            name: _modelAI.filename,
            modelUrl: _modelAI.url,
            modelType: _modelAI.modelType,
            fileType: _modelAI.fileType,
          ),
        );
      }

      // Disable GPU backend for Android Emulators to prevent OpenCL crash
      PreferredBackend backend = _modelAI.preferredBackend;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (!androidInfo.isPhysicalDevice) {
          backend = PreferredBackend.cpu;
        }
      }

      // Model is downloaded, let's create the instances
      modelChat = await FlutterGemmaPlugin.instance.createModel(
        modelType: _modelAI.modelType,
        fileType: _modelAI.fileType,
        preferredBackend: backend,
        maxTokens: _modelAI.maxTokens,
        supportImage: _modelAI.supportImage,
        maxNumImages: _modelAI.maxNumImages,
      );

      chat = await modelChat!.createChat(
        temperature: _modelAI.temperature,
        topK: _modelAI.topK,
        topP: _modelAI.topP,
        modelType: _modelAI.modelType,
      );

      isInitializedModelAI = true;
      isDownloadingModel = false;
      downloadProgress.value = 100;
      await sharedPreferences.setInt(_progressKey, 100);
    } catch (e) {
      debugPrint('Background download failed: $e');
      isDownloadingModel = false;
    }
  }
}
