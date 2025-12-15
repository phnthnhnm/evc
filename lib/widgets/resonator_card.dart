import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/resonator.dart';
import '../utils/resonator_utils.dart';
import '../utils/theme_provider.dart';
import '../utils/tier_color_utils.dart';

class ResonatorCard extends StatefulWidget {
  final Resonator resonator;
  final VoidCallback onTap;

  const ResonatorCard({
    super.key,
    required this.resonator,
    required this.onTap,
  });

  @override
  State<ResonatorCard> createState() => _ResonatorCardState();
}

class _ResonatorCardState extends State<ResonatorCard> {
  bool _hovering = false;

  @override
  @override
  Widget build(BuildContext context) {
    const double cardWidth = 240;
    const double portraitHeight = 360;
    const double starsBarHeight = 6;
    const double nameBarHeight = 34;
    const double cardHeight = portraitHeight + starsBarHeight + nameBarHeight;

    // Get overall score from savedEchoSet, if available
    final double? overallScore = widget.resonator.savedEchoSet?.overallScore;
    final String? overallTier = widget.resonator.savedEchoSet?.overallTier;
    final Color scoreColor = overallTier != null
        ? getTierColor(overallTier)
        : Colors.grey;

    // Check if score display is enabled
    final showScore = Provider.of<ThemeProvider>(context).showScoreOnCard;

    // Animation values
    final double scale = _hovering ? 1.22 : 1.14;
    final double brightness = _hovering ? 1.05 : 1.0;
    final double shadowBlur = _hovering ? 22 : 8;
    final double shadowSpread = _hovering ? 10 : 2;
    final double shadowAlpha = _hovering ? 0.55 : 0.25;
    final Color baseBg = const Color(0xFF181A20);
    final Color hoverBg = const Color(0xFF202228);
    final Color bgColor = _hovering ? hoverBg : baseBg;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withValues(alpha: _hovering ? 0.10 : 0.0),
                blurRadius: _hovering ? 32 : 0,
                spreadRadius: _hovering ? 8 : 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: shadowAlpha),
                blurRadius: shadowBlur,
                offset: const Offset(0, 4),
                spreadRadius: shadowSpread,
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
                      child: AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(<double>[
                            brightness,
                            0,
                            0,
                            0,
                            0,
                            0,
                            brightness,
                            0,
                            0,
                            0,
                            0,
                            0,
                            brightness,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: Image.asset(
                            widget.resonator.portraitAsset,
                            fit: BoxFit.cover,
                            width: cardWidth,
                            height: portraitHeight,
                          ),
                        ),
                      ),
                    ),
                    // Top left: overall score chip
                    if (showScore)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: scoreColor, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //Icon(Icons.star, color: scoreColor, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                overallScore != null && overallScore > 0
                                    ? overallScore.toStringAsFixed(1)
                                    : '—',
                                style: TextStyle(
                                  color: scoreColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
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
                            message: attributeLabel(widget.resonator.attribute),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: getAttributeBackgroundColor(
                                  widget.resonator.attribute,
                                ).withValues(alpha: 0.8),
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                attributeAsset(widget.resonator.attribute),
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Tooltip(
                            message: weaponLabel(widget.resonator.weapon),
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
                                weaponAsset(widget.resonator.weapon),
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
                            color: getStarColor(
                              widget.resonator.stars,
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
                      color: getStarColor(widget.resonator.stars),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ],
              ),
              Container(
                width: cardWidth,
                height: nameBarHeight,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.resonator.name,
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
      ),
    );
  }
}
