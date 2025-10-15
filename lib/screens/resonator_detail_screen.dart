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
import '../widgets/resonator_header.dart';
import '../widgets/result_chips.dart';
import 'echo_compare_screen.dart';

class ResonatorDetailScreen extends StatefulWidget {
  final Resonator resonator;
  const ResonatorDetailScreen({super.key, required this.resonator});

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

  @override
  void initState() {
    super.initState();
    erController = TextEditingController(text: totalER.toString());
    echoStats = List.generate(5, (_) => <String, double>{});
    erController.addListener(_onERTextChanged);
    _loadSaved();
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
      echoStats[echoIndex][key] = value;
    });
  }

  Future<void> _submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    final echoSetProvider = Provider.of<EchoSetProvider>(
      context,
      listen: false,
    );
    try {
      final result = await ApiService.submit(
        energyBuff: energyBuff,
        resonatorName: widget.resonator.name,
        totalER: totalER,
        echoStatsList: echoStats,
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
      if (!mounted) return;
      setState(() {
        loading = false;
      });
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
                    ResonatorHeader(resonator: widget.resonator),
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
              echoStats: echoStats,
              lastResult: lastResult,
              onStatChanged: (i, stat, value) => _setStatValue(i, stat, value),
              onCompare: (i) {
                if (lastResult == null) return;
                final echo = lastResult!.echoes[i];
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EchoCompareScreen(
                      resonator: widget.resonator,
                      currentEcho: echo,
                      echoIndex: i,
                      lastResult: lastResult!,
                    ),
                  ),
                );
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
              overallScore: lastResult?.overallScore ?? 0.0,
              overallTier: lastResult?.overallTier ?? 'Unbuilt',
            ),
          ],
        ),
      ),
    );
  }
}
