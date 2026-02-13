import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/models/math_question_model.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/ad_native_widget.dart';
import 'package:logic_mathematics/cores/widgets/gradient_button_widget.dart';
import 'package:logic_mathematics/features/analytics/stats_service.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/features/viewdetail/viewdetail_page.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ResultQuestionBottomsheet extends StatefulWidget {
  const ResultQuestionBottomsheet({
    super.key,
    required this.questions,
    required this.topicName,
  });

  final List<MathQuestion> questions;

  final String topicName;

  @override
  State<ResultQuestionBottomsheet> createState() =>
      _ResultQuestionBottomsheetState();
}

class _ResultQuestionBottomsheetState extends State<ResultQuestionBottomsheet> {
  double percentQuestionCorrect = 0;

  final colorCorrect = const Color(0xFF009F68);
  final colorIncorrect = const Color(0xFFFF0000);
  final controller = ConfettiController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    percentQuestionCorrect = culPercentQuestionCorrect();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (percentQuestionCorrect > 50) {
        int total = 30;
        int progress = 0;

        Timer.periodic(const Duration(milliseconds: 300), (timer) {
          progress++;

          if (progress >= total) {
            timer.cancel();
            return;
          }
          double randomInRange(double min, double max) {
            return min + Random().nextDouble() * (max - min);
          }

          Confetti.launch(
            context,
            options: ConfettiOptions(
              angle: randomInRange(55, 125),
              spread: randomInRange(50, 70),
              particleCount: randomInRange(50, 100).toInt(),
              y: 0.6,
            ),
          );
        });
      }
    });
  }

  double culPercentQuestionCorrect() {
    int correctCount = widget.questions.where((q) => q.correct).length;
    return (correctCount / widget.questions.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: InkWell(onTap: () => Navigator.pop(context))),
        Positioned.fill(
          top: 30.h,
          child: Confetti(controller: controller),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Configs.instance.commonRadiusBottomSheet),
              ),
            ),
            child: Column(
              spacing: 10,
              children: [
                percentQuestionCorrect > 50
                    ? AssetsImages.images.imageCongratulations.image(width: 91)
                    : AssetsImages.images.imageDongiveup.image(width: 91),
                Text(
                  percentQuestionCorrect > 50
                      ? context.l10n.congratulations
                      : context.l10n.dongiveup,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.congratulationsDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),

                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: colorCorrect.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(
                            Configs.instance.commonRadius,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Icon(Icons.check_circle, color: colorCorrect),
                            Center(
                              child: Text(
                                '${widget.questions.where((q) => q.correct).length} ',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colorCorrect),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: colorIncorrect.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(
                            Configs.instance.commonRadius,
                          ),
                        ),
                        child: Stack(
                          children: [
                            AssetsImages.icons.iconCircleXmark.svg(width: 20),
                            Center(
                              child: Text(
                                '${widget.questions.where((q) => !q.correct).length} ',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colorIncorrect),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedScaleButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      createRouter(ViewdetailPage(questions: widget.questions)),
                    );
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.viewDetail,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Icon(Icons.chevron_right_outlined),
                      ],
                    ),
                  ),
                ),
                AdNativeWidget(),
                Divider(height: 10),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: AnimatedScaleButton(
                        pressedScale: .95,
                        onPressed: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorCorrect.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(
                              Configs.instance.commonRadiusMax,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorCorrect.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            context.l10n.gotoHomepage,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorCorrect),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedScaleButton(
                        onPressed: () => Navigator.pop(context, false),

                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorCorrect,
                            borderRadius: BorderRadius.circular(
                              Configs.instance.commonRadiusMax,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorCorrect.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            context.l10n.keepPracticing,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
