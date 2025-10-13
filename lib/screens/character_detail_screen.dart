import 'package:flutter/material.dart';

import '../data.dart';
import '../models/character.dart';
import '../models/echo.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/toast_utils.dart';
import '../widgets/echo_card.dart';

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
    final c = widget.character;
    return Scaffold(
      appBar: AppBar(title: Text('Echo Builds')),
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
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.transparent,
                          backgroundImage: c.portraitAsset.isNotEmpty
                              ? AssetImage(c.portraitAsset)
                              : null,
                          child: c.portraitAsset.isEmpty
                              ? Text(
                                  c.name.isNotEmpty ? c.name[0] : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Tooltip(
                                    message: attributeLabels[c.attribute],
                                    child: Image.asset(
                                      attributeAsset(c.attribute),
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Tooltip(
                                    message: weaponLabels[c.weapon],
                                    child: Image.asset(
                                      weaponAsset(c.weapon),
                                      width: 24,
                                      height: 24,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Energy buffs from outros:'),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: energyBuff,
                          items: const [
                            DropdownMenuItem(
                              value: 'None',
                              child: Text('None'),
                            ),
                            DropdownMenuItem(
                              value: 'Yangyang',
                              child: Text('Yangyang'),
                            ),
                            DropdownMenuItem(
                              value: 'Zhezhi',
                              child: Text('Zhezhi'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => energyBuff = v ?? 'None'),
                        ),
                        const Spacer(),
                        const Text('Total ER of the build:'),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 90,
                          child: TextFormField(
                            initialValue: totalER.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) {
                              final parsed = int.tryParse(v);
                              if (parsed != null) {
                                setState(() => totalER = parsed);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                5,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: EchoCard(
                      index: i,
                      character: widget.character,
                      lastResult: lastResult,
                      echoStats: echoStats[i],
                      onStatChanged: (stat, value) =>
                          _setStatValue(i, stat, value),
                    ),
                  ),
                ),
              ),
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
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text('Overall Score: ${lastResult!.overallScore}'),
                    avatar: const Icon(Icons.workspace_premium),
                  ),
                  Chip(
                    label: Text('Overall Tier: ${lastResult!.overallTier}'),
                    avatar: const Icon(Icons.emoji_events),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
