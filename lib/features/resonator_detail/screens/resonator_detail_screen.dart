import 'package:evc/core/providers/compare_context_provider.dart';
import 'package:evc/core/providers/notification_provider.dart';
import 'package:evc/features/resonator_detail/providers/detail_provider.dart';
import 'package:evc/presentation/widgets/echo_cards_row.dart';
import 'package:evc/presentation/widgets/loading_action_button.dart';
import 'package:evc/presentation/widgets/reset_resonator_button.dart';
import 'package:evc/presentation/widgets/resonator_header.dart';
import 'package:evc/presentation/widgets/result_chips.dart';
import 'package:evc/presentation/widgets/team_row.dart';
import 'package:flutter/material.dart';
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

  /// Schedule clearing notification fields from state after the current frame,
  /// so the same message can fire again on the next submit and won't replay
  /// when the screen is recreated (e.g. navigating away and back).
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

    _maybeShowSuccess(state.successMessage);
    _maybeShowError(state.error);

    return Scaffold(
      appBar: AppBar(title: const Text('Echo Build')),
      body: SingleChildScrollView(
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
                          child: ResonatorHeader(resonator: notifier.resonator),
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
                      erController: TextEditingController(
                        text: state.totalER.toString(),
                      ),
                      onERChanged: (v) => notifier.setTotalER(v),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            LoadingActionButton(
              loading: state.loading,
              onPressed: () => notifier.submit(),
              icon: const Icon(Icons.send),
              text: 'Submit',
            ),
            const SizedBox(width: 12),
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
