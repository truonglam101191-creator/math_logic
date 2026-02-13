import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/datas/topic_data.dart';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/features/practice/practice_screen.dart';

class HomeItemTopicWidget extends StatelessWidget {
  const HomeItemTopicWidget({super.key, required this.topic});

  final TopicData topic;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          FirebaseAnalytics.instance.logEvent(
            name: 'select_topic',
            parameters: {'topic_title': topic.title},
          );
          // Navigator.push(
          //   context,
          //   createRouter(
          //     PracticeScreen(
          //       topic: topic.title,
          //       questions: topic.generateQuestions(
          //         Difficulty.values
          //             .where(
          //               (element) =>
          //                   element.name ==
          //                   Shared.instance.numberOfQuestions.option,
          //             )
          //             .first,
          //         Shared.instance.numberOfQuestions.numberOfQuestions,
          //       ),
          //       onEarnCoins: (int) {},
          //     ),
          //   ),
          // );
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              topic.path.image(height: 58),
              Text(
                topic.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
