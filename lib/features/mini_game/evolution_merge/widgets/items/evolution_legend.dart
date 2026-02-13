import 'package:flutter/material.dart';
import '../../data/data.dart';

/// Widget showing all evolution types in a horizontal strip
class EvolutionLegend extends StatelessWidget {
  final double height;
  final EdgeInsets padding;

  const EvolutionLegend({
    super.key,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.brown.withOpacity(0.1), width: 2),
      ),
      child: Row(
        children: EvolutionTypes.types.map((type) {
          final imageUrl = EvolutionAssetUrls.getImageUrl(type.assetId);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildFallback(type),
                    )
                  : _buildFallback(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFallback(EvolutionType type) {
    return Container(
      decoration: BoxDecoration(
        color: type.fallbackColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          type.name[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
