import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/user_coin_widget.dart';
import 'package:logic_mathematics/features/bottomsheets/selectlevelandnumberofquestions_bottomsheetda.dart';
import 'package:logic_mathematics/features/setting/setting_page.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/l10n.dart';

class HomeBodyWidget extends StatelessWidget {
  const HomeBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientStartusbar,
        ),
      ),
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            Positioned.fill(
              top: 15,
              child: Text(
                context.l10n.listofTopics,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UserCoinWidget(textColor: Colors.white),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          //constraints: BoxConstraints(maxHeight: 310),
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              SelectlevelandnumberofquestionsBottomsheetda(),
                        ),
                        icon: AssetsImages.icons.iconSettingsSliders.svg(),
                      ),
                      IconButton(
                        onPressed: () {
                          if (Platform.isAndroid)
                            FirebaseAnalytics.instance.logEvent(
                              name: 'open_settings_page',
                            );
                          Navigator.push(context, createRouter(SettingPage()));
                        },
                        icon: Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
