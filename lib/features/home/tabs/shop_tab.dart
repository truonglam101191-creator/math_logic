import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/extentions/in_app_purchase.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/user_coin_widget.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/main.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/features/game_core/widgets/animated_background.dart';
import 'package:logic_mathematics/cores/widgets/ad_native_widget.dart';

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  static const _heroImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDv0relLJq0v8ZFlQZ4CpjBt6aVOOVYzuh8rhOvdKR0TTnxutPJVLIc-0GJ2sMOpi7uZqBtETD9R5EdEUXNhpH87hBi3jlRuGg-O_eElBo0fGMULt6ZypFDM3FD0H01NU26TZCChpvf-FTfdR75WutgB0sdsi7LvemhbcUY8oyW_fzk32AFAyVz0wrpxTIxCP4pz-xQjWpe9moTGBpV1LiC0M2wnjvzR0PfwjZFapv1XtZYE3dnxprRUdXJ97J1QVn6Q5rv-dg7qg';

  @override
  Widget build(BuildContext context) {
    LocalInAppPurchase.listProduct.sort((a, b) => a.coin.compareTo(b.coin));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedBackground(
            backgroundColor: Color(0xFFFFF8E1),
            particleColor: Color(0x66FFC107),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                _ShopHeader(),

                // Content
                Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Hero banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _HeroBanner(imageUrl: _heroImage),
                  ),

                  const SizedBox(height: 18),

                  // Section title
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          AppLocalizations.of(context).buyCoins,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Opacity(
                          opacity: 0.75,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline, size: 16),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).askParentsBeforePurchase,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 240,
                    ),
                    itemCount: LocalInAppPurchase.listProduct.length,
                    itemBuilder: (_, index) => _StickerCard(
                      title: LocalInAppPurchase.listProduct[index].title
                          .split('(')
                          .first,
                      emoji: '✨',
                      amount:
                          '+${LocalInAppPurchase.listProduct[index].title.split(' ').first}',
                      price: LocalInAppPurchase.listProduct[index].price,
                      background: Color(0xFFFFECB3),
                      textColor: Colors.black,
                      onPressed: () {
                        serviceLocator.get<LocalInAppPurchase>().buy(
                          LocalInAppPurchase.listProduct[index],
                        );
                      },
                    ),
                  ),

                  // Grid of packages (2x2)
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //   child: GridView.builder(
                  //     physics: const NeverScrollableScrollPhysics(),

                  //     shrinkWrap: true,

                  //     children: const [
                  //       _StickerCard(
                  //         title: 'Gói Khởi động',
                  //         emoji: '🌟',
                  //         amount: '+100',
                  //         price: '10.000đ',
                  //         background: Color(0xFFC0E8FF),
                  //         textColor: Color(0xFF0B4A6F),
                  //       ),
                  //       _StickerCard(
                  //         title: 'Gói Cơ bản',
                  //         emoji: '✨',
                  //         amount: '+500',
                  //         price: '20.000đ',
                  //         background: Color(0xFFFFECB3),
                  //         textColor: Color(0xFF5A3F00),
                  //       ),
                  //       _StickerCard(
                  //         title: 'Gói Khổng lồ',
                  //         emoji: '💎',
                  //         amount: '+5000',
                  //         price: '400.000đ',
                  //         background: Color(0xFFE1B0FF),
                  //         textColor: Color(0xFF4A1E6A),
                  //       ),
                  //       _StickerCard(
                  //         title: 'Gói Đặc biệt',
                  //         emoji: '🚀',
                  //         amount: '+2000',
                  //         price: '150.000đ',
                  //         background: Color(0xFFFFC0CB),
                  //         textColor: Color(0xFF6E1432),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  const AdNativeWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context).coinShop,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(child: UserCoinWidget()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({Key? key, required this.imageUrl}) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFB300), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA000),
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, s, e) => Container(color: Colors.green),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).rechargeCoins,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).buyCoinsDescription,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _StickerCard extends StatelessWidget {
  const _StickerCard({
    Key? key,
    required this.title,
    required this.emoji,
    required this.amount,
    required this.price,
    required this.background,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final String emoji;
  final String amount;
  final String price;
  final Color background;
  final Color textColor;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: background.withOpacity(0.8),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: _darken(background, 0.1),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(
                  //   title,
                  //   style: TextStyle(
                  //     color: textColor,
                  //     fontWeight: FontWeight.w800,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  Text(emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 8),
                  Text(
                    amount,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).starsUnit,
                    style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AnimatedScaleButton(
              onPressed: onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accentDark,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentDark.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _darken(Color c, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
