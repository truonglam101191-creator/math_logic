import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/main.dart';
import 'package:share_plus/share_plus.dart';

class CoinService {
  static final CoinService _singleton = CoinService._internal();
  factory CoinService() => _singleton;
  CoinService._internal();

  static CoinService get instance => _singleton;

  String? _cachedDeviceId;

  /// Load coins from local storage on app start
  Future<void> loadCoinsFromLocal() async {
    final idDevice = await serviceLocator
        .get<DataBaseFuntion>()
        .loadCoinsFromLocal();
    Shared.instance.cacheUserCoins = await serviceLocator
        .get<DataBaseFuntion>()
        .getStar();
    if (idDevice.isEmpty) {
      final deviceId = await _getDeviceId();
      serviceLocator<DataBaseFuntion>().setLoadCoinsFromLocal(deviceId).then((
        value,
      ) async {
        final store = FirebaseFirestore.instance
            .collection('users')
            .doc(deviceId);
        if ((await store.get()).exists) {
          final data = (await store.get()).data() as Map<String, dynamic>;
          final firebaseCoins = data['coins'] ?? 0;

          Shared.instance.cacheUserCoins = firebaseCoins;
          serviceLocator.get<DataBaseFuntion>().saveStar(firebaseCoins).then((
            _,
          ) {
            serviceLocator<MessagingService>().send(
              channel: MessageChannel.startUserChanged,
              parameter: '',
            );
          });
          Shared.instance.lastCheckInDate = DateTime.fromMillisecondsSinceEpoch(
            data['checkin'] ?? 0,
          );
          serviceLocator.get<DataBaseFuntion>().saveLastCheckInDate(
            Shared.instance.lastCheckInDate,
          );
        } else {
          store.set({
            'coins': Shared.instance.cacheUserCoins,
            'lastUpdated': FieldValue.serverTimestamp(),
            'checkin': DateTime.now().millisecondsSinceEpoch,
            'deviceId': deviceId,
          });
        }
      });
    }
  }

  /// Sync coins to Firebase (called when app goes to background or on significant events)
  Future<void> syncCoinsToFirebase() async {
    try {
      final dataBase = serviceLocator.get<DataBaseFuntion>();
      final currentLocalCoins = await dataBase.getStar();
      final lastDay = await dataBase.getlastCheckInDate();

      if (currentLocalCoins == Shared.instance.cacheUserCoins &&
          lastDay.millisecondsSinceEpoch >=
              Shared.instance.lastCheckInDate.millisecondsSinceEpoch) {
        // No changes to sync
        return;
      }
      Shared.instance.cacheUserCoins = currentLocalCoins;
      final deviceId = await _getDeviceId();

      final userData = {
        'coins': await serviceLocator.get<DataBaseFuntion>().getStar(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'checkin': lastDay.millisecondsSinceEpoch,
        'deviceId': deviceId,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(deviceId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing coins to Firebase: $e');
    }
  }

  // /// Sync coins from Firebase (called on app start)
  // Future<void> syncCoinsFromFirebase() async {
  //   try {
  //     final deviceId = await _getDeviceId();
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(deviceId)
  //         .get();

  //     if (userDoc.exists) {
  //       final userData = userDoc.data() as Map<String, dynamic>;
  //       final firebaseCoins = userData['coins'] ?? 0;
  //       final localCoins = await serviceLocator
  //           .get<DataBaseFuntion>()
  //           .getStar();

  //       if (firebaseCoins != localCoins) {
  //         print(
  //           'Synced coins from Firebase: local($localCoins) vs firebase($firebaseCoins) -> $syncedCoins',
  //         );

  //         // If we used Firebase value, mark as no unsynced changes
  //         if (firebaseCoins >= localCoins) {
  //           _hasUnsyncedChanges = false;
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Error syncing coins from Firebase: $e');
  //   }
  // }

  Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      final deviceInfo = serviceLocator<DeviceInfoPlugin>();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _cachedDeviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _cachedDeviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
      } else {
        _cachedDeviceId = 'unknown_device';
      }
      return _cachedDeviceId!;
    } catch (e) {
      _cachedDeviceId = 'error_device_id';
      return _cachedDeviceId!;
    }
  }
}
