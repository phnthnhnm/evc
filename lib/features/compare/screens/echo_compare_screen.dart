import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:evc/core/providers/compare_context_provider.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/features/compare/providers/compare_provider.dart';
import 'package:evc/features/resonator_detail/providers/detail_provider.dart';
import 'package:evc/presentation/theme/app_colors.dart';
import 'package:evc/presentation/widgets/comparison_sign.dart';
import 'package:evc/presentation/widgets/echo_card.dart';
import 'package:evc/presentation/widgets/loading_action_button.dart';
import 'package:evc/presentation/widgets/total_er_input_field.dart';

class EchoCompareScreen extends ConsumerStatefulWidget {
  final String resonatorId;
  final int echoIndex;

  const EchoCompareScreen({
    super.key,
    required this.resonatorId,
    required this.echoIndex,
  });

  @override
  ConsumerState<EchoCompareScreen> createState() =>
      _EchoCompareScreenState();
}

class _EchoCompareScreenState extends ConsumerState<EchoCompareScreen> {
  late final TextEditingController _erController;

  @override
  void initState() {
    super.initState();
    final ctx = ref.read(compareContextProvider);
    if (ctx == null) {
      // Missing context — pop back
      Future.microtask(() {
        if (mounted) context.pop();
      });
    } else {
      ref.read(compareProvider.notifier).init(
            resonatorId: widget.resonatorId,
            echoIndex: widget.echoIndex,
          );
      _erController = TextEditingController(
        text: ctx.lastResult.totalER.toString(),
      );
      ref
          .read(compareProvider.notifier)
          .setTotalER(ctx.lastResult.totalER);
    }
  }

  @override
  void dispose() {
    _erController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctx = ref.watch(compareContextProvider);
    if (ctx == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final state = ref.watch(compareProvider);
    final currentEcho = ctx.lastResult.echoes[widget.echoIndex];

    String compareSign = '';
    if (state.newEchoResult != null) {
      if (currentEcho.score > state.newEchoResult!.score) {
        compareSign = '>';
      } else if (currentEcho.score < state.newEchoResult!.score) {
        compareSign = '<';
      } else {
        compareSign = '=';
      }
    }

    final double oldOverallScore = ctx.lastResult.overallScore;
    final double? newOverallScore =
        (state.submitted) ? state.newEchoSet?.overallScore : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Echoes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Spacer(),
                TotalERInputField(
                  controller: _erController,
                  onChanged: (v) {
                    ref.read(compareProvider.notifier).setTotalER(v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(
                            label: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Overall Score: '),
                                  TextSpan(
                                    text: oldOverallScore.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: AppColors.tierColor(
                                          ctx.lastResult.overallTier),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            avatar: const Icon(Icons.emoji_events),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Overall Tier: '),
                                  TextSpan(
                                    text: ctx.lastResult.overallTier,
                                    style: TextStyle(
                                      color: AppColors.tierColor(
                                          ctx.lastResult.overallTier),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            avatar: const Icon(Icons.workspace_premium),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(
                            label: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Overall Score: '),
                                  TextSpan(
                                    text: newOverallScore != null
                                        ? newOverallScore.toStringAsFixed(2)
                                        : '--',
                                    style: TextStyle(
                                      color: AppColors.tierColor(
                                          state.newEchoSet?.overallTier ??
                                              'Unbuilt'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            avatar: const Icon(Icons.emoji_events),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Overall Tier: '),
                                  TextSpan(
                                    text: state.newEchoSet?.overallTier ??
                                        '--',
                                    style: TextStyle(
                                      color: AppColors.tierColor(
                                          state.newEchoSet?.overallTier ??
                                              'Unbuilt'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            avatar: const Icon(Icons.workspace_premium),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: EchoCard(
                      index: 0,
                      resonator: ctx.resonator,
                      lastResult: EchoSet(
                        echoes: [currentEcho],
                        overallScore: currentEcho.score,
                        overallTier: currentEcho.tier,
                        totalER: 0.0,
                      ),
                      echoStats: {
                        for (final entry
                            in currentEcho.stats.entries)
                          entry.key.replaceAll(RegExp(r' \d+$'), ' 1'):
                              entry.value,
                      },
                      onStatChanged: (_, _) {},
                      customTitle: 'Current Echo',
                      showCompareButton: false,
                    ),
                  ),
                  SizedBox(
                      width: 96,
                      child: ComparisonSign(sign: compareSign)),
                  Expanded(
                    child: EchoCard(
                      index: 0,
                      resonator: ctx.resonator,
                      lastResult: state.newEchoResult != null
                          ? EchoSet(
                              echoes: [state.newEchoResult!],
                              overallScore: state.newEchoResult!.score,
                              overallTier: state.newEchoResult!.tier,
                              totalER: 0.0,
                            )
                          : null,
                      echoStats: state.newEchoStats,
                      onStatChanged: (stat, value) {
                        ref
                            .read(compareProvider.notifier)
                            .setStatValue(stat, value);
                      },
                      customTitle: 'New Echo',
                      showCompareButton: false,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingActionButton(
                      loading: state.loading,
                      onPressed: () {
                        ref
                            .read(compareProvider.notifier)
                            .submit(ctx.lastResult);
                      },
                      icon: const Icon(Icons.compare_arrows),
                      text:
                          state.submitted ? 'Compare Again' : 'Compare',
                    ),
                    if (state.showReplaceButton &&
                        state.newEchoResult != null &&
                        state.newEchoResult!.tier != 'Error')
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Replace with New Echo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimary,
                          ),
                          onPressed: () async {
                            final result = await ref
                                .read(compareProvider.notifier)
                                .replaceOldEchoWithNew(ctx.lastResult);
                            ref
                                .read(resonatorDetailProvider(
                                        widget.resonatorId)
                                    .notifier)
                                .applyCompareResult(result);
                            if (mounted) context.pop();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
