import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/services/coin_service.dart';
import 'package:logic_mathematics/cores/services/local_notification_service.dart';
import 'package:logic_mathematics/main.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  static final AppLifecycleHandler _singleton = AppLifecycleHandler._internal();
  factory AppLifecycleHandler() => _singleton;
  AppLifecycleHandler._internal();

  static AppLifecycleHandler get instance => _singleton;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        serviceLocator
            .get<LocalNotificationService>()
            .scheduleDailyReminderIfNeeded();
        break;
      case AppLifecycleState.paused:
        CoinService.instance.syncCoinsToFirebase();
        break;
      case AppLifecycleState.inactive:
        CoinService.instance.syncCoinsToFirebase();
        serviceLocator
            .get<LocalNotificationService>()
            .scheduleDailyReminderIfNeeded();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
    }
  }

  // void _syncCoinsFromFirebase() async {
  //   try {
  //     await CoinService.instance.syncCoinsFromFirebase();
  //   } catch (e) {
  //     print('Error syncing coins from Firebase on app resume: $e');
  //   }
  // }
}
