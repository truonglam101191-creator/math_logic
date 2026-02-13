import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/features/in_app/in_app_product_page.dart';
import 'package:logic_mathematics/features/mini_game/data_2024/const/colors.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/main.dart';

class UserCoinWidget extends StatefulWidget {
  const UserCoinWidget({
    super.key,
    this.textColor,
    this.radius,
    this.paddingRight = 0,
    this.showInAppPage = true,
  });

  final Color? textColor;

  final double? radius;

  final double paddingRight;
  final bool showInAppPage;

  @override
  State<UserCoinWidget> createState() => _UserCoinWidgetState();
}

class _UserCoinWidgetState extends State<UserCoinWidget> {
  int coin = 0;

  @override
  void initState() {
    super.initState();
    getUserCoin();
    serviceLocator<MessagingService>().subscribe(
      this,
      channel: MessageChannel.startUserChanged,
      action: (val) {
        getUserCoin();
      },
    );
  }

  void getUserCoin() {
    serviceLocator<DataBaseFuntion>().getStar().then((value) {
      if (mounted) {
        setState(() {
          coin = value;
        });
      }
    });
  }

  @override
  void dispose() {
    serviceLocator<MessagingService>().unsubscribe(
      this,
      channel: MessageChannel.startUserChanged,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!widget.showInAppPage) return;
        Navigator.push(context, createRouter(InAppProductPage()));
      },
      child: Container(
        margin: EdgeInsets.only(right: widget.paddingRight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFFFFF7E0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFE9B8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Color(0xFFFFC700), size: 18),
            SizedBox(width: 8),
            Text(
              '$coin',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFC700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
