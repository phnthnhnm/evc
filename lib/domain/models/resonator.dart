import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/stat.dart';
import '../enums/weapon_attribute.dart';
import 'echo_set.dart';

part 'resonator.freezed.dart';
part 'resonator.g.dart';

@freezed
abstract class Resonator with _$Resonator {
  const Resonator._();

  const factory Resonator({
    required String id,
    required String name,
    @Default(5) int stars,
    required Attribute attribute,
    required Weapon weapon,
    required String iconAsset,
    required String portraitAsset,
    @Default([]) List<Stat> usableStats,
    @JsonKey(includeIfNull: false) EchoSet? savedEchoSet,
    @Default([]) List<String> teams,
    @JsonKey(includeIfNull: false) Map<String, String>? teamApiNames,
    String? erImportance,
    @JsonKey(name: 'damageSplit') Map<String, double>? damageSplit,
    @JsonKey(name: 'teamER') Map<String, dynamic>? teamER,
  }) = _Resonator;

  /// Teams offered on the website, with 'Default' first when the resonator
  /// has a Default team (e.g. Qingxiao has none). Falls back to ['Default']
  /// only when no team data exists at all.
  List<String> get effectiveTeams {
    return teams.isEmpty ? const ['Default'] : teams;
  }

  /// Returns [team] when it is a valid option for this resonator, otherwise
  /// the first effective team. Guards against null and legacy saved teams
  /// (e.g. 'Default' saved before a resonator's teams changed).
  String resolveTeam(String? team) {
    if (team != null && effectiveTeams.contains(team)) return team;
    return effectiveTeams.first;
  }

  /// The name the website API expects for [team], which can differ from the
  /// canonical name (e.g. Ciaccona's "Low-Reqs" is sent as "Low-Reqs: ").
  String apiTeamName(String team) {
    return teamApiNames?[team] ?? team;
  }

  /// ER target range for [team], or null if no data or ER not needed.
  Map<String, double>? erTargetForTeam(String team) {
    final entry = teamER?[team];
    if (entry == null || entry is! Map) return null;
    final min = entry['min'];
    final max = entry['max'];
    if (min == null || max == null) return null;
    return {'min': (min as num).toDouble(), 'max': (max as num).toDouble()};
  }

  /// Whether ER is explicitly marked as not needed for this team.
  bool erNotNeededForTeam(String team) {
    final entry = teamER?[team];
    if (entry == null || entry is! Map) return false;
    return !entry.containsKey('min') || !entry.containsKey('max');
  }

  factory Resonator.fromJson(Map<String, dynamic> json) =>
      _$ResonatorFromJson(json);
}
