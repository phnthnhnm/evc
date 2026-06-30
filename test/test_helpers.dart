import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/enums/weapon_attribute.dart';
import 'package:evc/domain/models/resonator.dart';

/// Creates a mock resonator for testing.
Resonator mockResonator({
  String id = 'test-resonator',
  String name = 'Test Resonator',
  int stars = 5,
  Attribute attribute = Attribute.fusion,
  Weapon weapon = Weapon.sword,
  List<String> teams = const [],
}) {
  return Resonator(
    id: id,
    name: name,
    stars: stars,
    attribute: attribute,
    weapon: weapon,
    iconAsset: 'assets/resonator_icons/test.webp',
    portraitAsset: 'assets/resonator_portraits/test.webp',
    usableStats: Stat.all,
    teams: teams,
  );
}
