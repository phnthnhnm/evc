import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:evc/domain/enums/weapon_attribute.dart';
import 'package:evc/features/resonator_detail/providers/echo_sets_provider.dart';
import 'package:evc/features/resonator_list/providers/filter_sort_provider.dart';
import 'package:evc/features/settings/providers/settings_provider.dart';
import 'package:evc/presentation/theme/app_colors.dart';
import 'package:evc/presentation/widgets/resonator_list_view.dart';
import 'package:evc/presentation/widgets/search_bar.dart' as search_bar;

class ResonatorListScreen extends ConsumerStatefulWidget {
  const ResonatorListScreen({super.key});

  @override
  ConsumerState<ResonatorListScreen> createState() =>
      _ResonatorListScreenState();
}

class _ResonatorListScreenState extends ConsumerState<ResonatorListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(echoSetsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(resonatorFiltersProvider);
    final filtered = ref.watch(filteredResonatorsProvider);
    final showScore = ref.watch(showScoreOnCardProvider);

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
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            search_bar.SearchBar(
              value: filters.search,
              onChanged: (v) {
                ref.read(resonatorFiltersProvider.notifier).setSearch(v);
              },
            ),
            _filterRow(context, filters),
            const SizedBox(height: 8),
            ResonatorListView(
              resonators: filtered,
              onEchoSetSaved: (_, _) async => ref.invalidate(echoSetsProvider),
              onResonatorTap: (r) => context.push('/resonator/${r.id}'),
              showScoreOnCard: showScore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterRow(BuildContext context, ResonatorFilters filters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _starsDropdown(filters),
        const SizedBox(width: 24),
        _attributeDropdown(filters),
        const SizedBox(width: 24),
        _weaponDropdown(context, filters),
        const SizedBox(width: 24),
        _echoTierDropdown(filters),
        const SizedBox(width: 24),
        _sortDropdown(filters),
      ],
    );
  }

  Widget _starsDropdown(ResonatorFilters filters) {
    return DropdownButton<int>(
      value: filters.stars,
      hint: const Text('Stars'),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('All Stars')),
        ...[4, 5].map(
          (stars) => DropdownMenuItem<int>(
            value: stars,
            child: Text(
              '$stars ✦',
              style: TextStyle(
                color: AppColors.starColor(stars),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      onChanged: (s) => ref.read(resonatorFiltersProvider.notifier).setStars(s),
    );
  }

  Widget _attributeDropdown(ResonatorFilters filters) {
    return DropdownButton<Attribute>(
      value: filters.attribute,
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
                Image.asset(attr.assetPath, width: 24, height: 24),
                const SizedBox(width: 8),
                Text(attr.label),
              ],
            ),
          ),
        ),
      ],
      onChanged: (a) =>
          ref.read(resonatorFiltersProvider.notifier).setAttribute(a),
    );
  }

  Widget _weaponDropdown(BuildContext context, ResonatorFilters filters) {
    return DropdownButton<Weapon>(
      value: filters.weapon,
      hint: const Text('Weapons'),
      items: [
        const DropdownMenuItem<Weapon>(value: null, child: Text('All Weapons')),
        ...Weapon.values.map(
          (w) => DropdownMenuItem<Weapon>(
            value: w,
            child: Row(
              children: [
                Image.asset(
                  w.assetPath,
                  width: 24,
                  height: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(w.label),
              ],
            ),
          ),
        ),
      ],
      onChanged: (w) =>
          ref.read(resonatorFiltersProvider.notifier).setWeapon(w),
    );
  }

  Widget _echoTierDropdown(ResonatorFilters filters) {
    return DropdownButton<String>(
      value: filters.echoTier,
      hint: const Text('Echo Tier'),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('All Tiers')),
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
              style: TextStyle(color: AppColors.tierColor(tier)),
            ),
          ),
        ),
      ],
      onChanged: (t) =>
          ref.read(resonatorFiltersProvider.notifier).setEchoTier(t),
    );
  }

  Widget _sortDropdown(ResonatorFilters filters) {
    return DropdownButton<SortOrder>(
      value: filters.sortOrder,
      hint: const Text('Sort'),
      items: const [
        DropdownMenuItem(value: SortOrder.nameAz, child: Text('Name: A to Z')),
        DropdownMenuItem(value: SortOrder.nameZa, child: Text('Name: Z to A')),
        DropdownMenuItem(
          value: SortOrder.scoreDesc,
          child: Text('Score: High to Low'),
        ),
        DropdownMenuItem(
          value: SortOrder.scoreAsc,
          child: Text('Score: Low to High'),
        ),
      ],
      onChanged: (o) {
        if (o != null) {
          ref.read(resonatorFiltersProvider.notifier).setSortOrder(o);
        }
      },
    );
  }
}
