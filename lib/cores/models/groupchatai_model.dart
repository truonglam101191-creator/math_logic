import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/models/common_model.dart';
import 'package:logic_mathematics/cores/models/chat_message_model.dart';

class ChatGroup extends CommonModel {
  late String idGroup;
  late String namegroup;
  late bool isArchived;
  late GlobalKey key;
  late final List<Message> listchat;
  late DateTime created;
  late DateTime updated;
  late String workSpace;
  late String idUser;
  late String label;
  late bool isOpen;

  ChatGroup({
    this.idGroup = '',
    this.namegroup = '',
    required this.listchat,
    super.isFav = false,
    super.isImp = false,
    super.isPin = false,
    super.isEdit = false,
    super.isNew = false,
    this.isArchived = false,
    required this.created,
    required this.updated,
    this.workSpace = '',
    this.idUser = '',
    this.label = '',
    this.isOpen = false,
  }) {
    created = DateTime.now();
    key = GlobalKey();
  }
  ChatGroup.fromJson(Map<String, dynamic> json) {
    isOpen = false;
    key = GlobalKey();
    idGroup = json['idgroup'] ?? '';
    namegroup = json['namegroup'] ?? '';
    isFav = json['isFav'] ?? false;
    isImp = json['isImp'] ?? false;
    isPin = json['isPin'] ?? false;
    isArchived = json['isArchived'] ?? false;
    listchat = List.from(
      json['listchat'] ?? [],
    ).map((e) => Message.fromJson(e)).toList();
    workSpace = json['workSpace'] ?? '';
    created = DateTime.parse(json['created'] ?? '');
    updated = DateTime.parse(json['updated'] ?? '');
    idUser = json['idUser'] ?? '';
    label = json['label'] ?? '';
  }

  String? get color => null;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['idgroup'] = idGroup;
    data['namegroup'] = namegroup;
    data['isFav'] = isFav;
    data['isImp'] = isImp;
    data['isPin'] = isPin;
    data['isArchived'] = isArchived;
    data['listchat'] = listchat.map((e) => e.toJson()).toList();
    data['created'] = created
        .toString(); // Chuyển thời gian tạo thành dạng milliseconds từ epoch để lưu vào JSON
    data['updated'] = updated.toString();
    data['workSpace'] = workSpace;
    data['idUser'] = idUser;
    data['label'] = label;
    return data;
  }

  ChatGroup copyWith({
    String? idGroup,
    List<Message>? listchat,
    DateTime? created,
    DateTime? updated,
    String? namegroup,
    bool? isPin,
    bool? isFav,
    bool? isImp,
    bool? isArchived,
    String? workSpace,
    String? idUser,
    String? label,
  }) {
    return ChatGroup(
      idGroup: idGroup ?? this.idGroup,
      namegroup: namegroup ?? this.namegroup,
      listchat: listchat ?? this.listchat,
      created: created ?? this.created,
      isFav: isFav ?? this.isFav,
      isImp: isImp ?? this.isImp,
      isPin: isPin ?? this.isPin,
      isArchived: isArchived ?? this.isArchived,
      workSpace: workSpace ?? this.workSpace,
      idUser: idUser ?? this.idUser,
      label: label ?? this.label,
      updated: updated ?? this.updated,
    );
  }
}
