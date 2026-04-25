import 'package:flutter/material.dart';

class PetArtwork extends StatelessWidget {
  static const Set<String> _bundledAssets = {};

  final String name;
  final String spriteUrl;
  final double size;
  final double borderRadius;

  const PetArtwork({
    super.key,
    required this.name,
    required this.spriteUrl,
    this.size = 180,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (_bundledAssets.contains(spriteUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          spriteUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackArtwork(),
        ),
      );
    }

    return _buildFallbackArtwork();
  }

  Widget _buildFallbackArtwork() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8D9D7), Color(0xFFFCEDEA)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            top: size * 0.14,
            right: size * 0.12,
            child: _buildBubble(size * 0.18, 0.22),
          ),
          Positioned(
            bottom: size * 0.16,
            left: size * 0.12,
            child: _buildBubble(size * 0.12, 0.16),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.48,
                  height: size * 0.48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets_rounded,
                    size: size * 0.28,
                    color: const Color(0xFF2E3C2E),
                  ),
                ),
                SizedBox(height: size * 0.08),
                SizedBox(
                  width: size * 0.72,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Color(0xFF5A4A48),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(double bubbleSize, double opacity) {
    return Container(
      width: bubbleSize,
      height: bubbleSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
