/// Enhanced enum representing the 13 echo substats in Wuthering Waves.
enum Stat {
  critRate,
  critDamage,
  flatAtk,
  atkPercent,
  flatHp,
  hpPercent,
  flatDef,
  defPercent,
  basicPercent,
  heavyPercent,
  skillPercent,
  liberationPercent,
  erPercent;

  /// All stats in canonical display order.
  static const List<Stat> all = Stat.values;

  /// Look up a [Stat] by its Dart enum name.
  static Stat fromName(String name) => Stat.values.byName(name);

  /// The API name used in HTTP requests and JSON keys (e.g. "Crit Rate(%)").
  String get apiName => switch (this) {
        Stat.critRate => 'Crit Rate(%)',
        Stat.critDamage => 'Crit Damage(%)',
        Stat.flatAtk => 'Flat Atk',
        Stat.atkPercent => 'Atk(%)',
        Stat.flatHp => 'Flat HP',
        Stat.hpPercent => 'HP(%)',
        Stat.flatDef => 'Flat Def',
        Stat.defPercent => 'Def(%)',
        Stat.basicPercent => 'Basic(%)',
        Stat.heavyPercent => 'Heavy(%)',
        Stat.skillPercent => 'Skill(%)',
        Stat.liberationPercent => 'Liberation(%)',
        Stat.erPercent => 'ER(%)',
      };

  /// Human-readable label shown in the UI.
  String get label => switch (this) {
        Stat.critRate => 'Crit. Rate',
        Stat.critDamage => 'Crit. Damage',
        Stat.flatAtk => 'ATK',
        Stat.atkPercent => 'ATK%',
        Stat.flatHp => 'HP',
        Stat.hpPercent => 'HP%',
        Stat.flatDef => 'DEF',
        Stat.defPercent => 'DEF%',
        Stat.basicPercent => 'Basic%',
        Stat.heavyPercent => 'Heavy%',
        Stat.skillPercent => 'Skill%',
        Stat.liberationPercent => 'Liberation%',
        Stat.erPercent => 'ER',
      };

  /// Asset path for the stat icon.
  String get assetPath => switch (this) {
        Stat.critRate => 'assets/stat_icons/cr.webp',
        Stat.critDamage => 'assets/stat_icons/cd.webp',
        Stat.flatAtk || Stat.atkPercent => 'assets/stat_icons/atk.webp',
        Stat.flatHp || Stat.hpPercent => 'assets/stat_icons/hp.webp',
        Stat.flatDef || Stat.defPercent => 'assets/stat_icons/def.webp',
        Stat.basicPercent => 'assets/stat_icons/basic.webp',
        Stat.heavyPercent => 'assets/stat_icons/heavy.webp',
        Stat.skillPercent => 'assets/stat_icons/skill.webp',
        Stat.liberationPercent => 'assets/stat_icons/liberation.webp',
        Stat.erPercent => 'assets/stat_icons/er.webp',
      };

  /// Valid roll values for this stat (used in dropdowns).
  List<double> get validValues => switch (this) {
        Stat.critRate => [6.3, 6.9, 7.5, 8.1, 8.7, 9.3, 9.9, 10.5],
        Stat.critDamage => [12.6, 13.8, 15.0, 16.2, 17.4, 18.6, 19.8, 21.0],
        Stat.flatAtk => [30.0, 40.0, 50.0, 60.0],
        Stat.atkPercent => [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
        Stat.flatHp => [320.0, 360.0, 390.0, 430.0, 470.0, 510.0, 540.0, 580.0],
        Stat.hpPercent => [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
        Stat.flatDef => [40.0, 50.0, 60.0, 70.0],
        Stat.defPercent => [8.1, 9.0, 10.0, 10.9, 11.8, 12.8, 13.8, 14.7],
        Stat.basicPercent => [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
        Stat.heavyPercent => [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
        Stat.skillPercent => [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
        Stat.liberationPercent => [
            6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6,
          ],
        Stat.erPercent => [6.8, 7.6, 8.4, 9.2, 10.0, 10.8, 11.6, 12.4],
      };
}
