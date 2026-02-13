// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AdManagerBanner extends StatefulWidget {
//   const AdManagerBanner({super.key, this.height = 100, this.adCallback});

//   final int height;

//   final Function(bool isSucess)? adCallback;

//   @override
//   State<AdManagerBanner> createState() => _AdManagerBannerState();
// }

// class _AdManagerBannerState extends State<AdManagerBanner> {
//   int height = 0;
//   @override
//   void initState() {
//     super.initState();
//     height = widget.height;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       color: Colors.transparent,
//       alignment: Alignment.center,
//       height: height.toDouble(),
//       width: double.infinity,
//       duration: const Duration(milliseconds: 200),
//       child: Stack(
//         alignment: Alignment.topLeft,
//         children: [
//           AdWidget(
//             ad: AdManagerBannerAd(
//               adUnitId: Platform.isAndroid
//                   ? 'ca-app-pub-8031150677135815/3231600048'
//                   : 'ca-app-pub-3940256099942544/2934735716',
//               sizes: [
//                 AdSize.getInlineAdaptiveBannerAdSize(
//                   (MediaQuery.of(context).size.width - (2 * 16).truncate()).toInt(),
//                   height,
//                 ),
//               ],
//               request: const AdManagerAdRequest(),
//               listener: AdManagerBannerAdListener(
//                 onAdLoaded: (ad) {
//                   print(ad);
//                   widget.adCallback?.call(false);
//                 },
//                 onAdFailedToLoad: (Ad ad, LoadAdError error) {
//                   print('Inline adaptive banner failedToLoad: $error');
//                   ad.dispose();
//                   widget.adCallback?.call(true);
//                   setState(() {
//                     height = 0;
//                   });
//                 },
//               ),
//             )..load(),
//           // Small 'Ad' label to clearly indicate advertising content
//           Positioned(
//             left: 8,
//             top: 8,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 'Ad',
//                 style: TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // double _getSmartBannerHeight(BuildContext context) {
//   //   MediaQueryData mediaScreen = MediaQuery.of(context);
//   //   double dpHeight = mediaScreen.orientation == Orientation.portrait
//   //       ? mediaScreen.size.height
//   //       : mediaScreen.size.width;
//   //   if (dpHeight <= 400.0) {
//   //     return 42.0;
//   //   }
//   //   if (dpHeight > 720.0) {
//   //     return 100.0;
//   //   }
//   //   return 60.0;
//   // }
// }
