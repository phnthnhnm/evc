import 'package:flutter/material.dart';

import '../data.dart';
import '../models/character.dart';
import '../models/echo.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/toast_utils.dart';
import '../widgets/character_header.dart';
import '../widgets/echo_cards_row.dart';
import '../widgets/energy_buff_row.dart';
import '../widgets/result_chips.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;
  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  String energyBuff = 'None'; // None, Yangyang, Zhezhi
  int totalER = 100;
  late List<Map<String, double>> echoStats;
  bool loading = false;
  EchoSet? lastResult;
  String? error;

  @override
  void initState() {
    super.initState();
    echoStats = List.generate(5, (_) => <String, double>{});
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await StorageService.loadEchoSet(widget.character.id);
    if (saved != null) {
      setState(() {
        lastResult = saved;
        energyBuff = saved.energyBuff;
        totalER = saved.totalER;
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
    try {
      final result = await ApiService.submit(
        energyBuff: energyBuff,
        characterName: widget.character.name,
        totalER: totalER,
        echoStatsList: echoStats,
      );
      await StorageService.saveEchoSet(widget.character.id, result);
      setState(() {
        lastResult = result;
      });
      if (mounted) {
        showTopRightToast(context, 'Submitted and saved');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Echo Builds')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CharacterHeader(character: widget.character),
                    const SizedBox(height: 12),
                    EnergyBuffRow(
                      energyBuff: energyBuff,
                      onBuffChanged: (v) =>
                          setState(() => energyBuff = v ?? 'None'),
                      totalER: totalER,
                      onERChanged: (v) => setState(() => totalER = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            EchoCardsRow(
              character: widget.character,
              echoStats: echoStats,
              lastResult: lastResult,
              onStatChanged: (i, stat, value) => _setStatValue(i, stat, value),
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
            ElevatedButton.icon(
              onPressed: loading ? null : _submit,
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
            ),
            const SizedBox(width: 12),
            if (loading) const CircularProgressIndicator(),
            const Spacer(),
            if (lastResult != null)
              ResultChips(
                overallScore: lastResult!.overallScore,
                overallTier: lastResult!.overallTier,
              ),
          ],
        ),
      ),
    );
  }
}
