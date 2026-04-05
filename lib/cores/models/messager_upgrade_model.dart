import 'package:logic_mathematics/cores/models/chat_message_model.dart';

class MessagerUpgradeModel {
  late String role;
  late String content;
  late List<ContentTypeMessage> contents;
  late bool isImage;
  late bool isPlaying;

  MessagerUpgradeModel({
    required this.content,
    required this.role,
    this.isPlaying = false,
    required this.contents,
    required this.isImage,
  });
}
