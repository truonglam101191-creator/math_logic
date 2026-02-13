import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/admanager_banner.dart';
import 'package:logic_mathematics/cores/widgets/admob_adapter_banner.dart';
import 'package:logic_mathematics/features/in_app/in_app_product_page.dart';
import 'package:logic_mathematics/features/manager_ai/manager_ai_page.dart';
import 'package:logic_mathematics/features/temr/temrs_of_condition_page.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final inAppReview = InAppReview.instance;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primaryDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Info Section
                    _buildSection(
                      title: l10n.appInfo,
                      children: [
                        // _buildSettingItem(
                        //   icon: Icons.smart_toy_outlined,
                        //   title: l10n.aiModelManager,
                        //   subtitle: l10n.manageModels,
                        //   onTap: _goToAiManager,
                        // ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.info_outline,
                          title: l10n.version,
                          subtitle: Shared.instance.packageInfo.version,
                          onTap: null,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.apps,
                          title: l10n.appName,
                          subtitle: Shared.instance.packageInfo.appName
                              .split(':')
                              .first,
                          onTap: null,
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Share & Support Section
                    _buildSection(
                      title: l10n.shareAndSupport,
                      children: [
                        _buildSettingItem(
                          icon: Icons.monetization_on,
                          title: l10n.buyCoins,
                          subtitle: l10n.buyCoinsDescription,
                          onTap: _goToShop,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.share,
                          title: l10n.shareApp,
                          subtitle: l10n.shareAppDescription,
                          onTap: _shareApp,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.star_rate,
                          title: l10n.rateApp,
                          subtitle: l10n.rateAppDescription,
                          onTap: _rateApp,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.feedback,
                          title: l10n.feedback,
                          subtitle: l10n.feedbackDescription,
                          onTap: _sendFeedback,
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Legal Section
                    _buildSection(
                      title: l10n.legal,
                      children: [
                        _buildSettingItem(
                          icon: Icons.privacy_tip,
                          title: l10n.privacyPolicy,
                          subtitle: l10n.privacyPolicyDescription,
                          onTap: _openPrivacyPolicy,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.description,
                          title: l10n.termsOfService,
                          subtitle: l10n.termsOfServiceDescription,
                          onTap: _openTermsOfService,
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // About Section
                    _buildSection(
                      title: l10n.about,
                      children: [
                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: l10n.help,
                          subtitle: l10n.helpDescription,
                          onTap: _openHelp,
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.contact_mail,
                          title: l10n.contactUs,
                          subtitle: l10n.contactUsDescription,
                          onTap: _contactUs,
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
            AdmobAdapterBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 4.w, bottom: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE4E1), Color(0xFFE6E6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFB6C1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '✨ $title',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFB6C1).withOpacity(0.15),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0xFFFFB6C1).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    // Map icon colors for different sections
    Color getIconColor() {
      switch (icon) {
        case Icons.info_outline:
        case Icons.apps:
          return Color(0xFF4FC3F7); // Light Blue
        case Icons.monetization_on:
          return Color(0xFFFFD700); // Gold
        case Icons.share:
        case Icons.star_rate:
        case Icons.feedback:
          return Color(0xFFFFB74D); // Orange
        case Icons.privacy_tip:
        case Icons.description:
          return Color(0xFF81C784); // Green
        case Icons.help_outline:
        case Icons.contact_mail:
          return Color(0xFFBA68C8); // Purple
        default:
          return AppColors.primaryDark;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: onTap != null ? Colors.white : Colors.grey[50],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        leading: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                getIconColor().withOpacity(0.2),
                getIconColor().withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: getIconColor().withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: getIconColor(), size: 6.w),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 13.sp, height: 1.2),
        ),
        trailing: onTap != null
            ? Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 5.w,
                ),
              )
            : Container(
                padding: EdgeInsets.all(1.w),
                child: Icon(Icons.info, color: Color(0xFFE2E8F0), size: 4.w),
              ),
        onTap: onTap != null
            ? () {
                // Add haptic feedback
                // HapticFeedback.lightImpact();
                onTap();
              }
            : null,
      ),
    );
  }

  void _shareApp() {
    // Uncomment when share_plus is added
    Share.share(
      'Check out this amazing Logic Mathematics app! Download it now: https://play.google.com/store/apps/details?id=${Shared.instance.packageInfo.packageName}',
      subject: 'Logic Mathematics App',
    );

    // For now, show a snackbar with cute design
  }

  void _rateApp() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      _showCuteSnackBar('⚠️', 'In-app review not available', Color(0xFFFFB74D));
    }
  }

  void _sendFeedback() async {
    final subject = 'Feedback for Logic Mathematics App';
    final body =
        'Hi,\n\nI would like to share my feedback about the Logic Mathematics app:\n\n';
    final url =
        'mailto:${Configs.emailSupport}?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      _showCuteSnackBar('📧', 'Could not open email app', Color(0xFFBA68C8));
    }
  }

  void _openPrivacyPolicy() async {
    final url =
        'https://privacy-policy-lam.blogspot.com/2025/07/logicmath.html';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showCuteSnackBar(
        '🔒',
        'Could not open privacy policy',
        Color(0xFF81C784),
      );
    }
  }

  void _openTermsOfService() async {
    Navigator.push(context, createRouter(TermsOfConditionsPage()));
  }

  void _openHelp() async {
    final infoDevice = await serviceLocator.get<DeviceInfoPlugin>().androidInfo;
    final subject = 'Help Request';
    final body =
        'Device ${infoDevice.board} ${infoDevice.display} \n Hi, I need help with the Logic Mathematics app: ';
    final url =
        'mailto:${Configs.emailSupport}?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      _showCuteSnackBar('📧', 'Could not open email app', Color(0xFFBA68C8));
    }
  }

  void _contactUs() async {
    final subject = 'Contact Support';
    final url =
        'mailto:${Configs.emailSupport}?subject=${Uri.encodeComponent(subject)}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      _showCuteSnackBar('📧', 'Could not open email app', Color(0xFFBA68C8));
    }
  }

  void _goToShop() {
    // Navigate to shop page to buy coins
    // _showCuteSnackBar('🛒', 'Shop feature coming soon!', Color(0xFFFFD700));
    // TODO: Navigate to shop page
    Navigator.push(context, createRouter(InAppProductPage()));
  }

  // void _goToAiManager() {
  //   Navigator.push(context, createRouter(ManagerAiPage()));
  // }

  void _showCuteSnackBar(String emoji, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
