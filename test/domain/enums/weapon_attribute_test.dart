import 'package:flutter_test/flutter_test.dart';
import 'package:evc/domain/enums/weapon_attribute.dart';

void main() {
  group('Weapon', () {
    test('all 5 weapons have labels', () {
      for (final w in Weapon.values) {
        expect(w.label, isNotEmpty);
      }
    });

    test('all weapons have asset paths', () {
      for (final w in Weapon.values) {
        expect(w.assetPath, contains('.webp'));
      }
    });

    test('labels are distinct', () {
      final labels = Weapon.values.map((w) => w.label).toSet();
      expect(labels.length, Weapon.values.length);
    });
  });

  group('Attribute', () {
    test('all 6 attributes have labels', () {
      for (final a in Attribute.values) {
        expect(a.label, isNotEmpty);
      }
    });

    test('all attributes have asset paths', () {
      for (final a in Attribute.values) {
        expect(a.assetPath, contains('attribute_icons'));
      }
    });

    test('labels are distinct', () {
      final labels = Attribute.values.map((a) => a.label).toSet();
      expect(labels.length, Attribute.values.length);
    });
  });
}
