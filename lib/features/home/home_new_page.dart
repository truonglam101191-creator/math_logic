import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/db_storage/db_funtion.dart';
import 'package:logic_mathematics/cores/extentions/in_app_purchase.dart';
import 'package:logic_mathematics/cores/extentions/messagingservice.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/services/local_notification_service.dart';
import 'package:logic_mathematics/cores/themes/app_colors.dart';
import 'package:logic_mathematics/cores/widgets/admob_adapter_banner.dart';
import 'package:logic_mathematics/features/home/tabs/home_tab.dart';
import 'package:logic_mathematics/features/home/tabs/setting_info_tab.dart';
import 'package:logic_mathematics/features/home/tabs/shop_tab.dart';
import 'package:logic_mathematics/features/home/tabs/summary_tab.dart';
import 'package:logic_mathematics/l10n/l10n.dart';
import 'package:logic_mathematics/main.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class HomeNewPage extends StatefulWidget {
  const HomeNewPage({super.key});

  @override
  State<HomeNewPage> createState() => _HomeNewPageState();
}

class _HomeNewPageState extends State<HomeNewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final updater = ShorebirdUpdater();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    LocalInAppPurchase.onInAppSuccess = (val) async {
      final item = LocalInAppPurchase.listProduct.firstWhere(
        (element) => element.id == val.productID,
      );
      final coinCoinFrom = int.parse(
        item.title.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final getCurrentStar = await serviceLocator
          .get<DataBaseFuntion>()
          .getStar();
      final newStar = getCurrentStar + coinCoinFrom;
      serviceLocator.get<DataBaseFuntion>().saveStar(newStar).then((value) {
        serviceLocator<MessagingService>().send(
          channel: MessageChannel.startUserChanged,
          parameter: '',
        );
      });
    };
    _checkForUpdates();
    serviceLocator.get<LocalNotificationService>().requestPermissions().then((
      granted,
    ) {
      if (granted) {
        serviceLocator
            .get<LocalNotificationService>()
            .scheduleDailyReminderIfNeeded();
      } else {
        debugPrint('Notification permissions not granted.');
      }
    });
  }

  Future<void> _checkForUpdates() async {
    // Check whether a new update is available.
    final status = await updater.checkForUpdate();

    if (status == UpdateStatus.outdated) {
      try {
        // Perform the update
        await updater.update();
      } catch (_) {
        // Handle any errors that occur while updating.
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Shared.instance.setContext(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Column(
        children: [
          // Bottom navigation mimic
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                HomeTab(),
                SummaryTab(onPlay: () => _tabController.animateTo(0)),
                ShopTab(),
                SettingInfoTab(
                  onBackCoin: () {
                    _tabController.animateTo(2);
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 15),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (BuildContext context, Widget? child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _NavItem(
                            icon: Icons.home_filled,
                            label: l10n.home_nav_home,
                            active: _tabController.index == 0,
                            onTap: () => _tabController.animateTo(0),
                          ),
                          _NavItem(
                            icon: Icons.bar_chart,
                            label: l10n.home_nav_summary,
                            active: _tabController.index == 1,
                            onTap: () => _tabController.animateTo(1),
                          ),
                          _NavItem(
                            icon: Icons.storefront,
                            label: l10n.home_nav_store,
                            active: _tabController.index == 2,
                            onTap: () => _tabController.animateTo(2),
                          ),
                          _NavItem(
                            icon: Icons.settings,
                            label: l10n.home_nav_settings,
                            active: _tabController.index == 3,
                            onTap: () => _tabController.animateTo(3),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 5),
                  AdmobAdapterBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primaryDark : Colors.grey[400],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primaryDark : Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
