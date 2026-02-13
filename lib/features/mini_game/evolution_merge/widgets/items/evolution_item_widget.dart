import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/data.dart';

/// Widget to display an evolution item/creature
class EvolutionItemWidget extends StatelessWidget {
  final int typeIndex;
  final double size;
  final double angle;
  final bool showLabel;

  const EvolutionItemWidget({
    super.key,
    required this.typeIndex,
    required this.size,
    this.angle = 0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final type = EvolutionTypes.getType(typeIndex);
    final imageUrl = EvolutionAssetUrls.getImageUrl(type.assetId);

    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => _buildFallback(type),
                errorWidget: (context, url, error) => _buildFallback(type),
              )
            : _buildFallback(type),
      ),
    );
  }

  Widget _buildFallback(EvolutionType type) {
    return Container(
      decoration: BoxDecoration(
        color: type.fallbackColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: type.fallbackColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showLabel)
              Text(
                type.name,
                style: TextStyle(color: Colors.white70, fontSize: size * 0.12),
              ),
          ],
        ),
      ),
    );
  }
}

/// Animated evolution item for merging effects
class AnimatedEvolutionItem extends StatefulWidget {
  final int typeIndex;
  final double size;
  final VoidCallback? onMergeComplete;

  const AnimatedEvolutionItem({
    super.key,
    required this.typeIndex,
    required this.size,
    this.onMergeComplete,
  });

  @override
  State<AnimatedEvolutionItem> createState() => _AnimatedEvolutionItemState();
}

class _AnimatedEvolutionItemState extends State<AnimatedEvolutionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward().then((_) {
      widget.onMergeComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: EvolutionItemWidget(
        typeIndex: widget.typeIndex,
        size: widget.size,
      ),
    );
  }
}
