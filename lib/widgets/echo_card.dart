import 'package:flutter/material.dart';

import '../data/stat.dart';
import '../models/echo.dart';
import '../models/resonator.dart';
import '../utils/tier_color_utils.dart';
import '../widgets/stat_dropdown.dart';

class EchoCard extends StatelessWidget {
  final int index;
  final Resonator resonator;
  final EchoSet? lastResult;
  final Map<String, double> echoStats;
  final void Function(Stat stat, double value) onStatChanged;
  final VoidCallback? onCompare;
  final String? customTitle;

  const EchoCard({
    super.key,
    required this.index,
    required this.resonator,
    required this.lastResult,
    required this.echoStats,
    required this.onStatChanged,
    this.onCompare,
    this.customTitle,
  });

  double _getSelected(Stat stat) {
    final key = '${statApiNames[stat]} ${index + 1}';
    return echoStats[key] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final usable = resonator.usableStats;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    customTitle ?? 'Echo ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onCompare != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onCompare,
                      child: const Text('Compare'),
                    ),
                  ),
              ],
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
                    label: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Score: ',
                            style: Theme.of(context).chipTheme.labelStyle,
                          ),
                          TextSpan(
                            text: '${lastResult!.echoes[index].score}',
                            style:
                                (Theme.of(
                                  context,
                                ).chipTheme.labelStyle?.copyWith(
                                  color: getTierColor(
                                    lastResult!.echoes[index].tier,
                                  ),
                                )) ??
                                TextStyle(
                                  color: getTierColor(
                                    lastResult!.echoes[index].tier,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    avatar: const Icon(Icons.star),
                  ),
                  SizedBox(height: 8),
                  Chip(
                    label: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Tier: ',
                            style: Theme.of(context).chipTheme.labelStyle,
                          ),
                          TextSpan(
                            text: lastResult!.echoes[index].tier,
                            style:
                                (Theme.of(
                                  context,
                                ).chipTheme.labelStyle?.copyWith(
                                  color: getTierColor(
                                    lastResult!.echoes[index].tier,
                                  ),
                                )) ??
                                TextStyle(
                                  color: getTierColor(
                                    lastResult!.echoes[index].tier,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
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
