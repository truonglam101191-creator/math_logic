import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/features/game_core/widgets/animated_background.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/gen/assets.gen.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInformationPage extends StatefulWidget {
  const AppInformationPage({super.key});

  @override
  State<AppInformationPage> createState() => _AppInformationPageState();
}

class _AppInformationPageState extends State<AppInformationPage> {
  void _openPrivacyPolicy() async {
    final url = 'https://logicmath-eca11.web.app/privacy';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  void _openTermsOfService() async {
    final url = 'https://logicmath-eca11.web.app/terms';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF5F8F5);
    final primary = AppColors.accentDark;

    final l10n = AppLocalizations.of(context);
    final package = Shared.instance.packageInfo;
    final appName = package.appName.split(':').first;
    final version = '${package.version}';
    final build = package.buildNumber;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const AnimatedBackground(
              backgroundColor: Color(0xFFF5F8F5),
              particleColor: Color(0x15000000),
            ),
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                  ),
                  child: SizedBox(
                    height: kToolbarHeight - 16,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            l10n.appInfo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedScaleButton(
                            onPressed: () => Navigator.maybePop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      // image with glow ring
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  primary.withOpacity(0.18),
                                  Colors.transparent,
                                ],
                                radius: 0.8,
                              ),
                            ),
                          ),
                          Container(
                            width: 112,
                            height: 112,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: AssetsImages.images.imageLogoApp.image(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      Text(
                        appName.isNotEmpty ? appName : 'Toán Học Vui Vẻ',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primary.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.2),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          context.l10n.versionandbuild(version, build),
                          style: const TextStyle(color: Color(0xFF1BC41B)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(l10n.sectionGeneral, primary),
                        const SizedBox(height: 8),
                        _roundedCard(
                          children: [
                            _infoRow(
                              icon: Icons.business,
                              iconBg: Colors.blue.shade50,
                              title: l10n.developer,
                              trailing: Text(
                                'Lâm Developer',
                                style: TextStyle(color: Colors.green.shade900),
                              ),
                            ),
                            _infoLinkRow(
                              icon: Icons.language,
                              iconBg: Colors.purple.shade50,
                              title: l10n.website,
                              linkText: 'logicmath.app',
                              onTap: () async {
                                final url = 'https://logicmath-eca11.web.app/';
                                try {
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(
                                      Uri.parse(url),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                } catch (e) {
                                  debugPrint('Could not launch $url: $e');
                                }
                              },
                            ),
                            _infoRow(
                              icon: Icons.mail,
                              iconBg: Colors.orange.shade50,
                              title: l10n.contactUs,
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                              onTap: () async {
                                final infoDevice = await serviceLocator
                                    .get<DeviceInfoPlugin>()
                                    .androidInfo;
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
                                  debugPrint('Could not launch $url: $e');
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle(l10n.sectionLegalSupport, primary),
                        const SizedBox(height: 8),
                        _roundedCard(
                          children: [
                            _infoLinkRow(
                              icon: Icons.policy,
                              iconBg: Colors.grey.shade100,
                              title: l10n.privacyPolicy,
                              linkText: '',
                              onTap: _openPrivacyPolicy,
                            ),
                            _infoLinkRow(
                              icon: Icons.description,
                              iconBg: Colors.grey.shade100,
                              title: l10n.termsOfService,
                              linkText: '',
                              onTap: _openTermsOfService,
                            ),
                            // _infoLinkRow(
                            //   icon: Icons.code,
                            //   iconBg: Colors.grey.shade100,
                            //   title: l10n.openSourceLicenses,
                            //   linkText: '',
                            //   onTap: () {},
                            // ),
                          ],
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     _socialBtn(icon: Icons.facebook),
                        //     const SizedBox(width: 12),
                        //     _socialBtn(icon: Icons.alternate_email),
                        //     const SizedBox(width: 12),
                        //     _socialBtn(icon: Icons.camera_alt),
                        //   ],
                        // ),
                        const SizedBox(height: 22),
                        // Social buttons
                        Center(
                          child: Text(
                            l10n.copyrightNotice(2025),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: color.withOpacity(0.85),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _roundedCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(children.length * 2 - 1, (i) {
            if (i.isOdd)
              return Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade100,
              );
            return children[i ~/ 2];
          }),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.black54, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing else const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _infoLinkRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String linkText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.black54, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (linkText.isNotEmpty)
              Row(
                children: [
                  Text(linkText, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _socialBtn({required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, color: Colors.green.shade700, size: 22),
    );
  }
}
