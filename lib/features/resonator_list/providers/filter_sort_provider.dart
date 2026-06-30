import 'package:riverpod/riverpod.dart';

import '../../../domain/enums/weapon_attribute.dart';
import '../../../domain/models/resonator.dart';
import '../../resonator_detail/providers/echo_sets_provider.dart';
import 'resonator_list_provider.dart';

enum SortOrder { scoreDesc, scoreAsc, nameAz, nameZa }

class ResonatorFilters {
  final String search;
  final Attribute? attribute;
  final Weapon? weapon;
  final int? stars;
  final String? echoTier;
  final SortOrder sortOrder;

  const ResonatorFilters({
    this.search = '',
    this.attribute,
    this.weapon,
    this.stars,
    this.echoTier,
    this.sortOrder = SortOrder.scoreDesc,
  });

  ResonatorFilters copyWith({
    String? search,
    Attribute? attribute,
    bool clearAttribute = false,
    Weapon? weapon,
    bool clearWeapon = false,
    int? stars,
    bool clearStars = false,
    String? echoTier,
    bool clearEchoTier = false,
    SortOrder? sortOrder,
  }) {
    return ResonatorFilters(
      search: search ?? this.search,
      attribute: clearAttribute ? null : (attribute ?? this.attribute),
      weapon: clearWeapon ? null : (weapon ?? this.weapon),
      stars: clearStars ? null : (stars ?? this.stars),
      echoTier: clearEchoTier ? null : (echoTier ?? this.echoTier),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResonatorFilters &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          attribute == other.attribute &&
          weapon == other.weapon &&
          stars == other.stars &&
          echoTier == other.echoTier &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      Object.hash(search, attribute, weapon, stars, echoTier, sortOrder);
}

final resonatorFiltersProvider =
    NotifierProvider<ResonatorFiltersNotifier, ResonatorFilters>(
      ResonatorFiltersNotifier.new,
    );

class ResonatorFiltersNotifier extends Notifier<ResonatorFilters> {
  @override
  ResonatorFilters build() => const ResonatorFilters();

  void setSearch(String search) => state = state.copyWith(search: search);

  void setAttribute(Attribute? attr) =>
      state = state.copyWith(attribute: attr, clearAttribute: attr == null);

  void setWeapon(Weapon? weapon) =>
      state = state.copyWith(weapon: weapon, clearWeapon: weapon == null);

  void setStars(int? stars) =>
      state = state.copyWith(stars: stars, clearStars: stars == null);

  void setEchoTier(String? tier) =>
      state = state.copyWith(echoTier: tier, clearEchoTier: tier == null);

  void setSortOrder(SortOrder order) =>
      state = state.copyWith(sortOrder: order);
}

final filteredResonatorsProvider = Provider<List<Resonator>>((ref) {
  final resonators = ref.watch(resonatorListProvider);
  final filters = ref.watch(resonatorFiltersProvider);
  final echoSetsAsync = ref.watch(echoSetsProvider);
  final echoSets = echoSetsAsync.value ?? {};

  final normalizedSearch = filters.search.toLowerCase().trim();

  var filtered = resonators
      .where((r) {
        if (normalizedSearch.isNotEmpty &&
            !r.name.toLowerCase().contains(normalizedSearch)) {
          return false;
        }
        if (filters.attribute != null && r.attribute != filters.attribute) {
          return false;
        }
        if (filters.weapon != null && r.weapon != filters.weapon) {
          return false;
        }
        if (filters.stars != null && r.stars != filters.stars) {
          return false;
        }
        if (filters.echoTier != null) {
          final echoSet = echoSets[r.id];
          if (echoSet == null ||
              !echoSet.echoes.any((e) => e.tier == filters.echoTier)) {
            return false;
          }
        }
        return true;
      })
      .map((r) => r.copyWith(savedEchoSet: echoSets[r.id]))
      .toList();

  switch (filters.sortOrder) {
    case SortOrder.scoreDesc:
      filtered.sort((a, b) {
        final aScore = a.savedEchoSet?.overallScore;
        final bScore = b.savedEchoSet?.overallScore;
        if (aScore == null && bScore == null) return 0;
        if (aScore == null) return 1;
        if (bScore == null) return -1;
        return bScore.compareTo(aScore);
      });
    case SortOrder.scoreAsc:
      filtered.sort((a, b) {
        final aScore = a.savedEchoSet?.overallScore;
        final bScore = b.savedEchoSet?.overallScore;
        if (aScore == null && bScore == null) return 0;
        if (aScore == null) return 1;
        if (bScore == null) return -1;
        return aScore.compareTo(bScore);
      });
    case SortOrder.nameAz:
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    case SortOrder.nameZa:
      filtered.sort(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
  }

  return filtered;
});
