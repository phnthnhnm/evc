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
    String? erImportance,
    @JsonKey(name: 'damageSplit') Map<String, double>? damageSplit,
    @JsonKey(name: 'teamER') Map<String, dynamic>? teamER,
  }) = _Resonator;

  /// Always includes 'Default' as the first option, even when [teams] is empty.
  List<String> get effectiveTeams {
    return ['Default', ...teams.where((t) => t != 'Default')];
  }

  /// ER target range for [team], or null if no data or ER not needed.
  Map<String, double>? erTargetForTeam(String team) {
    final entry = teamER?[team];
    if (entry == null || entry is! Map) return null;
    final min = entry['min'];
    final max = entry['max'];
    if (min == null || max == null) return null;
    return {
      'min': (min as num).toDouble(),
      'max': (max as num).toDouble(),
    };
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
