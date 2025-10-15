import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/seed_resonators.dart';
import '../models/echo.dart';
import '../models/resonator.dart';
import '../services/storage_service.dart';
import '../widgets/attribute_filter_chips.dart';
import '../widgets/resonator_list_view.dart';
import '../widgets/search_bar.dart' as search_bar;
import '../widgets/weapon_choice_chips.dart';
import 'resonator_detail_screen.dart';
import 'settings/settings_screen.dart';

class ResonatorListScreen extends StatefulWidget {
  const ResonatorListScreen({super.key});

  @override
  State<ResonatorListScreen> createState() => _ResonatorListScreenState();
}

class _ResonatorListScreenState extends State<ResonatorListScreen> {
  String _search = '';
  Attribute? _filterAttribute;
  Weapon? _filterWeapon;
  late List<Resonator> _resonators;

  @override
  void initState() {
    super.initState();
    _resonators = seedResonators;
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final futures = _resonators
        .map((c) => StorageService.loadEchoSet(c.id))
        .toList();
    final loaded = await Future.wait(futures);
    setState(() {
      _resonators = List.generate(_resonators.length, (i) {
        final saved = loaded[i];
        return _resonators[i].copyWith(savedEchoSet: saved);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _resonators.where((c) {
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
        title: const Text('Resonators'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Report a Bug',
            onPressed: () async {
              final url = Uri.parse(
                'https://github.com/phnthnhnm/evc/issues/new',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to Use',
            onPressed: () async {
              final url = Uri.parse('https://www.echovaluecalc.com/instruct');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
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
            ResonatorListView(
              resonators: filtered,
              onEchoSetSaved: (resonator, result) async {
                if (result != null) {
                  await StorageService.saveEchoSet(resonator.id, result);
                  setState(() {
                    final idx = _resonators.indexWhere(
                      (c) => c.id == resonator.id,
                    );
                    if (idx >= 0) {
                      _resonators[idx] = _resonators[idx].copyWith(
                        savedEchoSet: result,
                      );
                    }
                  });
                }
              },
              onResonatorTap: (resonator) async {
                final result = await Navigator.push<EchoSet?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResonatorDetailScreen(resonator: resonator),
                  ),
                );
                if (result != null) {
                  await StorageService.saveEchoSet(resonator.id, result);
                  setState(() {
                    final idx = _resonators.indexWhere(
                      (c) => c.id == resonator.id,
                    );
                    if (idx >= 0) {
                      _resonators[idx] = _resonators[idx].copyWith(
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
