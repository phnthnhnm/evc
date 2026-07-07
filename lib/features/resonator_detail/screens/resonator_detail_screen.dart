import 'package:evc/core/providers/compare_context_provider.dart';
import 'package:evc/core/providers/notification_provider.dart';
import 'package:evc/features/resonator_detail/providers/adjacent_resonator_provider.dart';
import 'package:evc/features/resonator_detail/providers/detail_provider.dart';
import 'package:evc/presentation/widgets/echo_cards_row.dart';
import 'package:evc/presentation/widgets/loading_action_button.dart';
import 'package:evc/presentation/widgets/reset_resonator_button.dart';
import 'package:evc/presentation/widgets/resonator_header.dart';
import 'package:evc/presentation/widgets/result_chips.dart';
import 'package:evc/presentation/widgets/team_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResonatorDetailScreen extends ConsumerStatefulWidget {
  final String resonatorId;

  const ResonatorDetailScreen({super.key, required this.resonatorId});

  @override
  ConsumerState<ResonatorDetailScreen> createState() =>
      _ResonatorDetailScreenState();
}

class _ResonatorDetailScreenState extends ConsumerState<ResonatorDetailScreen> {
  String? _lastSuccessMessage;
  String? _lastErrorMessage;
  bool _scheduledClear = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _erController;
  bool _syncingER = false;
  ResonatorDetailNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    _erController = TextEditingController(text: '100.0');
    _erController.addListener(() {
      if (_syncingER) return;
      final parsed = double.tryParse(_erController.text);
      if (parsed != null) {
        ref
            .read(resonatorDetailProvider(widget.resonatorId).notifier)
            .setTotalER(parsed);
      }
    });
  }

  @override
  void didUpdateWidget(ResonatorDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resonatorId != widget.resonatorId) {
      _scrollController.jumpTo(0);
      final oldNotifier = _notifier;
      Future(() => oldNotifier?.revertToDefaults());
    }
  }

  @override
  void dispose() {
    _erController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    Future(() => _notifier?.revertToDefaults());
    super.dispose();
  }

  void _maybeShowSuccess(String? message) {
    if (message != null && message != _lastSuccessMessage) {
      _lastSuccessMessage = message;
      ToastNotification.show(ref, message);
      _scheduleClear();
    } else if (message == null) {
      _lastSuccessMessage = null;
    }
  }

  void _maybeShowError(String? message) {
    if (message != null && message != _lastErrorMessage) {
      _lastErrorMessage = message;
      ToastNotification.show(ref, message);
      _scheduleClear();
    } else if (message == null) {
      _lastErrorMessage = null;
    }
  }

  void _scheduleClear() {
    if (_scheduledClear) return;
    _scheduledClear = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledClear = false;
      if (mounted) {
        ref
            .read(resonatorDetailProvider(widget.resonatorId).notifier)
            .clearMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resonatorDetailProvider(widget.resonatorId));
    final notifier = ref.read(
      resonatorDetailProvider(widget.resonatorId).notifier,
    );
    _notifier = notifier;
    final adjacent = ref.watch(adjacentResonatorsProvider(widget.resonatorId));
    final hasPrev = adjacent.previousId != null;
    final hasNext = adjacent.nextId != null;

    final stateER = state.totalER;
    final controllerER = double.tryParse(_erController.text);
    if (controllerER != null && controllerER != stateER) {
      _syncingER = true;
      _erController.text = stateER.toString();
      _syncingER = false;
    }
    final erValid = stateER >= 100.0;

    _maybeShowSuccess(state.successMessage);
    _maybeShowError(state.error);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Echo Build'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Resonator',
            onPressed: hasPrev
                ? () => context.replace('/resonator/${adjacent.previousId}')
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Resonator',
            onPressed: hasNext
                ? () => context.replace('/resonator/${adjacent.nextId}')
                : null,
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (!_focusNode.hasPrimaryFocus) return KeyEventResult.ignored;
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          if (event.logicalKey == LogicalKeyboardKey.arrowLeft && hasPrev) {
            context.replace('/resonator/${adjacent.previousId}');
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight && hasNext) {
            context.replace('/resonator/${adjacent.nextId}');
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Listener(
          behavior: HitTestBehavior.deferToChild,
          onPointerDown: (_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _focusNode.requestFocus();
            });
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ResonatorHeader(
                                resonator: notifier.resonator,
                              ),
                            ),
                            ResetResonatorButton(
                              onReset: () => notifier.reset(),
                              label: 'Reset',
                              icon: Icons.refresh,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TeamRow(
                          selectedTeam: state.selectedTeam,
                          teams: notifier.resonator.effectiveTeams,
                          onTeamChanged: (v) => notifier.setTeam(v),
                          erController: _erController,
                          onERChanged: (_) {},
                          showTeamInfo: true,
                          showERInfo: true,
                          erTarget: notifier.resonator.erTargetForTeam(
                            state.selectedTeam,
                          ),
                          erNotNeeded: notifier.resonator.erNotNeededForTeam(
                            state.selectedTeam,
                          ),
                          currentER: state.totalER,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                EchoCardsRow(
                  resonator: notifier.resonator,
                  echoStats: state.echoStats,
                  lastResult: state.lastResult,
                  onStatChanged: (i, stat, value) =>
                      notifier.setStatValue(i, stat, value),
                  onCompare: (i) {
                    if (state.lastResult == null) return;
                    ref
                        .read(compareContextProvider.notifier)
                        .set(
                          CompareContext(
                            resonator: notifier.resonator,
                            lastResult: state.lastResult!,
                            echoIndex: i,
                          ),
                        );
                    context.push('/resonator/${widget.resonatorId}/compare/$i');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            LoadingActionButton(
              loading: state.loading,
              onPressed: erValid ? () => notifier.submit() : null,
              icon: const Icon(Icons.send),
              text: 'Submit',
            ),
            const SizedBox(width: 12),
            if (!erValid)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'ER must be ≥ 100',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const Spacer(),
            ResultChips(
              overallScore: state.lastResult?.overallScore ?? 0.0,
              overallTier: state.lastResult?.overallTier ?? 'Unbuilt',
            ),
          ],
        ),
      ),
    );
  }
}
