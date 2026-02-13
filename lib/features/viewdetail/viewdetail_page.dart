import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/models/math_question_model.dart';
import 'package:logic_mathematics/cores/widgets/ad_native_widget.dart';
import 'package:logic_mathematics/cores/widgets/app_bar_widget.dart';
import 'package:logic_mathematics/features/detail_question/detail_question_page.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';

class ViewdetailPage extends StatefulWidget {
  const ViewdetailPage({super.key, required this.questions});

  final List<MathQuestion> questions;

  @override
  State<ViewdetailPage> createState() => _ViewdetailPageState();
}

class _ViewdetailPageState extends State<ViewdetailPage> {
  final colorCorrect = const Color(0xFF009F68);
  final colorIncorrect = const Color(0xFFFF0000);
  double percentQuestionCorrect = 0;

  double culPercentQuestionCorrect() {
    int correctCount = widget.questions.where((q) => q.correct).length;
    return (correctCount / widget.questions.length) * 100;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    percentQuestionCorrect = culPercentQuestionCorrect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: Text(
          context.l10n.viewDetail,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: _buildGirdQuestion(),
    );
  }

  Widget _buildGirdQuestion() {
    return Column(
      spacing: 10,
      children: [
        SizedBox(),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Configs.instance.commonRadius),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                '${context.l10n.totalQuestions}: ${widget.questions.length}',
              ),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
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
                      padding: const EdgeInsets.all(10.0),
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
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15),
            itemCount: widget.questions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final question = widget.questions[index];
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  createRouter(
                    DetailQuestionPage(
                      question: question,
                      questionIndex: index,
                    ),
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: question.correct
                        ? colorCorrect.withValues(alpha: .1)
                        : colorIncorrect.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(
                      Configs.instance.commonRadius,
                    ),
                  ),
                  child: Text(
                    '${context.l10n.question} ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: question.correct ? colorCorrect : colorIncorrect,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AdNativeWidget(),
      ],
    );
  }
}
