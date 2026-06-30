import 'package:flutter/material.dart';

import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/domain/models/resonator.dart';
import 'package:evc/presentation/theme/app_colors.dart';
import 'package:evc/presentation/widgets/stat_dropdown.dart';

class EchoCard extends StatelessWidget {
  final int index;
  final Resonator resonator;
  final EchoSet? lastResult;
  final Map<String, double> echoStats;
  final void Function(Stat stat, double value) onStatChanged;
  final VoidCallback? onCompare;
  final String? customTitle;
  final bool showCompareButton;

  const EchoCard({
    super.key,
    required this.index,
    required this.resonator,
    required this.lastResult,
    required this.echoStats,
    required this.onStatChanged,
    this.onCompare,
    this.customTitle,
    this.showCompareButton = true,
  });

  double _getSelected(Stat stat) {
    final key = '${stat.apiName} ${index + 1}';
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
                if (onCompare != null && showCompareButton)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: onCompare,
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Compare'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 12,
              children: usable.map((stat) {
                final range = stat.validValues;
                final selected = _getSelected(stat);
                return SizedBox(
                  width: double.infinity,
                  child: StatDropdown(
                    label: Row(
                      children: [
                        Image.asset(
                          stat.assetPath,
                          width: 24,
                          height: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              stat.label,
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
                          text: lastResult != null
                              ? '${lastResult!.echoes[index].score}'
                              : '0.0',
                          style: (Theme.of(context)
                                      .chipTheme
                                      .labelStyle
                                      ?.copyWith(
                                        color: AppColors.tierColor(
                                          lastResult != null
                                              ? lastResult!
                                                  .echoes[index].tier
                                              : 'Unbuilt',
                                        ),
                                      )) ??
                              TextStyle(
                                color: AppColors.tierColor(
                                  lastResult != null
                                      ? lastResult!.echoes[index].tier
                                      : 'Unbuilt',
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  avatar: const Icon(Icons.star),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tier: ',
                          style: Theme.of(context).chipTheme.labelStyle,
                        ),
                        TextSpan(
                          text: lastResult != null
                              ? lastResult!.echoes[index].tier
                              : 'Unbuilt',
                          style: (Theme.of(context)
                                      .chipTheme
                                      .labelStyle
                                      ?.copyWith(
                                        color: AppColors.tierColor(
                                          lastResult != null
                                              ? lastResult!
                                                  .echoes[index].tier
                                              : 'Unbuilt',
                                        ),
                                      )) ??
                              TextStyle(
                                color: AppColors.tierColor(
                                  lastResult != null
                                      ? lastResult!.echoes[index].tier
                                      : 'Unbuilt',
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
