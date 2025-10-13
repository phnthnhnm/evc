import 'package:flutter/material.dart';

import '../data.dart';
import '../models/character.dart';
import '../models/echo.dart';
import '../services/storage_service.dart';
import '../widgets/character_card.dart';
import 'character_detail_screen.dart';

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
    final futures = _characters
        .map((c) => StorageService.loadEchoSet(c.id))
        .toList();
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
      final matchesSearch = c.name.toLowerCase().contains(
        _search.toLowerCase().trim(),
      );
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
                label: Tooltip(
                  message: attributeLabels[Attribute.aero],
                  child: Image.asset(
                    attributeAsset(Attribute.aero),
                    width: 24,
                    height: 24,
                  ),
                ),
                selected: _filterAttribute == Attribute.aero,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.aero
                      ? Attribute.aero
                      : null;
                }),
              ),
              FilterChip(
                label: Tooltip(
                  message: attributeLabels[Attribute.electro],
                  child: Image.asset(
                    attributeAsset(Attribute.electro),
                    width: 24,
                    height: 24,
                  ),
                ),
                selected: _filterAttribute == Attribute.electro,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.electro
                      ? Attribute.electro
                      : null;
                }),
              ),
              FilterChip(
                label: Tooltip(
                  message: attributeLabels[Attribute.fusion],
                  child: Image.asset(
                    attributeAsset(Attribute.fusion),
                    width: 24,
                    height: 24,
                  ),
                ),
                selected: _filterAttribute == Attribute.fusion,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.fusion
                      ? Attribute.fusion
                      : null;
                }),
              ),
              FilterChip(
                label: Tooltip(
                  message: attributeLabels[Attribute.glacio],
                  child: Image.asset(
                    attributeAsset(Attribute.glacio),
                    width: 24,
                    height: 24,
                  ),
                ),
                selected: _filterAttribute == Attribute.glacio,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.glacio
                      ? Attribute.glacio
                      : null;
                }),
              ),
              FilterChip(
                label: Tooltip(
                  message: attributeLabels[Attribute.havoc],
                  child: Image.asset(
                    attributeAsset(Attribute.havoc),
                    width: 24,
                    height: 24,
                  ),
                ),
                selected: _filterAttribute == Attribute.havoc,
                onSelected: (selected) => setState(() {
                  _filterAttribute =
                      selected && _filterAttribute != Attribute.havoc
                      ? Attribute.havoc
                      : null;
                }),
              ),
              FilterChip(
                label: Tooltip(
                  message: attributeLabels[Attribute.spectro],
                  child: Image.asset(
                    attributeAsset(Attribute.spectro),
                    width: 24,
                    height: 24,
                  ),
                ),
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
                label: Tooltip(
                  message: weaponLabels[Weapon.broadblade],
                  child: Image.asset(
                    weaponAsset(Weapon.broadblade),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                selected: _filterWeapon == Weapon.broadblade,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.broadblade
                      ? Weapon.broadblade
                      : null;
                }),
              ),
              ChoiceChip(
                label: Tooltip(
                  message: weaponLabels[Weapon.sword],
                  child: Image.asset(
                    weaponAsset(Weapon.sword),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                selected: _filterWeapon == Weapon.sword,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.sword
                      ? Weapon.sword
                      : null;
                }),
              ),
              ChoiceChip(
                label: Tooltip(
                  message: weaponLabels[Weapon.pistols],
                  child: Image.asset(
                    weaponAsset(Weapon.pistols),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                selected: _filterWeapon == Weapon.pistols,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.pistols
                      ? Weapon.pistols
                      : null;
                }),
              ),
              ChoiceChip(
                label: Tooltip(
                  message: weaponLabels[Weapon.gauntlets],
                  child: Image.asset(
                    weaponAsset(Weapon.gauntlets),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                selected: _filterWeapon == Weapon.gauntlets,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.gauntlets
                      ? Weapon.gauntlets
                      : null;
                }),
              ),
              ChoiceChip(
                label: Tooltip(
                  message: weaponLabels[Weapon.rectifier],
                  child: Image.asset(
                    weaponAsset(Weapon.rectifier),
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                selected: _filterWeapon == Weapon.rectifier,
                onSelected: (selected) => setState(() {
                  _filterWeapon = selected && _filterWeapon != Weapon.rectifier
                      ? Weapon.rectifier
                      : null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final character = filtered[index];
                return SizedBox(
                  width: 180,
                  child: CharacterCard(
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
                          final idx = _characters.indexWhere(
                            (c) => c.id == character.id,
                          );
                          if (idx >= 0) {
                            _characters[idx] = _characters[idx].copyWith(
                              savedEchoSet: result,
                            );
                          }
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
