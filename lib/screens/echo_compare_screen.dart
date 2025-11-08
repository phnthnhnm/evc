import 'package:flutter/material.dart';

import '../data/stat.dart';
import '../models/echo.dart';
import '../models/resonator.dart';
import '../services/api_service.dart';
import '../widgets/comparison_sign.dart';
import '../widgets/echo_card.dart';
import '../widgets/loading_action_button.dart';
import '../widgets/total_er_input_field.dart';

class EchoCompareScreen extends StatefulWidget {
  final Resonator resonator;
  final Echo currentEcho;
  final int echoIndex;
  final EchoSet lastResult;

  const EchoCompareScreen({
    super.key,
    required this.resonator,
    required this.currentEcho,
    required this.echoIndex,
    required this.lastResult,
  });

  @override
  State<EchoCompareScreen> createState() => _EchoCompareScreenState();
}

class _EchoCompareScreenState extends State<EchoCompareScreen> {
  Map<String, double> newEchoStats = {};
  bool submitted = false;
  bool loading = false;
  Echo? newEchoResult;
  late TextEditingController _erController;
  double _enteredTotalER = 0.0;
  
  // Cache regex pattern to avoid recreating it
  static final _digitPattern = RegExp(r' \d+$');

  @override
  void initState() {
    super.initState();
    newEchoResult = Echo(stats: {}, score: 0.0, tier: 'Unbuilt');
    _enteredTotalER = widget.lastResult.totalER;
    _erController = TextEditingController(text: _enteredTotalER.toString());
  }

  @override
  void dispose() {
    _erController.dispose();
    super.dispose();
  }

  void _onStatChanged(String statKey, double value) {
    setState(() {
      newEchoStats[statKey] = value;
    });
  }

  Future<void> handleSubmit() async {
    setState(() {
      submitted = true;
      loading = true;
    });
    // Prepare 5-echo payload, replacing the selected echo's stats
    List<Map<String, double>> echoStatsList = List.generate(5, (i) {
      if (i < widget.lastResult.echoes.length) {
        // Use the actual stats from the current build
        return Map<String, double>.from(widget.lastResult.echoes[i].stats);
      }
      return <String, double>{};
    });
    // Remap newEchoStats keys to match the selected echo index
    // Optimize: use cached RegExp instead of creating it in forEach
    final remappedStats = <String, double>{};
    newEchoStats.forEach((key, value) {
      final statName = key.replaceAll(_digitPattern, '');
      remappedStats['$statName ${widget.echoIndex + 1}'] = value;
    });
    echoStatsList[widget.echoIndex] = remappedStats;
    try {
      final result = await ApiService.submit(
        energyBuff: widget.lastResult.energyBuff,
        resonatorName: widget.resonator.name,
        totalER: _enteredTotalER,
        echoStatsList: echoStatsList,
      );
      final echo = result.echoes[widget.echoIndex];
      setState(() {
        newEchoResult = echo;
      });
    } catch (e) {
      setState(() {
        newEchoResult = Echo(stats: remappedStats, score: 0.0, tier: 'Error');
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final newStats = newEchoStats;
    String compareSign = '';
    if (newEchoResult != null) {
      if (widget.currentEcho.score > newEchoResult!.score) {
        compareSign = '>';
      } else if (widget.currentEcho.score < newEchoResult!.score) {
        compareSign = '<';
      } else {
        compareSign = '=';
      }
    }

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
                    setState(() {
                      _enteredTotalER = v;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EchoCard(
                          index: 0,
                          resonator: widget.resonator,
                          lastResult: EchoSet(
                            echoes: [widget.currentEcho],
                            overallScore: widget.currentEcho.score,
                            overallTier: widget.currentEcho.tier,
                            energyBuff: 'None',
                            totalER: 0.0,
                          ),
                          echoStats: {
                            for (final entry
                                in widget.currentEcho.stats.entries)
                              entry.key.replaceAll(_digitPattern, ' 1'):
                                  entry.value,
                          },
                          onStatChanged: (_, _) {},
                          customTitle: 'Current Echo',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 96, child: ComparisonSign(sign: compareSign)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EchoCard(
                          index: 0,
                          resonator: widget.resonator,
                          lastResult: newEchoResult != null
                              ? EchoSet(
                                  echoes: [newEchoResult!],
                                  overallScore: newEchoResult!.score,
                                  overallTier: newEchoResult!.tier,
                                  energyBuff: 'None',
                                  totalER: 0.0,
                                )
                              : null,
                          echoStats: newStats,
                          onStatChanged: (stat, value) {
                            final key = '${statApiNames[stat]} 1';
                            _onStatChanged(key, value);
                          },
                          customTitle: 'New Echo',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Center(
                child: LoadingActionButton(
                  loading: loading,
                  onPressed: handleSubmit,
                  icon: const Icon(Icons.compare_arrows),
                  text: submitted ? 'Compare Again' : 'Compare',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
