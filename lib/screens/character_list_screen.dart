import 'package:flutter/material.dart';

import '../data/seed_characters.dart';
import '../models/character.dart';
import '../services/storage_service.dart';
import '../widgets/attribute_filter_chips.dart';
import '../widgets/character_list_view.dart';
import '../widgets/search_bar.dart' as search_bar;
import '../widgets/weapon_choice_chips.dart';
import 'settings/settings_screen.dart';

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
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            search_bar.SearchBar(
              value: _search,
              onChanged: (v) => setState(() => _search = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AttributeFilterChips(
                  selected: _filterAttribute,
                  onChanged: (attr) => setState(() => _filterAttribute = attr),
                ),
                const SizedBox(width: 24),
                WeaponChoiceChips(
                  selected: _filterWeapon,
                  onChanged: (weapon) => setState(() => _filterWeapon = weapon),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CharacterListView(
              characters: filtered,
              onEchoSetSaved: (character, result) async {
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
          ],
        ),
      ),
    );
  }
}
