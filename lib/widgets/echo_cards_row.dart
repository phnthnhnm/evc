import 'package:flutter/material.dart';

import '../models/character.dart';
import '../widgets/echo_card.dart';

class EchoCardsRow extends StatelessWidget {
  final Character character;
  final List<Map<String, double>> echoStats;
  final dynamic lastResult;
  final void Function(int, dynamic, double) onStatChanged;
  const EchoCardsRow({
    super.key,
    required this.character,
    required this.echoStats,
    required this.lastResult,
    required this.onStatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: EchoCard(
              index: i,
              character: character,
              lastResult: lastResult,
              echoStats: echoStats[i],
              onStatChanged: (stat, value) => onStatChanged(i, stat, value),
            ),
          ),
        ),
      ),
    );
  }
}
