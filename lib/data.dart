import 'models/character.dart';

// Stat names must exactly match request param labels,
// without the trailing echo index (we will append " 1", " 2", etc.)
const List<String> allStats = [
  'Crit Rate(%)',
  'Crit Damage(%)',
  'Atk(%)',
  'Flat Atk',
  'HP(%)',
  'Flat HP',
  'Def(%)',
  'Flat Def',
  'Basic(%)',
  'Heavy(%)',
  'Skill(%)',
  'Liberation(%)',
  'ER(%)',
];

// Valid ranges for each stat as per spec
const Map<String, List<double>> statRanges = {
  'Crit Rate(%)': [6.3, 6.9, 7.5, 8.1, 8.7, 9.3, 9.9, 10.5],
  'Crit Damage(%)': [12.6, 13.8, 15.0, 16.2, 17.4, 18.6, 19.8, 21.0],
  'Atk(%)': [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  'Flat Atk': [30.0, 40.0, 50.0, 60.0],
  'HP(%)': [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  'Flat HP': [320.0, 360.0, 390.0, 430.0, 470.0, 510.0, 540.0, 580.0],
  'Def(%)': [8.1, 9.0, 10.0, 10.9, 11.8, 12.8, 13.8, 14.7],
  'Flat Def': [40.0, 50.0, 60.0, 70.0],
  'Basic(%)': [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  'Heavy(%)': [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  'Skill(%)': [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  'Liberation(%)': [6.4, 7.1, 7.9, 8.6, 9.4, 10.1, 10.9, 11.6],
  'ER(%)': [6.8, 7.6, 8.4, 9.2, 10.0, 10.8, 11.6, 12.4],
};

// Tiers (for reference in UI only; server returns exact tiers)
const List<String> tiersOrdered = [
  'GOD TIER',
  'EXTREME TIER',
  'HIGH-INVESTMENT TIER',
  'WELL-BUILT TIER',
  'DECENT TIER',
  'BASE TIER',
  'UNBUILT TIER',
];

// Characters and the stats they actually use
final List<Character> seedCharacters = [
  Character(
    id: 'carlotta',
    name: 'Carlotta',
    attribute: Attribute.glacio,
    weapon: Weapon.pistols,
    portraitUrl: '', // Placeholder; using initials avatar in UI
    usableStats: [
      'Crit Rate(%)',
      'Crit Damage(%)',
      'Atk(%)',
      'Flat Atk',
      'Skill(%)',
      'ER(%)',
    ],
  ),
  // You can add more characters here with their usable stats
  Character(
    id: 'yangyang',
    name: 'Yangyang',
    attribute: Attribute.aero,
    weapon: Weapon.sword,
    portraitUrl: '',
    usableStats: [
      'Crit Rate(%)',
      'Crit Damage(%)',
      'Atk(%)',
      'Flat Atk',
      'Basic(%)',
      'ER(%)',
    ],
  ),
  Character(
    id: 'zhezhi',
    name: 'Zhezhi',
    attribute: Attribute.glacio,
    weapon: Weapon.rectifier,
    portraitUrl: '',
    usableStats: [
      'Crit Rate(%)',
      'Crit Damage(%)',
      'Atk(%)',
      'Flat Atk',
      'Heavy(%)',
      'ER(%)',
    ],
  ),
];
