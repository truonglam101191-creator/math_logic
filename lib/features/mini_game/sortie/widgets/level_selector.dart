import 'package:flutter/material.dart';
import 'package:logic_mathematics/features/mini_game/sortie/data/models/game_theme.dart';

/// Level selection bottom sheet
class LevelSelector extends StatelessWidget {
  final int currentLevel;
  final int maxLevels;
  final List<int> unlockedLevels;
  final ValueChanged<int> onLevelSelected;

  const LevelSelector({
    super.key,
    required this.currentLevel,
    required this.maxLevels,
    required this.unlockedLevels,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Level',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Level grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: maxLevels,
              itemBuilder: (context, index) {
                final level = index + 1;
                final isUnlocked = unlockedLevels.contains(level);
                final isCurrent = level == currentLevel;
                final themeName = GameTheme.levelOrder[index];
                final theme = GameTheme.themes[themeName];

                return _LevelTile(
                  level: level,
                  themeName: themeName,
                  themeColor: theme?.backgroundColor ?? Colors.grey,
                  isUnlocked: isUnlocked,
                  isCurrent: isCurrent,
                  onTap: isUnlocked
                      ? () {
                          onLevelSelected(level);
                          Navigator.pop(context);
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Level tile widget
class _LevelTile extends StatelessWidget {
  final int level;
  final String themeName;
  final Color themeColor;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.themeName,
    required this.themeColor,
    required this.isUnlocked,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isCurrent ? themeColor : themeColor.withOpacity(0.7))
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: isCurrent
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: themeColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Level number
              Text(
                level.toString(),
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.grey[500],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Lock icon for locked levels
              if (!isUnlocked)
                const Positioned(
                  right: 4,
                  top: 4,
                  child: Icon(Icons.lock, size: 14, color: Colors.grey),
                ),

              // Theme icon
              Positioned(
                bottom: 4,
                child: Text(
                  _getThemeEmoji(themeName),
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Current indicator
              if (isCurrent)
                const Positioned(
                  right: 4,
                  top: 4,
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeEmoji(String themeName) {
    switch (themeName) {
      case 'medical':
        return '🏥';
      case 'toolbox':
        return '🧰';
      case 'farm':
        return '🌾';
      case 'school':
        return '📚';
      case 'art':
        return '🎨';
      case 'toybox':
        return '🧸';
      case 'kitchen':
        return '🍳';
      case 'backpack':
        return '🎒';
      case 'bathroom':
        return '🚿';
      case 'gardening':
        return '🌻';
      default:
        return '📦';
    }
  }
}

/// Show level selector as bottom sheet
void showLevelSelector(
  BuildContext context, {
  required int currentLevel,
  required int maxLevels,
  required List<int> unlockedLevels,
  required ValueChanged<int> onLevelSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => LevelSelector(
      currentLevel: currentLevel,
      maxLevels: maxLevels,
      unlockedLevels: unlockedLevels,
      onLevelSelected: onLevelSelected,
    ),
  );
}
