import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/skin.dart';

void main() {
  group('Skin', () {
    const skin = Skin(
      id: 'neon',
      name: 'Neon Board',
      description: 'A vibrant board.',
      price: 1000,
      type: SkinType.board,
      iconName: 'grid_on',
    );

    test('equality by id', () {
      const same = Skin(
        id: 'neon',
        name: 'Different Name',
        description: 'Different desc',
        price: 999,
        type: SkinType.dice,
        iconName: 'other',
      );
      expect(skin, equals(same));
    });

    test('different id is not equal', () {
      const other = Skin(
        id: 'classic',
        name: 'Neon Board',
        description: 'A vibrant board.',
        price: 1000,
        type: SkinType.board,
        iconName: 'grid_on',
      );
      expect(skin, isNot(equals(other)));
    });

    test('hashCode by id', () {
      const same = Skin(
        id: 'neon',
        name: 'X',
        description: 'Y',
        price: 0,
        type: SkinType.theme,
        iconName: 'z',
      );
      expect(skin.hashCode, equals(same.hashCode));
    });
  });
}
