class ReponseData {
  ReponseData({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
    required this.systemFingerprint,
    required this.dataImages,
  });
  late final String id;
  late final String object;
  late final int created;
  late final String model;
  late final List<Choices> choices;
  late final Usage usage;
  late final String systemFingerprint;
  late final List<ImageData> dataImages;

  ReponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    object = json['object'] ?? '';
    created = json['created'] ?? 0;
    model = json['model'] ?? '';
    choices = List.from(json['choices'] ?? [])
        .map((e) => Choices.fromJson(e))
        .toList();
    usage = json['usage'] != null
        ? Usage.fromJson(json['usage'])
        : Usage(completionTokens: 0, promptTokens: 0, totalTokens: 0);
    systemFingerprint = json['system_fingerprint'] ?? '';
    dataImages = List.from(json['data'] ?? [])
        .map((e) => ImageData.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['object'] = object;
    data['created'] = created;
    data['model'] = model;
    data['choices'] = choices.map((e) => e.toJson()).toList();
    data['usage'] = usage.toJson();
    data['system_fingerprint'] = systemFingerprint;
    return data;
  }
}

class Choices {
  Choices({
    required this.index,
    required this.message,
    this.logprobs,
    required this.finishReason,
  });
  late final int index;
  late final Message message;
  late final Null logprobs;
  late final String finishReason;

  Choices.fromJson(Map<String, dynamic> json) {
    index = json['index'] ?? 0;
    message = Message.fromJson(json['message']);
    logprobs = null;
    finishReason = json['finish_reason'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['index'] = index;
    data['message'] = message.toJson();
    data['logprobs'] = logprobs;
    data['finish_reason'] = finishReason;
    return data;
  }
}

class Message {
  Message({
    required this.role,
    required this.content,
    this.timestamp,
    required this.contents,
    this.isImage = false,
  });
  late final String role;
  late String content;
  late final List<ContentTypeMessage> contents;
  late final bool isImage;
  DateTime? timestamp;

  Message.fromJson(Map<String, dynamic> json) {
    role = json['role'] ?? '';
    isImage = json['isImage'] ?? false;
    if (json['content'] is String) {
      content = json['content'];
      contents = [];
    } else if (json['content'] is List) {
      content = '';
      contents = List.from(json['content'])
          .map((e) => ContentTypeMessage.fromJson(e))
          .toList();
    }
    timestamp =
        json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['role'] = role;
    data['isImage'] = isImage;
    data['content'] = contents.isNotEmpty
        ? contents.map((e) => e.toJson()).toList()
        : content;
    return data;
  }
}

class ContentTypeMessage {
  late String type;
  late String content;

  ContentTypeMessage({
    this.content = '',
    this.type = '',
  });

  ContentTypeMessage.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? '';
    content = '';
    switch (type) {
      case 'text':
        content = json[type];
        break;
      case 'image_url':
        content = json[type]['url'];
        break;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      type:
          type == 'text' ? content : {'url': 'data:image/jpeg;base64,$content'}
    };
  }
}

class Usage {
  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
  late final int promptTokens;
  late final int completionTokens;
  late final int totalTokens;

  Usage.fromJson(Map<String, dynamic> json) {
    promptTokens = json['prompt_tokens'] ?? 0;
    completionTokens = json['completion_tokens'] ?? 0;
    totalTokens = json['total_tokens'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['prompt_tokens'] = promptTokens;
    data['completion_tokens'] = completionTokens;
    data['total_tokens'] = totalTokens;
    return data;
  }
}

class ImageData {
  late final String url;
  ImageData({this.url = ''});

  ImageData.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }
}
