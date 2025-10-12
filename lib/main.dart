import 'package:flutter/material.dart';

import 'data.dart';
import 'models/character.dart';
import 'models/echo.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'widgets/character_card.dart';
import 'widgets/stat_dropdown.dart';

void main() {
  runApp(const EchoValueCalcApp());
}

class EchoValueCalcApp extends StatelessWidget {
  const EchoValueCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'Echo Value Calculator',
      theme: theme,
      home: const CharacterListScreen(),
    );
  }
}

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  String _search = '';
  Attribute? _filterAttribute;
  Weapon? _filterWeapon;
  late List<Character> _characters;

  @override
  void initState() {
    super.initState();
    _characters = seedCharacters;
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    // Preload saved echo sets to reflect autofill icon or status
    final futures =
        _characters.map((c) => StorageService.loadEchoSet(c.id)).toList();
    final loaded = await Future.wait(futures);
    setState(() {
      _characters = List.generate(_characters.length, (i) {
        final saved = loaded[i];
        return _characters[i].copyWith(savedEchoSet: saved);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _characters.where((c) {
      final matchesSearch =
          c.name.toLowerCase().contains(_search.toLowerCase().trim());
      final matchesAttr =
          _filterAttribute == null || c.attribute == _filterAttribute;
      final matchesWeapon = _filterWeapon == null || c.weapon == _filterWeapon;
      return matchesSearch && matchesAttr && matchesWeapon;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off),
            onPressed: () {
              setState(() {
                _filterAttribute = null;
                _filterWeapon = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Image.asset(attributeAsset(Attribute.aero),
                    width: 24, height: 24),
                selected: _filterAttribute == Attribute.aero,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.aero
                          ? Attribute.aero
                          : null;
                }),
              ),
              FilterChip(
                label: Image.asset(attributeAsset(Attribute.electro),
                    width: 24, height: 24),
                selected: _filterAttribute == Attribute.electro,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.electro
                          ? Attribute.electro
                          : null;
                }),
              ),
              FilterChip(
                label: Image.asset(attributeAsset(Attribute.fusion),
                    width: 24, height: 24),
                selected: _filterAttribute == Attribute.fusion,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.fusion
                          ? Attribute.fusion
                          : null;
                }),
              ),
              FilterChip(
                label: Image.asset(attributeAsset(Attribute.glacio),
                    width: 24, height: 24),
                selected: _filterAttribute == Attribute.glacio,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.glacio
                          ? Attribute.glacio
                          : null;
                }),
              ),
              FilterChip(
                label: Image.asset(attributeAsset(Attribute.havoc),
                    width: 24, height: 24),
                selected: _filterAttribute == Attribute.havoc,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.havoc
                          ? Attribute.havoc
                          : null;
                }),
              ),
              FilterChip(
                label: Image.asset(attributeAsset(Attribute.spectro),
                    width: 24, height: 24),
                selected: _filterAttribute == Attribute.spectro,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.spectro
                          ? Attribute.spectro
                          : null;
                }),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: Image.asset(weaponAsset(Weapon.broadblade),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary),
                selected: _filterWeapon == Weapon.broadblade,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.broadblade
                      ? Weapon.broadblade
                      : null;
                }),
              ),
              ChoiceChip(
                label: Image.asset(weaponAsset(Weapon.gauntlets),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary),
                selected: _filterWeapon == Weapon.gauntlets,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.gauntlets
                      ? Weapon.gauntlets
                      : null;
                }),
              ),
              ChoiceChip(
                label: Image.asset(weaponAsset(Weapon.pistols),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary),
                selected: _filterWeapon == Weapon.pistols,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.pistols
                      ? Weapon.pistols
                      : null;
                }),
              ),
              ChoiceChip(
                label: Image.asset(weaponAsset(Weapon.rectifier),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary),
                selected: _filterWeapon == Weapon.rectifier,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.rectifier
                      ? Weapon.rectifier
                      : null;
                }),
              ),
              ChoiceChip(
                label: Image.asset(weaponAsset(Weapon.sword),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary),
                selected: _filterWeapon == Weapon.sword,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.sword
                      ? Weapon.sword
                      : null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final character = filtered[index];
                return CharacterCard(
                  character: character,
                  onTap: () async {
                    final result = await Navigator.push<EchoSet?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CharacterDetailScreen(character: character),
                      ),
                    );
                    if (result != null) {
                      await StorageService.saveEchoSet(character.id, result);
                      setState(() {
                        final idx =
                            _characters.indexWhere((c) => c.id == character.id);
                        if (idx >= 0) {
                          _characters[idx] =
                              _characters[idx].copyWith(savedEchoSet: result);
                        }
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterDetailScreen extends StatefulWidget {
  final Character character;
  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  String energyBuff = 'None'; // None, Yangyang, Zhezhi
  int totalER = 100;

  // For each echo (1..5), we keep a map of "StatName i" => value
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
        // Restore stats maps
        for (int i = 0; i < 5; i++) {
          echoStats[i] = Map<String, double>.from(saved.echoes[i].stats);
        }
      });
    }
  }

  void _setStatValue(int echoIndex, String statBaseName, double value) {
    final key = '$statBaseName ${echoIndex + 1}';
    setState(() {
      echoStats[echoIndex][key] = value;
    });
  }

  double _getSelected(int echoIndex, String statBaseName) {
    final key = '$statBaseName ${echoIndex + 1}';
    return echoStats[echoIndex][key] ?? 0.0;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted and saved')),
        );
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

  Widget _buildEchoCard(int i) {
    final usable = widget.character.usableStats;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Echo ${i + 1}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 12,
              children: usable.map((statName) {
                final range = statRanges[statName] ?? const [0.0];
                final selected = _getSelected(i, statName);
                return StatDropdown(
                  label: statName,
                  values: range,
                  selected: selected,
                  onChanged: (v) => _setStatValue(i, statName, v),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            if (lastResult != null)
              Row(
                children: [
                  Chip(
                    label: Text(
                        'Score: ${lastResult!.echoes[i].score.toStringAsFixed(1)}'),
                    avatar: const Icon(Icons.star),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Tier: ${lastResult!.echoes[i].tier}'),
                    avatar: const Icon(Icons.military_tech),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    return Scaffold(
      appBar: AppBar(
        title: Text('${c.name} • ${attributeLabel(c.attribute)}'),
      ),
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
                          backgroundImage: c.portraitUrl.isNotEmpty
                              ? AssetImage(c.portraitUrl)
                              : null,
                          child: c.portraitUrl.isEmpty
                              ? Text(
                                  c.name.isNotEmpty ? c.name[0] : '?',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Image.asset(attributeAsset(c.attribute),
                                      width: 24, height: 24),
                                  const SizedBox(width: 12),
                                  Image.asset(weaponAsset(c.weapon),
                                      width: 24,
                                      height: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
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
                                value: 'None', child: Text('None')),
                            DropdownMenuItem(
                                value: 'Yangyang', child: Text('Yangyang')),
                            DropdownMenuItem(
                                value: 'Zhezhi', child: Text('Zhezhi')),
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
            for (int i = 0; i < 5; i++) _buildEchoCard(i),
            const SizedBox(height: 12),
            Row(
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
                        label: Text(
                            'Overall Score: ${lastResult!.overallScore.toStringAsFixed(1)}'),
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
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
