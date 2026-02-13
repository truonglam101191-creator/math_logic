import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/gradient_button_widget.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewVersionBottomsheet extends StatelessWidget {
  const NewVersionBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Configs.instance.commonRadiusBottomSheet,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.gradientBottomSheet,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  context.l10n.newUpdate,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  context.l10n.newUpdateDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('''✨ What’s New in This Version:
  🚀 Brand-New UI: Cleaner, smoother, and easier to use.
  🎨 Modern Design: Fresh visuals that feel just right.
  📱 Better Navigation: Find what you need, faster than ever.
  ⚡ Improved Performance: Lighter, quicker, and more responsive.
  🛠️ Bug Fixes: We squashed some bugs for a smoother ride.
  Update now to enjoy the upgraded experience!''', textAlign: TextAlign.center),
                SizedBox(),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: GradientButtonWidget(
                        onPressed: () => Navigator.pop(context, true),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(
                            Configs.instance.commonRadiusMax,
                          ),
                        ),
                        child: Text(
                          context.l10n.updateLater,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GradientButtonWidget(
                        padding: EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Configs.instance.commonRadiusMax,
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          launchUrlString(
                            'https://play.google.com/store/apps/details?id=${Shared.instance.packageInfo.packageName}',
                          );
                        },
                        child: Text(
                          context.l10n.updateNow,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SizedBox(height: 15),
        ],
      ),
    );
  }
}
