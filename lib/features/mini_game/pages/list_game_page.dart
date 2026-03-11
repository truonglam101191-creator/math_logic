import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logic_mathematics/cores/adsmob/ads_mob.dart';
import 'package:logic_mathematics/cores/extentions/utils.dart';
import 'package:logic_mathematics/cores/widgets/user_coin_widget.dart';
import 'package:logic_mathematics/features/home/widgets/animated_scale_button.dart';
import 'package:logic_mathematics/features/mini_game/arrows_escape/arrows_escape_page.dart';
import 'package:logic_mathematics/features/mini_game/logic_tetris/tetris_game_screen.dart';
import 'package:logic_mathematics/features/mini_game/pages/2048_game_page.dart';
import 'package:logic_mathematics/features/mini_game/pages/word_puzzle_game_page.dart';
import 'package:logic_mathematics/features/mini_game/pikachu_connect_game/pikachu_connect_game_page.dart';
import 'package:logic_mathematics/features/mini_game/web_cozy_tiles/web_cozy_tiles.dart';
import 'package:logic_mathematics/features/mini_game/web_duck_war/web_duck_war_stub.dart';
import 'package:logic_mathematics/features/mini_game/web_evolution_merge/web_evolution_merge.dart';
import 'package:logic_mathematics/features/mini_game/web_garden_gulp/web_garden_gulp.dart';
import 'package:logic_mathematics/features/mini_game/web_liquid_sort/web_liquid_sort.dart';
import 'package:logic_mathematics/features/mini_game/web_pack_pal/web_pack_pal_stub.dart';
import 'package:logic_mathematics/features/mini_game/web_quantum_link/web_quantum_link_stub.dart';
import 'package:logic_mathematics/features/mini_game/web_sortie/web_sortie_pal_stub.dart';
import 'package:logic_mathematics/features/mini_game/web_super_crew/web_super_crew.dart';
import 'package:logic_mathematics/features/mini_game/web_wood_block_puzzle/web_web_wood_block_puzzle.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';

import 'package:logic_mathematics/main.dart';
import 'package:logic_mathematics/cores/analytics/usage_service.dart';
import 'package:logic_mathematics/cores/enum/usage_type.dart';

import '../web_circuit_connect/web_circuit_connect_stub.dart';

class ListGamePage extends StatefulWidget {
  const ListGamePage({super.key});

  @override
  State<ListGamePage> createState() => _ListGamePageState();
}

class _ListGamePageState extends State<ListGamePage> {
  //String? _sessionUsageId;

  @override
  void initState() {
    super.initState();
    // _sessionUsageId = UsageService.instance.start(
    //   UsageType.miniGameList,
    //   'mini_game_list',
    //   meta: {'screen': 'list_game'},
    // );
  }

  @override
  void dispose() {
    // if (_sessionUsageId != null) {
    //   UsageService.instance.stop(_sessionUsageId!);
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, loc),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Title Section
                    _buildTitleSection(context, loc),
                    const SizedBox(height: 16),
                    // Featured Banner
                    _buildFeaturedBanner(context, loc),
                    const SizedBox(height: 20),
                    // Games Grid
                    _buildGamesGrid(context, loc),
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

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    return SizedBox(
      height: kToolbarHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Center(
            child: Text(
              loc.home_card_game_title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                BackButton(),
                Spacer(),

                // Coin Badge
                UserCoinWidget(),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              loc.gamesTitleMain,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Text('🎮', style: TextStyle(fontSize: 26)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          loc.gamesTitleSubtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFFBD74C), const Color(0xFFF5C842)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBD74C).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              loc.latest.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.challengeTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.home_card_game_subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context, AppLocalizations loc) {
    final games = [
      GameCardData(
        title: 'Super Crew',
        subtitle: 'Unscrew the bolts to free the nuts',
        imageUrl: 'assets/super_crew/super_crew_thumbnail.gif',
        backgroundColor: const Color(0xFFEAF4FF),
        onTap: () => _openGame(
          context,
          'Super Crew',
          'assets/super_crew/super_crew_thumbnail.gif',
          WebSuperCrew(),
        ),
      ),
      GameCardData(
        title: 'Arrows Escape',
        subtitle: 'Slide arrows to escape the grid',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/545/545682.png',
        backgroundColor: const Color(0xFFEAF4FF),
        onTap: () => _openGame(
          context,
          'Arrows Escape',
          'https://cdn-icons-png.flaticon.com/512/545/545682.png',
          const ArrowsEscapePage(),
        ),
      ),
      // GameCardData(
      //   title: 'Park Master',
      //   subtitle: '',
      //   imageUrl: 'assets/sortie/sortie_thumbnail.webp',
      //   backgroundColor: const Color(0xFFE8F0FF),
      //   onTap: () => _openGame(context, 'pack_pal', WebparkMasterPalStub()),
      // ),
      GameCardData(
        title: 'Garden Gulp',
        subtitle: 'Solve the tile puzzles',
        imageUrl: 'assets/garden_gulp/garden_gulp_thumbnail.webp',
        backgroundColor: const Color(0xFFFFF8E7),
        onTap: () => _openGame(
          context,
          'Garden Gulp',
          'assets/garden_gulp/garden_gulp_thumbnail.webp',
          WebGardenGulp(),
        ),
      ),
      GameCardData(
        title: 'Cozy Tiles',
        subtitle: 'Solve the tile puzzles',
        imageUrl: 'assets/cozy_tiles/cozy_tiles_thumbnail.webp',
        backgroundColor: const Color(0xFFFFF8E7),
        onTap: () => _openGame(
          context,
          'Cozy Tiles',
          'assets/cozy_tiles/cozy_tiles_thumbnail.webp',
          WebCozyTiles(),
        ),
      ),

      GameCardData(
        title: 'Liquid Sort',
        subtitle: 'Sort the colored liquids',
        imageUrl: 'assets/liquid_sort/liquid_sort_thumnail.webp',
        backgroundColor: const Color(0xFFFFF8E7),
        onTap: () => _openGame(
          context,
          'Liquid Sort',
          'assets/liquid_sort/liquid_sort_thumnail.webp',
          WebLiquidSort(),
        ),
      ),
      GameCardData(
        title: 'Evolution Merge',
        subtitle: 'Merge and evolve creatures',
        imageUrl: 'assets/evolution_merge/evolution_merge_thumbnail.webp',
        backgroundColor: const Color(0xFFE8F0FF),
        onTap: () => _openGame(
          context,
          'Evolution Merge',
          'assets/evolution_merge/evolution_merge_thumbnail.webp',
          WebEvolutionMerge(),
        ),
      ),
      GameCardData(
        title: 'Wood Block Puzzle',
        subtitle: 'Classic block puzzle game',
        imageUrl: 'assets/wood_block_puzzle/wood_block_puzzle_thumbnail.webp',
        backgroundColor: const Color(0xFFFFF8E7),
        onTap: () => _openGame(
          context,
          'Wood Block Puzzle',
          'assets/wood_block_puzzle/wood_block_puzzle_thumbnail.webp',
          WebWebWoodBlockPuzzle(),
        ),
      ),
      GameCardData(
        title: 'Sortie',
        subtitle: 'Space adventure game',
        imageUrl: 'assets/sortie/sortie_thumbnail.webp',
        backgroundColor: const Color(0xFFE8F0FF),
        onTap: () => _openGame(
          context,
          'Sortie',
          'assets/sortie/sortie_thumbnail.webp',
          WebSortiePalStub(),
        ),
      ),
      GameCardData(
        title: loc.gameQuantumTitle,
        subtitle: loc.gameQuantumSubtitle,
        imageUrl: 'assets/quantum_link/quantum_link_thumbnail.webp',
        backgroundColor: const Color(0xFFE8F0FF),
        onTap: () => _openGame(
          context,
          loc.gameQuantumTitle,
          'assets/quantum_link/quantum_link_thumbnail.webp',
          WebQuantumLinkStub(),
        ),
      ),
      GameCardData(
        title: loc.gamePackPalTitle,
        subtitle: loc.gamePackPalSubtitle,
        imageUrl: 'assets/pack_pal/pack_pal_thumbnail.webp',
        backgroundColor: const Color(0xFFE8F0FF),
        onTap: () => _openGame(
          context,
          loc.gamePackPalTitle,
          'assets/pack_pal/pack_pal_thumbnail.webp',
          WebPackPalStub(),
        ),
      ),
      GameCardData(
        title: loc.gamePikachuTitle,
        subtitle: loc.gamePikachuSubtitle,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2436/2436636.png',
        backgroundColor: const Color(0xFFFFF8E7),
        onTap: () =>
            _openGame(context, 'Connect Point', '', PikachuConnectGamePage()),
      ),
      GameCardData(
        title: loc.gameTetrisTitle,
        subtitle: loc.gameTetrisSubtitle,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3612/3612569.png',
        backgroundColor: const Color(0xFFFFF0E8),
        onTap: () => _openGame(context, 'Tetris', '', TetrisGameScreen()),
      ),
      // GameCardData(
      //   title: loc.gamePacmanTitle,
      //   subtitle: loc.gamePacmanSubtitle,
      //   imageUrl: 'https://cdn-icons-png.flaticon.com/512/8583/8583893.png',
      //   backgroundColor: const Color(0xFFE8F4F8),
      //   onTap: () => _openGame(context, 'pacman', GamePacman()),
      // ),
      GameCardData(
        title: loc.game2048Title,
        subtitle: loc.game2048Subtitle,
        imageUrl: 'assets/images/2048_thumnail.webp',
        backgroundColor: const Color(0xFFFFF5E6),
        onTap: () => _openGame(
          context,
          loc.game2048Title,
          'assets/images/2048_thumnail.webp',
          Game(),
        ),
      ),
      GameCardData(
        title: loc.gameWordTitle,
        subtitle: loc.gameWordSubtitle,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3898/3898082.png',
        backgroundColor: const Color(0xFFFFF8E7),
        onTap: () => _openGame(context, 'word_puzzle', '', SelectWidget()),
      ),
      GameCardData(
        title: loc.gameDuckTitle,
        subtitle: loc.gameDuckSubtitle,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2436/2436891.png',
        backgroundColor: const Color(0xFFE8F0FF),
        onTap: () => _openGame(context, loc.gameDuckTitle, '', WebDuckWar()),
      ),
      GameCardData(
        title: loc.gameCircuitTitle,
        subtitle: loc.gameCircuitSubtitle,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/564/564619.png',
        backgroundColor: const Color(0xFFE8F0FF),
        onTap: () => _openGame(
          context,
          loc.gameCircuitTitle,
          '',
          WebCircuitConnectStub(),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return _buildGameCard(context, games[index]);
      },
    );
  }

  void _openGame(
    BuildContext context,
    String eventName,
    String image,
    Widget page,
  ) {
    HapticFeedback.lightImpact();
    if (Platform.isAndroid) {
      FirebaseAnalytics.instance.logEvent(name: 'open_${eventName}_game');
    }
    // measure open-game flow (includes ad display and navigation)
    final openId = UsageService.instance.start(
      UsageType.openGame,
      eventName,
      meta: {'eventName': eventName, 'image': image},
    );

    serviceLocator.get<AdmobController>().showInterstitialAd(
      callback: (isSuccess) async {
        // record that ad was shown (or attempted)

        Navigator.push(context, createRouter(page)).then(
          (_) => UsageService.instance.stop(
            openId,
            extraMeta: {'ad_shown': isSuccess},
          ),
        );
      },
    );
  }

  Widget _buildGameCard(BuildContext context, GameCardData game) {
    return AnimatedScaleButton(
      onPressed: game.onTap,
      pressedScale: 0.96,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: game.backgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: Padding(
                        padding: game.imageUrl.contains('webp')
                            ? EdgeInsets.zero
                            : const EdgeInsets.all(20),
                        child:
                            !game.imageUrl.contains('https://') &&
                                game.imageUrl.contains('assets/')
                            ? Image.asset(
                                game.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                width: double.infinity,
                                game.imageUrl,
                                fit: game.imageUrl.contains('webp')
                                    ? BoxFit.cover
                                    : BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.gamepad,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                // Text Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        game.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Play Button
            Positioned(
              right: 12,
              bottom: 50,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBD74C),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBD74C).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black87,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameCardData {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color backgroundColor;
  final VoidCallback onTap;

  GameCardData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.onTap,
  });
}
