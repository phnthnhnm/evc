import 'package:flutter/material.dart';

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
          label: Text('Overall Score: $overallScore'),
          avatar: const Icon(Icons.workspace_premium),
        ),
        Chip(
          label: Text('Overall Tier: $overallTier'),
          avatar: const Icon(Icons.emoji_events),
        ),
      ],
    );
  }
}
