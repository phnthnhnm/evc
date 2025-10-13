import 'package:flutter/material.dart';

import '../data/stat.dart';
import '../models/character.dart';
import '../models/echo.dart';
import '../widgets/stat_dropdown.dart';

class EchoCard extends StatelessWidget {
  final int index;
  final Character character;
  final EchoSet? lastResult;
  final Map<String, double> echoStats;
  final void Function(Stat stat, double value) onStatChanged;

  const EchoCard({
    super.key,
    required this.index,
    required this.character,
    required this.lastResult,
    required this.echoStats,
    required this.onStatChanged,
  });

  double _getSelected(Stat stat) {
    final key = '${statApiNames[stat]} ${index + 1}';
    return echoStats[key] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final usable = character.usableStats;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Echo ${index + 1}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 12,
              children: usable.map((stat) {
                final range = statRanges[stat] ?? const [0.0];
                final selected = _getSelected(stat);
                return SizedBox(
                  width: double.infinity,
                  child: StatDropdown(
                    label: Row(
                      children: [
                        Image.asset(
                          statAsset(stat),
                          width: 24,
                          height: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              statLabels[stat] ?? '',
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    values: range,
                    selected: selected,
                    onChanged: (v) => onStatChanged(stat, v),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            if (lastResult != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text('Score: ${lastResult!.echoes[index].score}'),
                    avatar: const Icon(Icons.star),
                  ),
                  SizedBox(height: 8),
                  Chip(
                    label: Text('Tier: ${lastResult!.echoes[index].tier}'),
                    avatar: const Icon(Icons.military_tech),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
