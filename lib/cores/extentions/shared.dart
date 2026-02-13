import 'package:flutter/material.dart';
// import 'package:flutter_gemma/core/chat.dart';
// import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/models/option_quesion_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // // ignore: avoid_init_to_null
  // late InferenceModel? modelChat = null;

  // // ignore: avoid_init_to_null
  // late ModelAI? modelAI = null;

  // bool isInitializedModelAI = false;

  // InferenceChat? chat = null;

  // void creatModel() {
  //   if (modelAI != null || !isInitializedModelAI) {
  //     serviceLocator.get<DataBaseFuntion>().getOptionAiByName().then((
  //       value,
  //     ) async {
  //       if (value != null) {
  //         modelAI = ModelAI.values.firstWhere(
  //           (element) => element.name == value.modelName,
  //         );
  //         FlutterGemmaPlugin.instance
  //             .createModel(
  //               preferredBackend: modelAI!.preferredBackend,
  //               modelType: modelAI!.modelType,
  //               fileType: modelAI!.fileType,
  //               maxTokens: modelAI!.maxTokens,
  //               supportImage: modelAI!.supportImage,
  //               maxNumImages: modelAI!.maxNumImages,
  //             )
  //             .then((value) {
  //               modelChat = value;
  //               isInitializedModelAI = true;
  //               serviceLocator.get<MessagingService>().send(
  //                 channel: MessageChannel.modelAIChanged,
  //                 parameter: '',
  //               );
  //             });
  //       }
  //     });
  //   }
  // }

  // void clearModel() {
  //   modelChat?.close();
  //   modelChat = null;
  //   isInitializedModelAI = false;
  // }
}
