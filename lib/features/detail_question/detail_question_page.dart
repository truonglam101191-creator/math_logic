import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/enum/enum_question_type.dart';
import 'package:logic_mathematics/cores/models/math_question_model.dart';
import 'package:logic_mathematics/cores/widgets/app_bar_widget.dart';
import 'package:logic_mathematics/cores/utils/fraction_utils.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/l10n/l10n.dart';

class DetailQuestionPage extends StatefulWidget {
  const DetailQuestionPage({
    super.key,
    required this.question,
    required this.questionIndex,
  });
  final MathQuestion question;

  final int questionIndex;

  @override
  State<DetailQuestionPage> createState() => _DetailQuestionPageState();
}

class _DetailQuestionPageState extends State<DetailQuestionPage> {
  final colorCorrect = const Color(0xFF009F68);
  final colorIncorrect = const Color(0xFFFF0000);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: Text(
          '${context.l10n.question} ${widget.questionIndex + 1}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: _buildBody,
    );
  }

  Widget get _buildBody {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                Configs.instance.commonRadius,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  widget.question.question,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: _buildUserAnswerDisplay(),
                ),
              ],
            ),
          ),
          if (!widget.question.correct)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorIncorrect.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  Configs.instance.commonRadius,
                ),
              ),
              child: Row(
                spacing: 10,
                children: [
                  AssetsImages.icons.iconCircleXmark.svg(
                    width: 20,
                    color: colorIncorrect,
                  ),
                  Text(
                    context.l10n.incorrect,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colorIncorrect),
                  ),
                ],
              ),
            ),
          Text(
            context.l10n.result,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.titleMedium?.color?.withValues(alpha: .5),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: colorCorrect.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                Configs.instance.commonRadius,
              ),
            ),
            child: Text(
              '${widget.question.question.replaceAll('?', '')} ${_formatAnswer(widget.question.answer)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorCorrect),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnswerDisplay() {
    final userAnswer = widget.question.userAnswers?.toString() ?? '';
    final formattedAnswer = _formatAnswer(userAnswer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your answer: $formattedAnswer',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.question.correct ? colorCorrect : colorIncorrect,
          ),
        ),
        // Show simplified fraction if it's different
        if (userAnswer.contains('/')) ...[
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final simplified = FractionUtils.simplifyString(userAnswer);
              if (simplified != null && simplified != userAnswer) {
                return Text(
                  'Simplified: $simplified',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  String _formatAnswer(dynamic answer) {
    final answerStr = answer.toString();

    // Try to format as fraction if it contains '/'
    if (answerStr.contains('/')) {
      final simplified = FractionUtils.simplifyString(answerStr);
      return simplified ?? answerStr;
    }

    return answerStr;
  }
}
