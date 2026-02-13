import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/enum/enum_function_settings_key.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/app_information/app_information_page.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingInfoTab extends StatefulWidget {
  const SettingInfoTab({super.key, this.onBackCoin});

  final VoidCallback? onBackCoin;

  @override
  State<SettingInfoTab> createState() => _SettingInfoTabState();
}

class _SettingInfoTabState extends State<SettingInfoTab>
    with AutomaticKeepAliveClientMixin {
  final inAppReview = InAppReview.instance;

  void _shareApp() {
    // Uncomment when share_plus is added
    Share.share(
      'https://play.google.com/store/apps/details?id=${Shared.instance.packageInfo.packageName}',
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
    final url = 'https://logicmath-eca11.web.app/#/privacy';
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
    final url = 'https://logicmath-eca11.web.app/#/terms';
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

  void handleSettingItemTap(EnumFunctionSettingsKey key) {
    switch (key) {
      case EnumFunctionSettingsKey.app_information:
        Navigator.push(context, createRouter(AppInformationPage()));
        break;
      case EnumFunctionSettingsKey.buy_coin:
        widget.onBackCoin?.call();
        break;
      case EnumFunctionSettingsKey.share_app:
        _shareApp();
        break;
      case EnumFunctionSettingsKey.rate_app:
        _rateApp();
        break;
      case EnumFunctionSettingsKey.feedback:
        _sendFeedback();
        break;
      case EnumFunctionSettingsKey.help_support:
        _openHelp();
        break;
      case EnumFunctionSettingsKey.contact_us:
        _contactUs();
        break;
      case EnumFunctionSettingsKey.privacy_policy:
        _openPrivacyPolicy();
        break;
      case EnumFunctionSettingsKey.terms_of_service:
        _openTermsOfService();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bg = const Color(0xFFF5F8F5);
    final primary = AppColors.accentDark;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: BoxDecoration(
                color: bg.withOpacity(0.95),
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Builder(
                        builder: (c) {
                          final l10n = AppLocalizations.of(c);
                          return Text(
                            l10n.settingInfoTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      AppLocalizations.of(context).sectionGeneral,
                      primary,
                    ),
                    const SizedBox(height: 8),
                    _roundedCard(
                      onTap: (keyFunction) => handleSettingItemTap(keyFunction),
                      context,
                      items: [
                        // _SettingItemData(
                        //   icon: Icons.settings,
                        //   iconBg: Colors.blue.shade50,
                        //   iconColor: Colors.blue.shade600,
                        //   title: 'Cài đặt hệ thống',
                        //   subtitle: 'Âm thanh, thông báo & hiển thị',
                        // ),
                        _SettingItemData(
                          icon: Icons.info,
                          iconBg: Colors.purple.shade50,
                          iconColor: Colors.purple.shade600,
                          functionKey: EnumFunctionSettingsKey.app_information,
                          title: AppLocalizations.of(context).appInformation,
                          subtitle: AppLocalizations.of(
                            context,
                          ).appInformationDescription,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    _sectionTitle(
                      AppLocalizations.of(context).sectionStoreInteraction,
                      primary,
                    ),
                    const SizedBox(height: 8),
                    _roundedCard(
                      context,
                      onTap: (keyFunction) => handleSettingItemTap(keyFunction),
                      items: [
                        _SettingItemData(
                          icon: Icons.monetization_on,
                          iconBg: primary.withOpacity(0.18),
                          iconColor: primary,
                          title: AppLocalizations.of(context).buyCoins,
                          subtitle: AppLocalizations.of(
                            context,
                          ).buyCoinsDescription,
                          functionKey: EnumFunctionSettingsKey.buy_coin,
                        ),
                        _SettingItemData(
                          icon: Icons.share,
                          iconBg: Colors.orange.shade50,
                          iconColor: Colors.orange.shade600,
                          title: AppLocalizations.of(context).shareApp,
                          subtitle: AppLocalizations.of(
                            context,
                          ).shareAppDescription,
                          functionKey: EnumFunctionSettingsKey.share_app,
                        ),
                        _SettingItemData(
                          icon: Icons.star,
                          iconBg: Colors.yellow.shade50,
                          iconColor: Colors.yellow.shade700,
                          title: AppLocalizations.of(context).rateApp,
                          subtitle: AppLocalizations.of(
                            context,
                          ).rateAppDescription,
                          functionKey: EnumFunctionSettingsKey.rate_app,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    _sectionTitle(
                      AppLocalizations.of(context).sectionLegalSupport,
                      primary,
                    ),
                    const SizedBox(height: 8),
                    _roundedCard(
                      context,
                      onTap: (keyFunction) => handleSettingItemTap(keyFunction),
                      items: [
                        _SettingItemData(
                          icon: Icons.feedback,
                          iconBg: Colors.teal.shade50,
                          iconColor: Colors.teal.shade600,
                          title: AppLocalizations.of(context).feedback,
                          subtitle: AppLocalizations.of(
                            context,
                          ).feedbackDescription,
                          functionKey: EnumFunctionSettingsKey.feedback,
                        ),
                        _SettingItemData(
                          icon: Icons.help,
                          iconBg: Colors.red.shade50,
                          iconColor: Colors.red.shade600,
                          title: AppLocalizations.of(context).help,
                          subtitle: AppLocalizations.of(
                            context,
                          ).helpDescription,
                          functionKey: EnumFunctionSettingsKey.help_support,
                        ),
                        _SettingItemData(
                          icon: Icons.mail,
                          iconBg: Colors.pink.shade50,
                          iconColor: Colors.pink.shade600,
                          title: AppLocalizations.of(context).contactUs,
                          subtitle: AppLocalizations.of(
                            context,
                          ).contactUsDescription,
                          functionKey: EnumFunctionSettingsKey.contact_us,
                        ),
                        _SettingItemData(
                          icon: Icons.security,
                          iconBg: Colors.grey.shade100,
                          iconColor: Colors.grey.shade700,
                          title: AppLocalizations.of(context).privacyPolicy,
                          subtitle: AppLocalizations.of(
                            context,
                          ).privacyPolicyDescription,
                          functionKey: EnumFunctionSettingsKey.privacy_policy,
                        ),
                        _SettingItemData(
                          icon: Icons.gavel,
                          iconBg: Colors.grey.shade100,
                          iconColor: Colors.grey.shade700,
                          title: AppLocalizations.of(context).termsOfService,
                          subtitle: AppLocalizations.of(
                            context,
                          ).termsOfServiceDescription,
                          functionKey: EnumFunctionSettingsKey.terms_of_service,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: AssetsImages.images.imageLogoApp.image(
                              fit: BoxFit.contain,
                            ),
                          ),

                          Text(
                            Shared.instance.packageInfo.appName
                                .split(':')
                                .first,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${context.l10n.version} ${Shared.instance.packageInfo.version}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _roundedCard(
    BuildContext context, {
    required List<_SettingItemData> items,
    Function(EnumFunctionSettingsKey keyFunction)? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final it = items[i];
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: it.iconBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(it.icon, color: it.iconColor, size: 22),
                ),
                title: Text(
                  it.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  it.subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
                onTap: () => onTap?.call(it.functionKey),
              ),
              if (i != items.length - 1)
                Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SettingItemData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final EnumFunctionSettingsKey functionKey;

  _SettingItemData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.functionKey,
  });
}
