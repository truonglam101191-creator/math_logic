import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/chat_ai/chat_ai_page.dart';

Offset getPosition(GlobalKey key) {
  RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
  return box.localToGlobal(Offset.zero);
}

createRouter(Widget page, {bool isCupertino = true}) {
  return isCupertino
      ? CupertinoPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: page.runtimeType.toString()),
        )
      : MaterialPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: page.runtimeType.toString()),
        );
}
