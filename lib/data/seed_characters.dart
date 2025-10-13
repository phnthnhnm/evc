import '../models/character.dart';
import 'data.dart';

final List<Character> seedCharacters = [
  Character(
    id: 'carlotta',
    name: 'Carlotta',
    attribute: Attribute.glacio,
    weapon: Weapon.pistols,
    portraitAsset: 'assets/portraits/Carlotta.png',
    usableStats: [
      Stat.critRate,
      Stat.critDamage,
      Stat.flatAtk,
      Stat.atkPercent,
      Stat.skillPercent,
      Stat.erPercent,
    ],
  ),
  Character(
    id: 'yangyang',
    name: 'Yangyang',
    attribute: Attribute.aero,
    weapon: Weapon.sword,
    portraitAsset: 'assets/portraits/Yangyang.png',
    usableStats: [
      Stat.critRate,
      Stat.critDamage,
      Stat.flatAtk,
      Stat.atkPercent,
      Stat.basicPercent,
      Stat.skillPercent,
      Stat.liberationPercent,
    ],
  ),
  Character(
    id: 'zhezhi',
    name: 'Zhezhi',
    attribute: Attribute.glacio,
    weapon: Weapon.rectifier,
    portraitAsset: 'assets/portraits/Zhezhi.png',
    usableStats: [
      Stat.critRate,
      Stat.critDamage,
      Stat.flatAtk,
      Stat.atkPercent,
      Stat.basicPercent,
      Stat.heavyPercent,
      Stat.skillPercent,
      Stat.erPercent,
    ],
  ),
];
