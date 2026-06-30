import 'package:flutter_test/flutter_test.dart';
import 'package:evc/domain/enums/stat.dart';

void main() {
  group('Stat enum', () {
    test('all contains 13 stats', () {
      expect(Stat.all.length, 13);
    });

    test('fromName round-trips for every stat', () {
      for (final stat in Stat.values) {
        expect(Stat.fromName(stat.name), stat);
      }
    });

    test('fromName throws for invalid name', () {
      expect(() => Stat.fromName('invalid'), throwsArgumentError);
    });

    test('flatAtk and atkPercent share the same asset', () {
      expect(Stat.flatAtk.assetPath, Stat.atkPercent.assetPath);
    });

    test('flatHp and hpPercent share the same asset', () {
      expect(Stat.flatHp.assetPath, Stat.hpPercent.assetPath);
    });
  });
}
