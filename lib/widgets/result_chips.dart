import 'package:flutter/material.dart';

import '../utils/tier_color_utils.dart';

class ResultChips extends StatelessWidget {
  final double overallScore;
  final String overallTier;
  const ResultChips({
    super.key,
    required this.overallScore,
    required this.overallTier,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        Chip(
          label: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Overall Score: ',
                  style: Theme.of(context).chipTheme.labelStyle,
                ),
                TextSpan(
                  text: '$overallScore',
                  style:
                      (Theme.of(context).chipTheme.labelStyle?.copyWith(
                        color: getTierColor(overallTier),
                      )) ??
                      TextStyle(color: getTierColor(overallTier)),
                ),
              ],
            ),
          ),
          avatar: const Icon(Icons.workspace_premium),
        ),
        Chip(
          label: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Overall Tier: ',
                  style: Theme.of(context).chipTheme.labelStyle,
                ),
                TextSpan(
                  text: overallTier,
                  style:
                      (Theme.of(context).chipTheme.labelStyle?.copyWith(
                        color: getTierColor(overallTier),
                      )) ??
                      TextStyle(color: getTierColor(overallTier)),
                ),
              ],
            ),
          ),
          avatar: const Icon(Icons.emoji_events),
        ),
      ],
    );
  }
}
