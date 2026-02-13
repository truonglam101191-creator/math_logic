import 'package:oziapi/models/request_model.dart';

class MessagerUpgradeModel {
  late final String role;
  late final String content;
  late final List<ContentTypeMessage> contents;
  late final bool isImage;
  late bool isPlaying;

  MessagerUpgradeModel({
    required this.content,
    required this.role,
    this.isPlaying = false,
    required this.contents,
    required this.isImage,
  });
}
