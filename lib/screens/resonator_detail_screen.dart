import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stat.dart';
import '../models/echo.dart';
import '../models/resonator.dart';
import '../services/api_service.dart';
import '../utils/echo_set_provider.dart';
import '../utils/toast_utils.dart';
import '../widgets/echo_cards_row.dart';
import '../widgets/energy_buff_row.dart';
import '../widgets/loading_action_button.dart';
import '../widgets/reset_resonator_button.dart';
import '../widgets/resonator_header.dart';
import '../widgets/result_chips.dart';
import 'echo_compare_screen.dart';

class ResonatorDetailScreen extends StatefulWidget {
  final Resonator resonator;
  final EchoSet? savedEchoSet;
  const ResonatorDetailScreen({
    super.key,
    required this.resonator,
    this.savedEchoSet,
  });

  @override
  State<ResonatorDetailScreen> createState() => _ResonatorDetailScreenState();
}

class _ResonatorDetailScreenState extends State<ResonatorDetailScreen> {
  String energyBuff = 'None'; // None, Yangyang, Zhezhi
  double totalER = 100.0;
  late TextEditingController erController;
  late List<Map<String, double>> echoStats;
  bool loading = false;
  EchoSet? lastResult;
  String? error;

  Future<void> _resetResonatorData() async {
    setState(() {
      energyBuff = 'None';
      totalER = 100.0;
      erController.text = '100.0';
      echoStats = List.generate(5, (_) => <String, double>{});
      lastResult = null;
      error = null;
    });
    final echoSetProvider = Provider.of<EchoSetProvider>(
      context,
      listen: false,
    );
    await echoSetProvider.deleteEchoSet(widget.resonator.id);
    if (!mounted) return;
    showTopRightToast(context, 'Resonator data deleted!');
  }

  @override
  void initState() {
    super.initState();
    erController = TextEditingController(text: totalER.toString());
    echoStats = List.generate(5, (_) => <String, double>{});
    erController.addListener(_onERTextChanged);
    if (widget.savedEchoSet != null) {
      lastResult = widget.savedEchoSet;
      energyBuff = widget.savedEchoSet!.energyBuff;
      totalER = widget.savedEchoSet!.totalER;
      erController.text = widget.savedEchoSet!.totalER.toString();
      for (int i = 0; i < 5; i++) {
        echoStats[i] = Map<String, double>.from(
          widget.savedEchoSet!.echoes[i].stats,
        );
      }
    } else {
      _loadSaved();
    }
  }

  void _onERTextChanged() {
    final parsed = double.tryParse(erController.text);
    if (parsed != null && parsed != totalER) {
      setState(() {
        totalER = parsed;
      });
    }
  }

  Future<void> _loadSaved() async {
    final echoSetProvider = Provider.of<EchoSetProvider>(
      context,
      listen: false,
    );
    await echoSetProvider.loadEchoSet(widget.resonator.id);
    if (!mounted) return;
    final saved = echoSetProvider.getEchoSet(widget.resonator.id);
    if (saved != null) {
      setState(() {
        lastResult = saved;
        energyBuff = saved.energyBuff;
        totalER = saved.totalER;
        erController.text = saved.totalER.toString();
        for (int i = 0; i < 5; i++) {
          echoStats[i] = Map<String, double>.from(saved.echoes[i].stats);
        }
      });
    }
  }

  void _setStatValue(int echoIndex, Stat stat, double value) {
    final key = '${statApiNames[stat]} ${echoIndex + 1}';
    setState(() {
      if (value == 0.0) {
        echoStats[echoIndex].remove(key);
      } else {
        echoStats[echoIndex][key] = value;
      }
    });
  }

  Future<void> _submit() async {
    final overLimitIndices = <int>[];
    for (int i = 0; i < echoStats.length; i++) {
      if (echoStats[i].length > 5) overLimitIndices.add(i + 1);
    }
    if (overLimitIndices.isNotEmpty) {
      final echoList = overLimitIndices.join(', ');
      showTopRightToast(
        context,
        'Error: Echo${overLimitIndices.length > 1 ? 'es' : ''} $echoList have more than 5 stats. Please remove extra stats.',
      );
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    final cleanedEchoStats = echoStats
        .map(
          (stats) =>
              Map<String, double>.from(stats)..removeWhere((k, v) => v == 0.0),
        )
        .toList();
    final echoSetProvider = Provider.of<EchoSetProvider>(
      context,
      listen: false,
    );
    try {
      final result = await ApiService.submit(
        energyBuff: energyBuff,
        resonatorName: widget.resonator.name,
        totalER: totalER,
        echoStatsList: cleanedEchoStats,
      );
      await echoSetProvider.saveEchoSet(widget.resonator.id, result);
      if (!mounted) return;
      setState(() {
        lastResult = result;
      });
      showTopRightToast(context, 'Submitted and saved!');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    erController.removeListener(_onERTextChanged);
    erController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EchoSetProvider>(
      builder: (context, echoSetProvider, _) {
        final saved = echoSetProvider.getEchoSet(widget.resonator.id);
        final effectiveLastResult = saved ?? lastResult;
        final showResult = effectiveLastResult != null;
        final displayEchoStats = showResult
            ? List.generate(
                5,
                (i) => Map<String, double>.from(
                  effectiveLastResult.echoes[i].stats,
                ),
              )
            : echoStats;

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
                              child: ResonatorHeader(
                                resonator: widget.resonator,
                              ),
                            ),
                            ResetResonatorButton(
                              onReset: _resetResonatorData,
                              label: 'Reset',
                              icon: Icons.refresh,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        EnergyBuffRow(
                          energyBuff: energyBuff,
                          onBuffChanged: (v) =>
                              setState(() => energyBuff = v ?? 'None'),
                          erController: erController,
                          onERChanged: (v) => setState(() => totalER = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                EchoCardsRow(
                  resonator: widget.resonator,
                  echoStats: showResult ? echoStats : displayEchoStats,
                  lastResult: effectiveLastResult,
                  onStatChanged: (i, stat, value) =>
                      _setStatValue(i, stat, value),
                  onCompare: (i) async {
                    if (effectiveLastResult == null) return;
                    final echo = effectiveLastResult.echoes[i];
                    final result = await Navigator.of(context).push<EchoSet>(
                      MaterialPageRoute(
                        builder: (context) => EchoCompareScreen(
                          resonator: widget.resonator,
                          currentEcho: echo,
                          echoIndex: i,
                          lastResult: effectiveLastResult,
                        ),
                      ),
                    );
                    if (result != null) {
                      await echoSetProvider.loadEchoSet(widget.resonator.id);
                      setState(() {
                        for (int idx = 0; idx < 5; idx++) {
                          echoStats[idx] = Map<String, double>.from(
                            result.echoes[idx].stats,
                          );
                        }
                        lastResult = result;
                      });
                    }
                  },
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                LoadingActionButton(
                  loading: loading,
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  text: 'Submit',
                ),
                const SizedBox(width: 12),
                const Spacer(),
                ResultChips(
                  overallScore: effectiveLastResult?.overallScore ?? 0.0,
                  overallTier: effectiveLastResult?.overallTier ?? 'Unbuilt',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
