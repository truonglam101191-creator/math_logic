import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/features/subscription/data/datasources/subscription_local_datasource.dart';
import 'package:logic_mathematics/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AdmobAdapterBanner extends StatefulWidget {
  const AdmobAdapterBanner({super.key});

  @override
  _AdmobAdapterBannerState createState() => _AdmobAdapterBannerState();
}

class _AdmobAdapterBannerState extends State<AdmobAdapterBanner> {
  BannerAd? _banner;
  bool _isLoading = false;

  // late final KeyboardVisibilityController _controller;

  double _hieghtKeyShow = 0;

  int count = 0;

  //bool isKeyboardVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _controller = KeyboardVisibilityController();
    // _controller.onChange.listen((bool visible) {
    //   setState(() {
    //     isKeyboardVisible = visible;
    //   });
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdaptiveBanner();
  }

  Future<void> _loadAdaptiveBanner() async {
    if (_isLoading || !mounted) return;
    _isLoading = true;
    if (!mounted) return;

    // Dispose previous ad if any
    _banner?.dispose();

    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          Device.width.toInt(),
        );

    final banner = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-8031150677135815/3231600048'
          : 'ca-app-pub-3940256099942544/2934735716',
      size: adSize ?? AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          count = 0;
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() => _banner = null);
          count++;
          if (count < 3) {
            _loadAdaptiveBanner();
          }
        },
      ),
    );

    _hieghtKeyShow = banner.size.height.toDouble();

    setState(() => _banner = banner);
    banner.load();
    _isLoading = false;
  }

  @override
  void dispose() {
    _banner?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Shared.instance.isShowAds == false || serviceLocator<SubscriptionLocalDataSource>().isActive) {
      return SizedBox();
    }
    return AnimatedContainer(
      height: _banner == null ? 0 : _hieghtKeyShow,
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      alignment: Alignment.center,
      child: _banner == null
          ? const SizedBox.shrink()
          : Stack(
              alignment: Alignment.topLeft,
              children: [
                // Surround ad with subtle box to separate it from app content
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: AdWidget(ad: _banner!),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ad',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
