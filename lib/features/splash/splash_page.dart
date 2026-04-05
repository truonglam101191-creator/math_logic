import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logic_mathematics/cores/adsmob/ads_mob.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/services/coin_service.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/bottomsheets/new_version_bottomsheet.dart';
import 'package:logic_mathematics/features/home/home_new_page.dart';
import 'package:logic_mathematics/features/onborading/onboarding_page.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/main.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _checkVersion = NewVersionPlus();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Shared.instance.setContext(context);

      serviceLocator<InternetConnection>().hasInternetAccess.then((
        value,
      ) async {
        //Check if the device has internet access
        if (value) {
          await CoinService.instance.loadCoinsFromLocal();
          // If there is internet access, check for a new version
          await fetchJson(); // Đảm bảo luôn fetch cấu hình quảng cáo trước khi check version
          checkVersion();
        } else {
          // If there is no internet access, next page
          nextPage();
        }
      });
    });
  }

  Future checkVersion() async {
    try {
      await _checkVersion.getVersionStatus().then((value) {
        if (value != null && value.canUpdate) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => NewVersionBottomsheet(),
          ).then((value) {
            if (value is bool && value) {
              // If the user has accepted the new version, navigate to the next page
              nextPage();
            }
          });
        } else {
          nextPage();
        }
      });
    } catch (e) {
      // Handle any errors that occur during version check
      nextPage();
    }
  }

  Future<void> fetchJson() async {
    //serviceLocator<AdmobController>().createInterstitialAd();
    //await serviceLocator<AdmobController>().loadAd();
    final url =
        'https://raw.githubusercontent.com/truonglam101191-creator/manager_api/main/ads.json';
    final response = await serviceLocator.get<Dio>().get(url);

    if (response.statusCode == HttpStatus.ok) {
      final data = json.decode(response.data);
      Shared.instance.isShowAds = data['isAds'] ?? true;
      serviceLocator<AdmobController>().createInterstitialAd();
    } else {
      print('Lỗi: ${response.statusCode}');
    }
  }

  // Remove these methods as they're now handled by CoinService
  // Future<void> _loadCoinsFromLocal() async { ... }
  // Future<void> _grantFirstTimeBonus() async { ... }
  // Future<String> _getDeviceId() async { ... }

  // void _showWelcomeBonusDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       child: Container(
  //         padding: EdgeInsets.all(24),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(20),
  //           gradient: LinearGradient(
  //             colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.monetization_on, size: 64, color: Color(0xFFFFD700)),
  //             SizedBox(height: 16),
  //             Text(
  //               '🎉 Welcome Bonus!',
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //                 color: AppColors.primaryDark,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 12),
  //             Text(
  //               'Congratulations! You\'ve received 30 FREE coins as a welcome gift!',
  //               style: TextStyle(fontSize: 16, color: Colors.grey[700]),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               'Use these coins to unlock hints and features in the app.',
  //               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 24),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 nextPage();
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: AppColors.primaryDark,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
  //               ),
  //               child: Text(
  //                 'Start Exploring!',
  //                 style: TextStyle(fontWeight: FontWeight.w600),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void nextPage() async {
    final isBorading = await serviceLocator.get<DataBaseFuntion>().onBorading();

    Navigator.pushReplacement(
      context,
      createRouter(isBorading ? HomeNewPage() : OnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image(
            image: AssetsImages.images.imageBgSplash.provider(),
            fit: BoxFit.fill,
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 15,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image(
                    image: AssetsImages.images.imageLogoApp.provider(),
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              Text(
                Shared.instance.packageInfo.appName.split(':').first,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8.h,
          left: 0,
          right: 0,
          child: SpinKitCircle(color: AppColors.accentDark, size: 60),
        ),
      ],
    );
  }
}
