import 'package:flutter_test/flutter_test.dart';
import 'package:evc/domain/enums/weapon_attribute.dart';

void main() {
  group('Weapon', () {
    test('labels are distinct', () {
      final labels = Weapon.values.map((w) => w.label).toSet();
      expect(labels.length, Weapon.values.length);
    });
  });

  group('Attribute', () {
    test('labels are distinct', () {
      final labels = Attribute.values.map((a) => a.label).toSet();
      expect(labels.length, Attribute.values.length);
    });
  });
}
