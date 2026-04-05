import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/adsmob/ads_mob.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/enum/enum_topic_math.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/user_coin_widget.dart';
import 'package:logic_mathematics/features/bottomsheets/roll_up_bottomsheet.dart';
import 'package:logic_mathematics/features/chat_ai/history_chatai_page.dart';
import 'package:logic_mathematics/features/home/pages/topic_list_page.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/features/mini_game/pages/list_game_page.dart';
import 'package:logic_mathematics/features/game_core/widgets/particle_reward_effect.dart';
import 'package:logic_mathematics/features/game_core/widgets/animated_background.dart';
import 'package:logic_mathematics/features/special_challenge/challenge_page.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/cores/widgets/ad_native_widget.dart';
import 'package:logic_mathematics/main.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedBackground(
            backgroundColor: Color(0xFFF9FAFB),
            particleColor: Color(0x22000000),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.hello},',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.accentDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.baby,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    UserCoinWidget(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedScaleButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => ChallengePage(),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.shade400,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade400,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            spacing: 5,
                            children: [
                              Icon(
                                Icons.offline_bolt,
                                color: Colors.blue.shade600,
                              ),
                              Expanded(child: Text(l10n.specialChallenge)),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.blue.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Daily gift card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFF7FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBBE5EC),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFBBE5EC),
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.checkIn,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.home_daily_reward_subtitle.replaceAll(
                                      '10',
                                      '5',
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedScaleButton(
                                    pressedScale: .95,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => RollUpBottomsheet(),
                                      ).then((value) {
                                        if (value == true) {
                                          serviceLocator
                                              .get<AdmobController>()
                                              .showInterstitialAd(
                                                callback: (isSucess) async {
                                                  final coin =
                                                      await serviceLocator
                                                          .get<
                                                            DataBaseFuntion
                                                          >()
                                                          .getStar();
                                                  final newCoin = coin + 5;
                                                  serviceLocator
                                                      .get<DataBaseFuntion>()
                                                      .saveStar(newCoin)
                                                      .then((value) {
                                                        ParticleRewardEffect.showReward(
                                                          context,
                                                        );
                                                        serviceLocator
                                                            .get<
                                                              DataBaseFuntion
                                                            >()
                                                            .saveCheckInToday()
                                                            .then((value) {
                                                              serviceLocator<
                                                                    MessagingService
                                                                  >()
                                                                  .send(
                                                                    channel:
                                                                        MessageChannel
                                                                            .startUserChanged,
                                                                    parameter:
                                                                        '',
                                                                  );
                                                            });
                                                      });
                                                },
                                              );
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.blue.shade100,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.shade200,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        l10n.start,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 86,
                                height: 86,
                                color: Colors.pink[100],
                                child: const Icon(
                                  Icons.card_giftcard,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Large featured card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EA),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: const Color(0xFFFFE0B2),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFFFE0B2),
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -10,
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.orange[400],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.orange[600]!,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange[600]!,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.calculate,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.basicMath,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.home_featured_basic_subtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.brown[600],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                // Big CTA
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: AnimatedScaleButton(
                                    pressedScale: .95,
                                    onPressed: () {
                                      if (Platform.isAndroid) {
                                        FirebaseAnalytics.instance.logEvent(
                                          name: 'open_basic_math_home',
                                        );
                                      }
                                      Navigator.push(
                                        context,
                                        createRouter(TopicListPage()),
                                      );
                                    },
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1FF83A),
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                          color: const Color(0xFF13AF25),
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0xFF13AF25),
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        child: Center(
                                          child: Text(
                                            l10n.startNow,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Grid of smaller cards (2 columns)
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 195,
                            ),
                        children: [
                          _SmallCard(
                            title: l10n.home_card_reflex_title,
                            subtitle: l10n.home_card_reflex_subtitle,
                            icon: Icons.bolt,
                            bg: const Color(0xFFE6E8FF),
                            btnColor: const Color(0xFF6963F0),
                            onPressed: () {
                              if (Platform.isAndroid) {
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'open_reflex_home',
                                );
                              }
                              Navigator.push(
                                context,
                                createRouter(
                                  TopicListPage(
                                    enumTopicMath: EnumTopicMath.reflex,
                                  ),
                                ),
                              );
                            },
                          ),
                          _SmallCard(
                            title: l10n.home_card_think_title,
                            subtitle: l10n.home_card_think_subtitle,
                            icon: Icons.psychology,
                            bg: const Color(0xFFF2E6FF),
                            btnColor: const Color(0xFF9B59FF),
                            onPressed: () {
                              if (Platform.isAndroid) {
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'open_thinking_home',
                                );
                              }
                              Navigator.push(
                                context,
                                createRouter(
                                  TopicListPage(
                                    enumTopicMath: EnumTopicMath.think,
                                  ),
                                ),
                              );
                            },
                          ),
                          _SmallCard(
                            title: l10n.home_card_ai_title,
                            subtitle: l10n.home_card_ai_subtitle,
                            textButton: l10n.home_card_ai_button,
                            icon: Icons.smart_toy,
                            bg: const Color(0xFFE6FFF5),
                            iconButon: Icons.message,
                            btnColor: const Color(0xFF00BFA5),
                            onPressed: () {
                              if (Platform.isAndroid) {
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'open_chat_ai_home',
                                );
                              }
                              Navigator.push(
                                context,
                                createRouter(HistoryChataiPage()),
                              );
                            },
                          ),
                          _SmallCard(
                            title: l10n.home_card_game_title,
                            subtitle: l10n.home_card_game_subtitle,
                            icon: Icons.videogame_asset,
                            bg: const Color(0xFFFDE6F0),
                            btnColor: const Color(0xFFFF5C8A),
                            onPressed: () {
                              if (Platform.isAndroid) {
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'open_mini_game',
                                );
                              }

                              Navigator.push(
                                context,
                                createRouter(ListGamePage()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const AdNativeWidget(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bg,
    required this.btnColor,
    this.textButton = '',
    this.iconButon,
    this.onPressed,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color btnColor;
  final String textButton;
  final IconData? iconButon;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 20 - 12) / 2 - 6;
    final l10n = context.l10n;
    return AnimatedScaleButton(
      pressedScale: .9,
      onPressed: onPressed,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: btnColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: btnColor.withOpacity(0.3),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: btnColor.withOpacity(0.6),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: btnColor.withOpacity(0.6),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconButon ?? Icons.play_circle_sharp,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        textButton.isNotEmpty
                            ? textButton
                            : l10n.small_card_play,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
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
    );
  }
}
