class ContentTypeMessage {
  final String type; // Usually 'text' or 'image_url' or 'url_image'
  final String content;

  ContentTypeMessage({
    required this.type,
    required this.content,
  });

  factory ContentTypeMessage.fromJson(Map<String, dynamic> json) {
    String type = json['type'] ?? 'text';
    String content = '';
    
    // Fallback for OziApi legacy JSON where image_url is an object
    if (json['content'] != null) {
      content = json['content'].toString();
    } else if (json['image_url'] != null && json['image_url']['url'] != null) {
      content = json['image_url']['url'].toString();
    }
    
    return ContentTypeMessage(
      type: type,
      content: content,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
    };
    if (type == 'image_url' || type == 'url_image') {
      map['image_url'] = {'url': content};
    } else {
      map['content'] = content;
    }
    return map;
  }
}

class Message {
  String role; // 'user' or 'assistant' / 'model'
  String content;
  bool isImage;
  List<ContentTypeMessage> contents;
  DateTime? timestamp;

  Message({
    required this.role,
    this.content = '',
    this.isImage = false,
    this.contents = const [],
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] ?? 'user',
      content: json['content']?.toString() ?? '',
      isImage: json['isImage'] == true,
      contents: (json['contents'] as List?)
              ?.map((e) => ContentTypeMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'isImage': isImage,
      'contents': contents.map((e) => e.toJson()).toList(),
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
