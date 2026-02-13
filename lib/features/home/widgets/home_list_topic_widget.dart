import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/datas/topic_data.dart';
import 'package:logic_mathematics/features/home/widgets/home_item_topic_widget.dart';

class HomeListTopicWidget extends StatelessWidget {
  HomeListTopicWidget({super.key});

  final List<TopicData> topics = TopicData.allTopics;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) {
          return HomeItemTopicWidget(topic: topics[index]);
        },
        itemCount: topics.length,
      ),
    );
  }
}
