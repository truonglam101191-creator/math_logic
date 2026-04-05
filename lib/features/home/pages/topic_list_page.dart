import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/datas/topic_data.dart';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/enum/enum_topic_math.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/widgets/user_coin_widget.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/features/home/widgets/topic_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logic_mathematics/features/practice/practice_screen.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/cores/widgets/native_ad_small_dark_widget.dart';

class TopicListPage extends StatelessWidget {
  const TopicListPage({super.key, this.enumTopicMath = EnumTopicMath.basic});

  final EnumTopicMath enumTopicMath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left: circular white back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Theme.of(context).cardColor,
                    shape: const CircleBorder(),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: AnimatedScaleButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.arrow_back, color: Colors.black87),
                      ),
                    ),
                  ),
                ),

                // Center title
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    // localized page title
                    getPageTitle(enumTopicMath, context.l10n),
                    style: GoogleFonts.notoSans(
                      textStyle: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                ),

                // Right: star chip
                Align(
                  alignment: Alignment.centerRight,
                  child: UserCoinWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            final topics = getTopicsByEnumTopicMath(
              enumTopicMath,
              context.l10n,
            );

            return ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              itemCount: topics.length,
              separatorBuilder: (context, index) {
                if ((index + 1) % 3 == 0) {
                  return const Column(
                    children: [
                      SizedBox(height: 6),
                      NativeAdSmallDarkWidget(),
                      SizedBox(height: 6),
                    ],
                  );
                }
                return const SizedBox(height: 6);
              },
              itemBuilder: (context, index) {
                final t = topics[index];
                return TopicCard(
                  icon: t['icon'] as IconData,
                  iconBackground: t['iconColor'] as Color,
                  backgroundColor: t['backgroundColor'] as Color?,
                  iconForeground: t['iconForeground'] as Color?,
                  title: t['title'] as String,
                  subtitle: t['subtitle'] as String,
                  onPressed: () {
                    final topic = TopicData.allTopics.firstWhere(
                      (element) => element.key == t['key'] as TopicKey,
                    );
                    Navigator.push(
                      context,
                      createRouter(
                        PracticeScreen(
                          topic: topic.title,
                          questions: topic.generateQuestions(
                            Difficulty.values
                                .where(
                                  (element) =>
                                      element.name ==
                                      Shared.instance.numberOfQuestions.option,
                                )
                                .first,
                            Shared.instance.numberOfQuestions.numberOfQuestions,
                          ),
                          onEarnCoins: (int) {},
                          topicKey: topic.key,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getTopicsByEnumTopicMath(
    EnumTopicMath enumTopicMath,
    AppLocalizations l10n,
  ) {
    switch (enumTopicMath) {
      case EnumTopicMath.basic:
        return [
          {
            'key': TopicKey.addition,
            'icon': Icons.add_circle,
            'iconColor': const Color(0xFFFFF7ED),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFF97316),
            'title': l10n.topic_addition_title,
            'subtitle': l10n.topic_addition_subtitle,
          },
          {
            'key': TopicKey.subtraction,
            'icon': Icons.do_not_disturb_on,
            'iconColor': const Color(0xFFFEE2E2),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFEF4444),
            'title': l10n.topic_subtraction_title,
            'subtitle': l10n.topic_subtraction_subtitle,
          },
          {
            'key': TopicKey.basicMath,
            'icon': Icons.calculate,
            'iconColor': const Color(0xFFFFFBEB),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFD97706),
            'title': l10n.topic_mixed_title,
            'subtitle': l10n.topic_mixed_subtitle,
          },
          {
            'key': TopicKey.advancedArithmetic,
            'icon': Icons.close,
            'iconColor': const Color(0xFFF3E8FF),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFA78BFA),
            'title': l10n.topic_mul_div_title,
            'subtitle': l10n.topic_mul_div_subtitle,
          },
          {
            'key': TopicKey.divisionMath,
            'icon': Icons.percent,
            'iconColor': const Color(0xFFFCE7F3),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFEC4899),
            'title': l10n.topic_division_title,
            'subtitle': l10n.topic_division_subtitle,
          },
          {
            'key': TopicKey.comprehensiveArithmetic,
            'icon': Icons.functions,
            'iconColor': const Color(0xFFDBEAFE),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF3B82F6),
            'title': l10n.topic_review_title,
            'subtitle': l10n.topic_review_subtitle,
          },
          {
            'key': TopicKey.probabilityMath,
            'icon': Icons.pie_chart,
            'iconColor': const Color(0xFFECFEFF),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF0891B2),
            'title': l10n.topic_fraction_title,
            'subtitle': l10n.topic_fraction_subtitle,
          },
          {
            'key': TopicKey.oddEvenNumberMath,
            'icon': Icons.contrast,
            'iconColor': const Color(0xFFEEF2FF),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF6366F1),
            'title': l10n.topic_even_odd_title,
            'subtitle': l10n.topic_even_odd_subtitle,
          },
          {
            'key': TopicKey.primeNumberMath,
            'icon': Icons.diamond,
            'iconColor': const Color(0xFFCCFBF1),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF14B8A6),
            'title': l10n.topic_prime_title,
            'subtitle': l10n.topic_prime_subtitle,
          },
          {
            'key': TopicKey.powerAndRootMath,
            'icon': Icons.publish,
            'iconColor': const Color(0xFFF7FEE7),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF84CC16),
            'title': l10n.topic_power_root_title,
            'subtitle': l10n.topic_power_root_subtitle,
          },
          {
            'key': TopicKey.moduloMath,
            'icon': Icons.sync_alt,
            'iconColor': const Color(0xFFF1F5F9),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF64748B),
            'title': l10n.topic_modulo_title,
            'subtitle': l10n.topic_modulo_subtitle,
          },
        ];
      case EnumTopicMath.reflex:
        return [
          {
            'key': TopicKey.visualLogicMath,
            'icon': Icons.functions,
            'iconColor': const Color(0xFFDBEAFE),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF3B82F6),
            'title': l10n.visualLogicMath,
            'subtitle': l10n.topic_algebra_subtitle,
          },
          {
            'key': TopicKey.visualLogicMath2,
            'icon': Icons.change_history,
            'iconColor': const Color(0xFFD1FAE5),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF10B981),
            'title': l10n.visualLogicMath,
            'subtitle': l10n.topic_geometry_subtitle,
          },
          {
            'key': TopicKey.timeMath,
            'icon': Icons.timeline,
            'iconColor': const Color(0xFFFFF7ED),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFF97316),
            'title': l10n.timeMath,
            'subtitle': l10n.topic_calculus_subtitle,
          },
          {
            'key': TopicKey.sequenceMath,
            'icon': Icons.pie_chart,
            'iconColor': const Color(0xFFECFEFF),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF0891B2),
            'title': l10n.sequenceMath,
            'subtitle': l10n.topic_advanced_probability_subtitle,
          },
        ];
      case EnumTopicMath.think:
        return [
          {
            'key': TopicKey.mathlogic,
            'icon': Icons.lightbulb,
            'iconColor': const Color(0xFFFFF7ED),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFF97316),
            'title': l10n.mathlogic,
            'subtitle': l10n.mathlogic_subtitle,
          },
          {
            'key': TopicKey.deductiveLogicMath,
            'icon': Icons.gavel,
            'iconColor': const Color(0xFFFEE2E2),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFEF4444),
            'title': l10n.deductiveLogicMath,
            'subtitle': l10n.topic_deductive_subtitle,
          },
          {
            'key': TopicKey.visualLogicMath,
            'icon': Icons.functions,
            'iconColor': const Color(0xFFDBEAFE),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF3B82F6),
            'title': l10n.visualLogicMath,
            'subtitle': l10n.topic_algebra_subtitle,
          },
          {
            'key': TopicKey.visualLogicMath2,
            'icon': Icons.change_history,
            'iconColor': const Color(0xFFD1FAE5),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF10B981),
            'title': l10n.visualLogicMath2,
            'subtitle': l10n.topic_geometry_subtitle,
          },
          {
            'key': TopicKey.specialChallenge,
            'icon': Icons.star,
            'iconColor': const Color(0xFFFFF7E0),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFFFC700),
            'title': l10n.specialChallenge,
            'subtitle': l10n.topic_special_challenge_subtitle,
          },
          {
            'key': TopicKey.basicMath,
            'icon': Icons.calculate,
            'iconColor': const Color(0xFFFFFBEB),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFFD97706),
            'title': l10n.topic_mixed_title,
            'subtitle': l10n.topic_mixed_subtitle,
          },
          {
            'key': TopicKey.sequenceMath,
            'icon': Icons.timeline,
            'iconColor': const Color(0xFFECFEFF),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF0891B2),
            'title': l10n.sequenceMath,
            'subtitle': l10n.topic_advanced_probability_subtitle,
          },
          {
            'key': TopicKey.probabilityMath,
            'icon': Icons.pie_chart,
            'iconColor': const Color(0xFFCCFBF1),
            'backgroundColor': const Color(0xFFFFFFFF),
            'iconForeground': const Color(0xFF14B8A6),
            'title': l10n.probabilityMath,
            'subtitle': l10n.topic_fraction_subtitle,
          },
        ];
    }
  }

  String getPageTitle(EnumTopicMath enumTopicMath, AppLocalizations l10n) {
    switch (enumTopicMath) {
      case EnumTopicMath.basic:
        return l10n.topic_list_title;
      case EnumTopicMath.reflex:
        return l10n.reflex;
      case EnumTopicMath.think:
        return l10n.thinking;
    }
  }
}
