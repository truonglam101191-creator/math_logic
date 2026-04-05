import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';

const int maxFailedLoadAttempts = 3;

class AdmobController {
  RewardedInterstitialAd? _rewardedInterstitialAd;

  InterstitialAd? _interstitialAd;

  AppOpenAd? _appOpenAd;

  bool _isShowingAd = false;
  DateTime? _lastAdShowTime;

  AdmobController() {
    createRewardedInterstitialAd();
  }

  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  int _numRewardedInterstitialLoadAttempts = 0;

  void createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-8031150677135815/4213509223'
          : 'ca-app-pub-3940256099942544/6978759866',
      request: request,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          _rewardedInterstitialAd = ad;
          _numRewardedInterstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedInterstitialAd = null;
          _numRewardedInterstitialLoadAttempts += 1;
          if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
            createRewardedInterstitialAd();
          }
        },
      ),
    );
  }

  void showRewardedInterstitialAd({Function()? callback}) {
    if (_rewardedInterstitialAd == null) {
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
              debugPrint('$ad onAdShowedFullScreenContent.'),
          onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
            ad.dispose();
            createRewardedInterstitialAd();
            callback?.call();
          },
          onAdFailedToShowFullScreenContent:
              (RewardedInterstitialAd ad, AdError error) {
                ad.dispose();
                createRewardedInterstitialAd();
              },
        );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      },
    );
    _rewardedInterstitialAd = null;
  }

  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Shared.instance.adUnitIdInterstitial,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numRewardedInterstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedInterstitialAd = null;
          _numRewardedInterstitialLoadAttempts += 1;
          if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd({Function(bool isSucess)? callback}) {
    //if (_numRewardedInterstitialLoadAttempts >= maxFailedLoadAttempts) {
    if (Shared.instance.isShowAds) {
      if (_lastAdShowTime != null &&
          DateTime.now().difference(_lastAdShowTime!).inSeconds < 60) {
        print('Skipping Interstitial due to 60s cooldown.');
        callback?.call(true);
        return;
      }

      if (_interstitialAd == null) {
        print('Warning: attempt to show interstitial before loaded.');
        callback?.call(false);
        return;
      }
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdShowedFullScreenContent.');
          _lastAdShowTime = DateTime.now();
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          createInterstitialAd();
          callback?.call(true);
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          createInterstitialAd();
        },
      );

      _interstitialAd!.setImmersiveMode(true);
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Ads are not enabled.');
      callback?.call(false);
    }
  }

  Future<void> loadAd({Function(bool isSucess)? onLoad}) => AppOpenAd.load(
    adUnitId: Shared.instance.adOpenAppUnitId,
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        _appOpenAd = ad;
        print('✅ AppOpenAd loaded');
        onLoad?.call(true);
        if (!_isShowingAd) {
          Future.delayed(const Duration(seconds: 5), () {
            showAdIfAvailable();
          });
          // _isShowingAd = true;
        }
      },
      onAdFailedToLoad: (error) {
        print('❌ Failed to load AppOpenAd: $error');
        _appOpenAd = null;
        onLoad?.call(false);
      },
    ),
  );

  void showAdIfAvailable({Function()? callback}) async {
    if (!Shared.instance.isShowAds) {
      callback?.call();
      return;
    }

    if (_lastAdShowTime != null &&
        DateTime.now().difference(_lastAdShowTime!).inSeconds < 60) {
      callback?.call();
      return;
    }

    if (_isShowingAd) {
      callback?.call();
      return;
    }

    if (_appOpenAd == null) {
      await loadAd();
      callback?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        _lastAdShowTime = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = true;
        ad.dispose();
        loadAd();
        callback?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        loadAd();
        callback?.call();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
  }
}
