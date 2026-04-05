import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logic_mathematics/cores/adsmob/ads_mob.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/db_storage/db_storage.dart';
import 'package:logic_mathematics/cores/extentions/httpoverrides_extention.dart';
import 'package:logic_mathematics/cores/extentions/in_app_purchase.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/services/app_lifecycle_handler.dart';
import 'package:logic_mathematics/cores/services/local_notification_service.dart';
import 'package:logic_mathematics/cores/themes/app_theme.dart';
import 'package:logic_mathematics/features/splash/splash_page.dart';
import 'package:logic_mathematics/cores/audio/audio_manager.dart';
import 'package:logic_mathematics/features/subscription/data/datasources/network_time_remote_datasource.dart';
import 'package:logic_mathematics/features/subscription/data/datasources/subscription_local_datasource.dart';
import 'package:logic_mathematics/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:logic_mathematics/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:oziapi/requests/request.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await Firebase.initializeApp();
    await MobileAds.instance.initialize();
    RequestConfiguration configuration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      maxAdContentRating: MaxAdContentRating.g,
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);
  } catch (error) {
    debugPrint('Firebase initialization error: $error');
  }
  try {
    // HuggingFace token from .env file
    await FlutterGemma.initialize(huggingFaceToken: dotenv.env['HF_TOKEN']);
  } catch (e) {
    debugPrint('FlutterGemma initialization error: $e');
  }
  await setUpServiceLocator();
  await initStartApp();
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // Initialize app lifecycle handler
    AppLifecycleHandler.instance.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    AppLifecycleHandler.instance.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ResponsiveSizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              child = EasyLoading.init()(context, child);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1),
                  devicePixelRatio: 1,
                ),
                child: child,
              );
            },
            title: Shared.instance.packageInfo.appName,
            theme: lightTheme.copyWith(
              textTheme: GoogleFonts.notoSansTextTheme(lightTheme.textTheme),
              primaryTextTheme: GoogleFonts.notoSansTextTheme(
                lightTheme.primaryTextTheme,
              ),
            ),
            darkTheme: darkTheme.copyWith(
              textTheme: GoogleFonts.notoSansTextTheme(darkTheme.textTheme),
              primaryTextTheme: GoogleFonts.notoSansTextTheme(
                darkTheme.primaryTextTheme,
              ),
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: ThemeMode.light, //Shared.instance.themeMode,
            home: SplashPage(),
          );
        },
      ),
    );
  }
}

Future<void> initStartApp() async {
  // Initialize Firebase Remote Config and register to service locator
  // try {
  //   final remoteConfig = FirebaseRemoteConfig.instance;
  //   await remoteConfig.setConfigSettings(
  //     RemoteConfigSettings(
  //       fetchTimeout: const Duration(seconds: 10),
  //       minimumFetchInterval: const Duration(minutes: 30),
  //     ),
  //   );
  //   // set safe defaults (isAdmob default true)
  //   // await remoteConfig.setDefaults({'isAdmob': true});
  //   // optional: configure fetch behavior

  //   // fetch and activate values from server
  //   try {
  //     await remoteConfig.fetchAndActivate();
  //     Shared.instance.isShowAds = remoteConfig.getBool('isAdmob');
  //     debugPrint('RemoteConfig fetched: isAdmob=${Shared.instance.isShowAds}');
  //   } catch (_) {
  //     // ignore fetch errors; defaults will be used
  //   }
  //   // register RemoteConfig so other modules can read 'isAdmob'
  //   serviceLocator.registerSingleton<FirebaseRemoteConfig>(remoteConfig);
  // } catch (e) {
  //   debugPrint('RemoteConfig init failed: $e');
  // }

  HttpOverrides.global = HttpoverridesExtention();
  Shared.instance.setPackageInfo(await PackageInfo.fromPlatform());
  Shared.instance.numberOfQuestions = await serviceLocator<DataBaseFuntion>()
      .getNumberOfQuestionsAndDifficulty();
  Shared.instance.sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.get<LocalNotificationService>().initialize();
  Shared.instance.lastCheckInDate = await serviceLocator
      .get<DataBaseFuntion>()
      .getlastCheckInDate();
  await serviceLocator.get<AudioManager>().init();
  debugPrint('Last check-in date: ${Shared.instance.lastCheckInDate}');

  
  // Initialize and verify subscription offline/online
  await serviceLocator.get<SubscriptionRepository>().checkSubscriptionStatus();

  // Start downloading the AI model in the background immediately
  Shared.instance.startBackgroundModelDownload();
}

late GetIt serviceLocator;
Future<void> setUpServiceLocator() async {
  serviceLocator = GetIt.instance;
  serviceLocator.registerSingleton<InternetConnection>(InternetConnection());
  serviceLocator.registerSingleton<AdmobController>(AdmobController());
  serviceLocator.registerSingleton<LocalInAppPurchase>(LocalInAppPurchase());
  serviceLocator.registerSingleton<MessagingService>(MessagingService());
  serviceLocator.registerSingleton<DbStorage>(DbStorage());
  serviceLocator.registerSingleton<DataBaseFuntion>(DataBaseFuntion());
  serviceLocator.registerSingleton<Dio>(Dio());
  serviceLocator.registerSingleton<DeviceInfoPlugin>(DeviceInfoPlugin());
  serviceLocator.registerSingleton<Request>(Request());
  serviceLocator.registerSingleton<ImagePicker>(ImagePicker());
  serviceLocator.registerSingleton<KeyboardVisibilityController>(
    KeyboardVisibilityController(),
  );
  serviceLocator.registerSingleton<LocalNotificationService>(
    LocalNotificationService(),
  );
  serviceLocator.registerSingleton<AudioManager>(AudioManager());

  // Subscription Dependencies
  serviceLocator.registerLazySingleton<NetworkTimeRemoteDataSource>(
    () => NetworkTimeRemoteDataSource(Dio()),
  );
  
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SubscriptionLocalDataSource>(
    () => SubscriptionLocalDataSource(prefs),
  );

  serviceLocator.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      serviceLocator<SubscriptionLocalDataSource>(),
      serviceLocator<NetworkTimeRemoteDataSource>(),
    ),
  );
}
