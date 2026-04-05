import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/features/game_core/widgets/animated_background.dart';
import 'package:logic_mathematics/cores/widgets/native_ad_small_dark_widget.dart';
import 'package:logic_mathematics/main.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  int _selectedDifficulty = 0;
  int _selectedCountIndex = 2;
  final List<int> _counts = [5, 10, 20, 30, 40, 50];

  final Color _primaryGreen = AppColors.accentDark;
  final double _cardRadius = 28.0;

  void _onStart() {
    Shared.instance.numberOfQuestions = Shared.instance.numberOfQuestions
        .copyWith(
          numberOfQuestions: _counts[_selectedCountIndex],
          option: Difficulty.values[_selectedDifficulty].name,
        );

    serviceLocator<DataBaseFuntion>().saveNumberOfQuestionsAndDifficulty().then(
      (value) {
        Navigator.pop(context);
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDifficulty = Difficulty.values.indexWhere(
      (element) => element.name == Shared.instance.numberOfQuestions.option,
    );
    _selectedCountIndex = _counts.indexWhere(
      (element) =>
          element == Shared.instance.numberOfQuestions.numberOfQuestions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const AnimatedBackground(
              backgroundColor: Color(0xFFF9FAFB),
              particleColor: Color(0x22000000),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(Shared.instance.context).padding.top,
                ),

                SizedBox(
                  height: kToolbarHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: AnimatedScaleButton(
                          onPressed: () => Navigator.pop(context),
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          context.l10n.challengeTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_cardRadius),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: AssetsImages.images.imageSpecialChallenge
                                  .provider(),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.35),
                                BlendMode.darken,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 20,
                                bottom: 26,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.readyTitle,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 28,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      context.l10n.readySubtitle,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const NativeAdSmallDarkWidget(),
                        const SizedBox(height: 14),
                        // Section title
                        Text(
                          context.l10n.adventurePathTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Difficulty list
                        Column(
                          children: List.generate(3, (i) => i).map((i) {
                            final bool selected = _selectedDifficulty == i;
                            final titles = [
                              context.l10n.difficultyEasy,
                              context.l10n.difficultyMedium,
                              context.l10n.difficultyHard,
                            ];
                            final subtitles = [
                              context.l10n.difficultyEasyDesc,
                              context.l10n.difficultyMediumDesc,
                              context.l10n.difficultyHardDesc,
                            ];
                            final icons = [
                              Icons.explore,
                              Icons.map,
                              Icons.castle,
                            ];

                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDifficulty = i),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _primaryGreen.withOpacity(0.12)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: selected
                                        ? _primaryGreen
                                        : Colors.grey.shade300,
                                    width: 2.4,
                                  ),
                                  boxShadow: [
                                    if (selected)
                                      BoxShadow(
                                        color: _primaryGreen.withOpacity(0.4),
                                        offset: const Offset(0, 6),
                                      )
                                    else
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? _primaryGreen.withOpacity(0.16)
                                            : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        icons[i],
                                        color: selected
                                            ? _primaryGreen
                                            : Colors.orange,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            titles[i],
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitles[i],
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: selected
                                              ? _primaryGreen
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: AnimatedScale(
                                        duration: Durations.medium1,
                                        scale: selected ? 1.0 : 0.0,
                                        child: Icon(
                                          Icons.circle,
                                          color: _primaryGreen,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          context.l10n.chooseQuestionCount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _counts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final selected = _selectedCountIndex == idx;
                              // icons for each count: 5,10,20,30,40,50
                              final icons = [
                                Icons.star,
                                Icons.park,
                                Icons.castle,
                                Icons.terrain,
                                Icons.filter_hdr,
                                Icons.emoji_events,
                              ];

                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCountIndex = idx),
                                child: Container(
                                  width: 84,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: selected
                                          ? _primaryGreen
                                          : Colors.grey.shade300,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      if (selected)
                                        BoxShadow(
                                          color: _primaryGreen.withOpacity(0.4),
                                          offset: const Offset(0, 6),
                                        )
                                      else
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: selected
                                            ? _primaryGreen.withOpacity(0.12)
                                            : Colors.white,
                                        child: Icon(
                                          icons[idx],
                                          color: selected
                                              ? _primaryGreen
                                              : Colors.purple,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_counts[idx]}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Big CTA
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: AnimatedScaleButton(
                    pressedScale: 0.88,
                    duration: const Duration(milliseconds: 140),
                    onPressed: _onStart,
                    child: Container(
                      height: 64,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _primaryGreen,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF04823E),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF04823E),
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 18),
                          Text(
                            context.l10n.startNow,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
