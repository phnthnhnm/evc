import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/seed_resonators.dart';
import '../models/echo.dart';
import '../models/resonator.dart';
import '../utils/echo_set_provider.dart';
import '../utils/resonator_utils.dart';
import '../utils/tier_color_utils.dart';
import '../widgets/resonator_list_view.dart';
import '../widgets/search_bar.dart' as search_bar;
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
  String? _filterEchoTier;
  int? _filterStars;
  
  // Cache normalized search term to avoid repeated toLowerCase() calls
  String _normalizedSearch = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EchoSetProvider>(context, listen: false).loadAll();
    });
  }
  
  // Helper method to filter resonators
  List<Resonator> _filterResonators(
    Map<String, EchoSet> echoSets,
  ) {
    // Early return if no filters applied
    final hasFilters = _search.isNotEmpty ||
        _filterAttribute != null ||
        _filterWeapon != null ||
        _filterStars != null ||
        _filterEchoTier != null;
    
    if (!hasFilters) {
      // No filtering needed, just attach echo sets
      return seedResonators
          .map((r) => r.copyWith(savedEchoSet: echoSets[r.id]))
          .toList();
    }
    
    return seedResonators.where((c) {
      // Search filter - use cached normalized search
      if (_normalizedSearch.isNotEmpty) {
        if (!c.name.toLowerCase().contains(_normalizedSearch)) {
          return false;
        }
      }
      
      // Attribute filter
      if (_filterAttribute != null && c.attribute != _filterAttribute) {
        return false;
      }
      
      // Weapon filter
      if (_filterWeapon != null && c.weapon != _filterWeapon) {
        return false;
      }
      
      // Stars filter
      if (_filterStars != null && c.stars != _filterStars) {
        return false;
      }
      
      // Echo tier filter
      if (_filterEchoTier != null) {
        final echoSet = echoSets[c.id];
        if (echoSet == null || 
            !echoSet.echoes.any((e) => e.tier == _filterEchoTier)) {
          return false;
        }
      }
      
      return true;
    }).map((resonator) {
      return resonator.copyWith(savedEchoSet: echoSets[resonator.id]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final echoSetProvider = Provider.of<EchoSetProvider>(context);
    final echoSets = echoSetProvider.echoSets;
    final filtered = _filterResonators(echoSets);

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
              onChanged: (v) {
                setState(() {
                  _search = v;
                  _normalizedSearch = v.toLowerCase().trim();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _filterStars,
                  hint: const Text('Stars'),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Stars'),
                    ),
                    ...[4, 5].map(
                      (stars) => DropdownMenuItem<int>(
                        value: stars,
                        child: Text(
                          '$stars ✦',
                          style: TextStyle(
                            color: getStarColor(stars),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (stars) => setState(() => _filterStars = stars),
                ),
                const SizedBox(width: 24),
                DropdownButton<Attribute>(
                  value: _filterAttribute,
                  hint: const Text('Attribute'),
                  items: [
                    const DropdownMenuItem<Attribute>(
                      value: null,
                      child: Text('All Attributes'),
                    ),
                    ...Attribute.values.map(
                      (attr) => DropdownMenuItem<Attribute>(
                        value: attr,
                        child: Row(
                          children: [
                            Image.asset(
                              attributeAsset(attr),
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(attributeLabel(attr)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (attr) => setState(() => _filterAttribute = attr),
                ),
                const SizedBox(width: 24),
                DropdownButton<Weapon>(
                  value: _filterWeapon,
                  hint: const Text('Weapons'),
                  items: [
                    const DropdownMenuItem<Weapon>(
                      value: null,
                      child: Text('All Weapons'),
                    ),
                    ...Weapon.values.map(
                      (weapon) => DropdownMenuItem<Weapon>(
                        value: weapon,
                        child: Row(
                          children: [
                            Image.asset(
                              weaponAsset(weapon),
                              width: 24,
                              height: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(weaponLabel(weapon)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (weapon) => setState(() => _filterWeapon = weapon),
                ),
                const SizedBox(width: 24),
                DropdownButton<String>(
                  value: _filterEchoTier,
                  hint: const Text('Echo Tier'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Tiers'),
                    ),
                    ...[
                      'Godly',
                      'Extreme',
                      'High Investment',
                      'Well Built',
                      'Decent',
                      'Base Level',
                      'Unbuilt',
                    ].map(
                      (tier) => DropdownMenuItem<String>(
                        value: tier,
                        child: Text(
                          tier,
                          style: TextStyle(color: getTierColor(tier)),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (tier) => setState(() => _filterEchoTier = tier),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ResonatorListView(
              resonators: filtered,
              onEchoSetSaved: (resonator, result) async {
                if (result != null) {
                  await echoSetProvider.saveEchoSet(resonator.id, result);
                }
              },
              onResonatorTap: (resonator) async {
                final result = await Navigator.push<EchoSet?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResonatorDetailScreen(
                      resonator: resonator,
                      savedEchoSet: echoSets[resonator.id],
                    ),
                  ),
                );
                if (result != null) {
                  await echoSetProvider.saveEchoSet(resonator.id, result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
