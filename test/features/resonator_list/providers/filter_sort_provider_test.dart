import 'package:flutter_test/flutter_test.dart';

import 'package:evc/domain/enums/weapon_attribute.dart';
import 'package:evc/features/resonator_list/providers/filter_sort_provider.dart';

void main() {
  group('ResonatorFilters', () {
    test('copyWith with no args returns identical copy', () {
      const filters = ResonatorFilters(
        search: 'test',
        attribute: Attribute.fusion,
        sortOrder: SortOrder.nameAz,
      );
      final copy = filters.copyWith();

      expect(copy, filters);
    });

    test('copyWith overrides search', () {
      const filters = ResonatorFilters();
      final copy = filters.copyWith(search: 'rover');

      expect(copy.search, 'rover');
    });

    test('copyWith overrides sortOrder', () {
      const filters = ResonatorFilters();
      final copy = filters.copyWith(sortOrder: SortOrder.nameAz);

      expect(copy.sortOrder, SortOrder.nameAz);
    });

    test('copyWith overrides attribute, weapon, stars, echoTier', () {
      const filters = ResonatorFilters();
      final copy = filters.copyWith(
        attribute: Attribute.aero,
        weapon: Weapon.pistols,
        stars: 4,
        echoTier: 'S',
      );

      expect(copy.attribute, Attribute.aero);
      expect(copy.weapon, Weapon.pistols);
      expect(copy.stars, 4);
      expect(copy.echoTier, 'S');
    });

    test('clearAttribute: true sets attribute to null (wins over provided value)', () {
      const filters = ResonatorFilters(attribute: Attribute.fusion);
      final copy = filters.copyWith(
        attribute: Attribute.aero,
        clearAttribute: true,
      );

      expect(copy.attribute, isNull);
    });

    test('clearWeapon, clearStars, clearEchoTier each null their field', () {
      const filters = ResonatorFilters(
        weapon: Weapon.sword,
        stars: 5,
        echoTier: 'S',
      );

      final copy = filters.copyWith(
        clearWeapon: true,
        clearStars: true,
        clearEchoTier: true,
      );

      expect(copy.weapon, isNull);
      expect(copy.stars, isNull);
      expect(copy.echoTier, isNull);
    });

    test('equality: same values are ==', () {
      const a = ResonatorFilters(
        search: 'rover',
        attribute: Attribute.spectro,
        sortOrder: SortOrder.scoreAsc,
      );
      const b = ResonatorFilters(
        search: 'rover',
        attribute: Attribute.spectro,
        sortOrder: SortOrder.scoreAsc,
      );

      expect(a, equals(b));
    });

    test('equality: different values are not ==', () {
      const a = ResonatorFilters(search: 'rover');
      const b = ResonatorFilters(search: 'yinlin');

      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      const a = ResonatorFilters(search: 'rover', attribute: Attribute.fusion);
      const b = ResonatorFilters(search: 'rover', attribute: Attribute.fusion);

      expect(a.hashCode, b.hashCode);
    });
  });
}
