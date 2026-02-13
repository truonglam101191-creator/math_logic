import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/extentions/in_app_purchase.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';

class OptionSuggestPopup extends StatelessWidget {
  const OptionSuggestPopup({
    super.key,
    required this.onUseCoin,
    required this.onWatchVideo,
    this.coinCost = 2,
  });

  final VoidCallback onUseCoin;
  final VoidCallback onWatchVideo;
  final int coinCost;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onUseCoin,
    required VoidCallback onWatchVideo,
    int coinCost = 1,
  }) async {
    showDialog(
      context: context,
      builder: (_) => OptionSuggestPopup(
        onUseCoin: onUseCoin,
        onWatchVideo: onWatchVideo,
        coinCost: coinCost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Green header background
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE8F5E9),
                          const Color(0xFFC8E6C9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                  ),

                  // Light bulb icon
                  Positioned(
                    top: 20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('💡', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: AnimatedScaleButton(
                      pressedScale: .9,
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.close, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  context.l10n.hint,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  context.l10n.hintDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Option 1: Use Coin
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _OptionCard(
                  icon: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4).withValues(alpha: .5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  title: context.l10n.useCoins,
                  subtitle: context.l10n.useCoinDescription(
                    coinCost.toString(),
                  ),
                  buttonText: '$coinCost ${context.l10n.coinUnit}',
                  buttonColor: const Color(0xFF4AE54A),
                  onPressed: () {
                    Navigator.pop(context);
                    onUseCoin();
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Divider with "HOẶC"
              _OrDivider(text: context.l10n.or),

              const SizedBox(height: 16),

              // Option 2: Watch Video
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _OptionCard(
                  icon: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE3F2FD),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF2196F3),
                        size: 28,
                      ),
                    ),
                  ),
                  title: context.l10n.watchAd,
                  subtitle: context.l10n.watchAdDescription,
                  buttonText: context.l10n.free,
                  buttonColor: const Color(0xFF4AE54A),
                  buttonIcon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                    onWatchVideo();
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Divider with "HOẶC"
              _OrDivider(text: context.l10n.or),

              const SizedBox(height: 16),

              // Add more coins section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  context.l10n.addCoinsToTreasury,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Coin packages
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: _CoinPackageCard(
                        amount: 10,
                        price: LocalInAppPurchase.listProduct.first.price,
                        onPressed: () {
                          if (LocalInAppPurchase.listProduct.isNotEmpty) {
                            serviceLocator.get<LocalInAppPurchase>().buy(
                              LocalInAppPurchase.listProduct.first,
                            );
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: _CoinPackageCard(
                        amount: 20,
                        isHot: true,
                        onPressed: () {
                          if (LocalInAppPurchase.listProduct.length > 1) {
                            serviceLocator.get<LocalInAppPurchase>().buy(
                              LocalInAppPurchase.listProduct[1],
                            );
                          }
                        },
                        price: LocalInAppPurchase.listProduct[1].price,
                      ),
                    ),
                    Expanded(
                      child: _CoinPackageCard(
                        amount: 30,
                        onPressed: () {
                          if (LocalInAppPurchase.listProduct.length > 2) {
                            serviceLocator.get<LocalInAppPurchase>().buy(
                              LocalInAppPurchase.listProduct[2],
                            );
                          }
                        },
                        price: LocalInAppPurchase.listProduct[2].price,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
    this.buttonIcon,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;
  final IconData? buttonIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   title,
                //   style: const TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w700,
                //     color: Color(0xFF1A1A1A),
                //   ),
                // ),
                // const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedScaleButton(
                    onPressed: onPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (buttonIcon != null) ...[
                            Icon(buttonIcon, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    );
  }
}

class _CoinPackageCard extends StatelessWidget {
  const _CoinPackageCard({
    required this.amount,
    required this.onPressed,
    this.isHot = false,
    required this.price,
  });

  final int amount;
  final bool isHot;
  final String price;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedScaleButton(
      onPressed: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHot
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFFFFE082),
                width: isHot ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFE082).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star icon with amount badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 36)),
                    Positioned(
                      right: -8,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4AE54A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'x$amount',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Amount text
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 10),

                // Get button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4AE54A),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4AE54A).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        l10n.get,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // HOT badge
          if (isHot)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'HOT!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
