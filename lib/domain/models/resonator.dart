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
  }) = _Resonator;

  /// Always includes 'Default' as the first option, even when [teams] is empty.
  List<String> get effectiveTeams {
    return ['Default', ...teams.where((t) => t != 'Default')];
  }

  factory Resonator.fromJson(Map<String, dynamic> json) =>
      _$ResonatorFromJson(json);
}
