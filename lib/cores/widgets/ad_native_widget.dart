import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logic_mathematics/cores/adsmob/consent_manager.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AdNativeWidget extends StatefulWidget {
  const AdNativeWidget({super.key});

  @override
  State<AdNativeWidget> createState() => _AdNativeWidgetState();
}

class _AdNativeWidgetState extends State<AdNativeWidget> {
  final _consentManager = ConsentManager();

  // final double _adAspectRatioSmall = (91 / 355);
  //final double _adAspectRatioMedium = (370 / 355);
  final _adAspectRatioMedium = (370 / 355);

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  bool _isPrivacyOptionsRequired = false; // NEW: dynamic privacy flag

  @override
  void initState() {
    super.initState();
    if (Shared.instance.isShowAds) {
      _loadAd();
      _getIsPrivacyOptionsRequired(); // check after init
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return Shared.instance.isShowAds
        ? Stack(
            alignment: Alignment.bottomRight,
            children: [
              _nativeAdIsLoaded && _nativeAd != null
                  ? SizedBox(
                      height: (Device.width * _adAspectRatioMedium) - 40,
                      width: Device.width,
                      child: AdWidget(ad: _nativeAd!),
                    )
                  : const SizedBox(),
              if (_isPrivacyOptionsRequired)
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    color: Colors.black.withOpacity(0.3),
                    minSize: 0,
                    onPressed: () async {
                      _consentManager.showPrivacyOptionsForm((_) {});
                      if (!mounted) return;
                      _getIsPrivacyOptionsRequired();
                    },
                    child: Text(
                      context.l10n.privacyPolicy,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ),
                ),
            ],
          )
        : SizedBox();
  }

  void _getIsPrivacyOptionsRequired() async {
    final required = await _consentManager.isPrivacyOptionsRequired();
    if (!mounted) return;
    setState(() {
      _isPrivacyOptionsRequired = required;
    });
  }

  /// Loads a native ad.
  void _loadAd() async {
    final canRequestAds = await _consentManager.canRequestAds();
    if (!canRequestAds) {
      // Try to collect consent and retry
      _consentManager.gatherConsent((_) {
        debugPrint('Retrying to load native ad after consent gathering.');
        _loadAd();
      });
    }

    if (!await _consentManager.canRequestAds()) {
      if (!mounted) return;
      setState(() {
        _nativeAdIsLoaded = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _nativeAdIsLoaded = false;
    });

    final theme = Theme.of(context);

    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-8031150677135815/1431918935',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          // ignore: avoid_print
          print('$NativeAd loaded.');
          if (!mounted) return;
          setState(() {
            _nativeAdIsLoaded = true;
          });
          _getIsPrivacyOptionsRequired();
        },
        onAdFailedToLoad: (ad, error) {
          // ignore: avoid_print
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdClicked: (ad) {},
        onAdImpression: (ad) {},
        onAdClosed: (ad) {},
        onAdOpened: (ad) {},
        onAdWillDismissScreen: (ad) {},
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: theme.cardTheme.color,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: theme.iconTheme.color!,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: theme.textTheme.titleSmall!.color!,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: theme.textTheme.titleSmall!.color!,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: theme.textTheme.titleSmall!.color!,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    )..load();
  }
}
