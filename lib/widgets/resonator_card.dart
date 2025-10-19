import 'package:flutter/material.dart';

import '../models/resonator.dart';
import '../utils/resonator_utils.dart';

class ResonatorCard extends StatelessWidget {
  final Resonator resonator;
  final VoidCallback onTap;

  const ResonatorCard({
    super.key,
    required this.resonator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 240;
    const double portraitHeight = 360;
    const double starsBarHeight = 6;
    const double nameBarHeight = 34;
    const double cardHeight = portraitHeight + starsBarHeight + nameBarHeight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF181A20),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              width: cardWidth,
              height: portraitHeight,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: Transform.scale(
                      scale: 1.14, // Zoom in
                      child: Image.asset(
                        resonator.portraitAsset,
                        fit: BoxFit.cover,
                        width: cardWidth,
                        height: portraitHeight,
                      ),
                    ),
                  ),
                  // Top right: attribute & weapon icons with circular backgrounds
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: attributeLabel(resonator.attribute),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getAttributeBackgroundColor(
                                resonator.attribute,
                              ).withValues(alpha: 0.8),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              attributeAsset(resonator.attribute),
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Tooltip(
                          message: weaponLabel(resonator.weapon),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(
                                0xFF3A3F44,
                              ).withValues(alpha: 0.7),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              weaponAsset(resonator.weapon),
                              width: 28,
                              height: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    width: cardWidth,
                    height: starsBarHeight + 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: getStarBarColor(
                            resonator.stars,
                          ).withValues(alpha: 0.7),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: cardWidth,
                  height: starsBarHeight,
                  decoration: BoxDecoration(
                    color: getStarBarColor(resonator.stars),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ],
            ),
            Container(
              width: cardWidth,
              height: nameBarHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.88),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                resonator.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFCBD5E1),
                  letterSpacing: 0.04,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
