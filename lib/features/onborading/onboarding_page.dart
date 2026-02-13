import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/features/home/home_new_page.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final kPrimary = theme.primaryColor;
    final textColor = Colors.black;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AssetsImages.images.onboardBackground.image(
              fit: BoxFit.cover,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _HeaderBadge(primary: kPrimary, textColor: textColor),
                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hero image
                        _HeroCard(),
                        const SizedBox(height: 20),

                        // Title
                        const _TitleWithWave(),
                        const SizedBox(height: 10),

                        // Description
                        Text(
                          context.l10n.newUpdateDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Feature icons row
                        _FeatureRow(textColor: textColor),
                      ],
                    ),
                  ),
                ),
                _BottomCTA(
                  primary: kPrimary,
                  controller: _waveController,
                  onTap: () {
                    serviceLocator.get<DataBaseFuntion>().setOnBorading(true);
                    Navigator.pushReplacement(
                      context,
                      createRouter(HomeNewPage()),
                    );
                  },
                  textColor: textColor,
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.primary, required this.textColor});

  final Color primary;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: bg.withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.basicMath.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontSize: 14,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 6),
        borderRadius: BorderRadius.circular(40),
        image: DecorationImage(
          image: AssetsImages.images.imageOnboading.provider(),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
    );
  }
}

class _TitleWithWave extends StatelessWidget {
  const _TitleWithWave();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.newUpdate;
    // Try splitting title into two parts around an em-dash / en-dash separator
    final parts = title.split(' – ');
    final primary = Theme.of(context).primaryColor;
    final baseStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: Colors.black,
      height: 1.15,
    );

    if (parts.length > 1) {
      return Column(
        children: [
          Text(
            parts[0],
            textAlign: TextAlign.center,
            style: baseStyle?.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 6),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: -6,
                left: 0,
                right: 0,
                child: FractionallySizedBox(
                  widthFactor: 1.05,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                parts[1],
                textAlign: TextAlign.center,
                style: baseStyle?.copyWith(fontSize: 36, color: primary),
              ),
            ],
          ),
        ],
      );
    }

    return Text(
      title,
      textAlign: TextAlign.center,
      style: baseStyle?.copyWith(fontSize: 34),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.textColor});
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, Color bg, Color fg) {
      return Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: fg),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.8 : 1,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        item(
          Icons.psychology,
          context.l10n.think,
          const Color(0xFFFFEAD6),
          const Color(0xFFEA580C),
        ),
        _divider(),
        item(
          Icons.timer,
          context.l10n.reflex,
          const Color(0xFFDBEAFE),
          const Color(0xFF2563EB),
        ),
        _divider(),
        item(
          Icons.sports_esports,
          context.l10n.game,
          const Color(0xFFEDE9FE),
          const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    height: 32,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.grey.withOpacity(0.25),
  );
}

class _BottomCTA extends StatelessWidget {
  const _BottomCTA({
    required this.primary,
    required this.controller,
    required this.onTap,
    required this.textColor,
  });

  final Color primary;
  final AnimationController controller;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _AnimatedCTAButton(
          controller: controller,
          primary: primary,
          textColor: textColor,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _AnimatedCTAButton extends StatelessWidget {
  const _AnimatedCTAButton({
    required this.controller,
    required this.primary,
    required this.textColor,
    required this.onTap,
  });

  final AnimationController controller;
  final Color primary;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          height: 64,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated top-half sheen
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final t = CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeOut,
                  ).value;
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: (1 - t) * 32,
                    child: Opacity(
                      opacity: (0.2 + 0.6 * t),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.startNow,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: textColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// (Removed unused Wave underline painter - replaced with filled highlight)

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
        ),
      ),
    );
  }
}

// no color extensions required for this screen
