import 'package:flutter/material.dart';

import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/domain/models/resonator.dart';
import 'package:evc/presentation/widgets/echo_card.dart';

class EchoCardsRow extends StatelessWidget {
  final Resonator resonator;
  final List<Map<String, double>> echoStats;
  final EchoSet? lastResult;
  final List<Set<String>> changedEchoKeys;
  final List<Map<String, double>?> baselineStatsList;
  final void Function(int, Stat, double) onStatChanged;
  final void Function(int)? onCompare;

  const EchoCardsRow({
    super.key,
    required this.resonator,
    required this.echoStats,
    required this.lastResult,
    this.changedEchoKeys = const [],
    this.baselineStatsList = const [],
    required this.onStatChanged,
    this.onCompare,
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
              resonator: resonator,
              lastResult: lastResult,
              echoStats: echoStats[i],
              changedStatKeys: changedEchoKeys.length > i
                  ? changedEchoKeys[i]
                  : const {},
              baselineStats: baselineStatsList.length > i
                  ? baselineStatsList[i]
                  : null,
              onStatChanged: (stat, value) => onStatChanged(i, stat, value),
              onCompare: onCompare != null ? () => onCompare!(i) : null,
            ),
          ),
        ),
      ),
    );
  }
}
