import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/domain/models/resonator.dart';
import 'package:evc/presentation/theme/app_colors.dart';
import 'package:evc/presentation/widgets/stat_dropdown.dart';
import 'package:flutter/material.dart';

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

  int get _nonZeroStatCount {
    var count = 0;
    for (final stat in resonator.usableStats) {
      final key = '${stat.apiName} ${index + 1}';
      if ((echoStats[key] ?? 0.0) != 0.0) count++;
    }
    return count;
  }

  bool get _hasTooManyStats => _nonZeroStatCount > 5;

  /// Damage split percentage badge for a stat, or null if not a damage stat,
  /// no split data, or the value is zero. Color intensity scales with the
  /// value's importance relative to the most dominant damage type.
  Widget? _buildDamageBadge(Stat stat, BuildContext context) {
    final split = resonator.damageSplit;
    if (split == null) return null;
    final key = switch (stat) {
      Stat.basicPercent => 'basic',
      Stat.heavyPercent => 'heavy',
      Stat.skillPercent => 'skill',
      Stat.liberationPercent => 'liberation',
      _ => null,
    };
    if (key == null) return null;
    final value = split[key];
    if (value == null || value == 0.0) return null;

    // Find the dominant damage type for relative scaling.
    final maxSplit = [
      split['basic'] ?? 0,
      split['heavy'] ?? 0,
      split['skill'] ?? 0,
      split['liberation'] ?? 0,
    ].reduce((a, b) => a > b ? a : b);

    final ratio = maxSplit > 0 ? value / maxSplit : 0.0;
    final pct = '${(value * 100).toStringAsFixed(0)}%';
    final scheme = Theme.of(context).colorScheme;

    // Dominant stat gets full prominence; others are proportionally subdued.
    final isDominant = ratio >= 0.95;
    final bgAlpha = isDominant ? 200 : (60 + (ratio * 140)).round();
    final fgColor = isDominant ? scheme.onPrimary : scheme.primary;

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.primary.withAlpha(bgAlpha),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        pct,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fgColor,
          height: 1.2,
        ),
      ),
    );

    return Tooltip(
      message: '~$pct of damage per rotation comes from ${stat.label}',
      child: badge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usable = resonator.usableStats;
    final tooMany = _hasTooManyStats;
    return Card(
      elevation: 1,
      shape: tooMany
          ? RoundedRectangleBorder(
              side: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (tooMany)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Tooltip(
                      message:
                          'This echo has $_nonZeroStatCount non-zero stats '
                          '(max 5).',
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    customTitle ?? 'Echo ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: tooMany ? Colors.redAccent : null,
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
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
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
                final damageBadge = _buildDamageBadge(stat, context);
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
                            child: Row(
                              children: [
                                Text(
                                  stat.label,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                                if (damageBadge != null) ...[
                                  const SizedBox(width: 6),
                                  damageBadge,
                                ],
                              ],
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
                          style:
                              (Theme.of(context).chipTheme.labelStyle?.copyWith(
                                color: AppColors.tierColor(
                                  lastResult != null
                                      ? lastResult!.echoes[index].tier
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
                          style:
                              (Theme.of(context).chipTheme.labelStyle?.copyWith(
                                color: AppColors.tierColor(
                                  lastResult != null
                                      ? lastResult!.echoes[index].tier
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
