import 'models/character.dart';

// Stat enum and helpers
enum Stat {
  critRate,
  critDamage,
  atkPercent,
  flatAtk,
  hpPercent,
  flatHp,
  defPercent,
  flatDef,
  basicPercent,
  heavyPercent,
  skillPercent,
  liberationPercent,
  erPercent,
}

const List<Stat> allStats = [
  Stat.critRate,
  Stat.critDamage,
  Stat.atkPercent,
  Stat.flatAtk,
  Stat.hpPercent,
  Stat.flatHp,
  Stat.defPercent,
  Stat.flatDef,
  Stat.basicPercent,
  Stat.heavyPercent,
  Stat.skillPercent,
  Stat.liberationPercent,
  Stat.erPercent,
];

const Map<Stat, String> statLabels = {
  Stat.critRate: 'Crit Rate(%)',
  Stat.critDamage: 'Crit Damage(%)',
  Stat.atkPercent: 'Atk(%)',
  Stat.flatAtk: 'Flat Atk',
  Stat.hpPercent: 'HP(%)',
  Stat.flatHp: 'Flat HP',
  Stat.defPercent: 'Def(%)',
  Stat.flatDef: 'Flat Def',
  Stat.basicPercent: 'Basic(%)',
  Stat.heavyPercent: 'Heavy(%)',
  Stat.skillPercent: 'Skill(%)',
  Stat.liberationPercent: 'Liberation(%)',
  Stat.erPercent: 'ER(%)',
};

// Stat names must exactly match request param labels,
// without the trailing echo index (we will append " 1", " 2", etc.)

// Valid ranges for each stat as per spec
const Map<Stat, List<double>> statRanges = {
  Stat.critRate: [6.3, 6.9, 7.5, 8.1, 8.7, 9.3, 9.9, 10.5],
  Stat.critDamage: [12.6, 13.8, 15.0, 16.2, 17.4, 18.6, 19.8, 21.0],
  Stat.atkPercent: [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  Stat.flatAtk: [30.0, 40.0, 50.0, 60.0],
  Stat.hpPercent: [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  Stat.flatHp: [320.0, 360.0, 390.0, 430.0, 470.0, 510.0, 540.0, 580.0],
  Stat.defPercent: [8.1, 9.0, 10.0, 10.9, 11.8, 12.8, 13.8, 14.7],
  Stat.flatDef: [40.0, 50.0, 60.0, 70.0],
  Stat.basicPercent: [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  Stat.heavyPercent: [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  Stat.skillPercent: [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  Stat.liberationPercent: [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  Stat.erPercent: [6.8, 7.6, 8.4, 9.2, 10.0, 10.8, 11.6, 12.4],
};

// Characters and the stats they actually use
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
      Stat.atkPercent,
      Stat.flatAtk,
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
      Stat.atkPercent,
      Stat.flatAtk,
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
      Stat.atkPercent,
      Stat.flatAtk,
      Stat.basicPercent,
      Stat.heavyPercent,
      Stat.skillPercent,
      Stat.erPercent,
    ],
  ),
];
