import 'package:flutter/material.dart';
import '../data/models.dart';

class PikachuTileWidget extends StatelessWidget {
  final PikachuTile tile;
  final bool selected;
  final TileStyle style;
  final VoidCallback? onTap;

  const PikachuTileWidget({
    super.key,
    required this.tile,
    required this.selected,
    required this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return const SizedBox();
    }
    final color = style.colorFor(tile.type);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.yellowAccent : Colors.black26,
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [const BoxShadow(color: Colors.yellow, blurRadius: 6)]
              : const [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        alignment: Alignment.center,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (style.iconBuilder != null) {
      final icon = style.iconBuilder!(context, tile.type);
      return icon;
    }
    return Text(
      '${tile.type}',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
