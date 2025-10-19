import 'package:flutter/material.dart';

import '../models/resonator.dart';

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
    // Card size
    const double cardWidth = 240;
    const double portraitHeight = 360;
    const double starsBarHeight = 6;
    const double nameBarHeight = 40;
    const double cardHeight = portraitHeight + starsBarHeight + nameBarHeight;
    // Bar color by stars
    Color getStarBarColor(int stars) {
      if (stars == 5) return const Color(0xFFFFD700); // Gold
      if (stars == 4) return const Color(0xFFB266FF); // Purple
      return Colors.grey.shade700;
    }

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
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Portrait
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
                    child: Image.asset(
                      resonator.portraitAsset,
                      fit: BoxFit.cover,
                      width: cardWidth,
                      height: portraitHeight,
                    ),
                  ),
                  // Top right: attribute & weapon icons
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: attributeLabel(resonator.attribute),
                            child: Image.asset(
                              attributeAsset(resonator.attribute),
                              width: 28,
                              height: 28,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: weaponLabel(resonator.weapon),
                            child: Image.asset(
                              weaponAsset(resonator.weapon),
                              width: 28,
                              height: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Stars bar
            Container(
              width: cardWidth,
              height: starsBarHeight,
              decoration: BoxDecoration(
                color: getStarBarColor(resonator.stars),
                borderRadius: BorderRadius.zero,
              ),
            ),
            // Name bar
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
