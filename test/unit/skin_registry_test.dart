import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/skin_registry.dart';
import '../../lib/models/skin.dart';

void main() {
  group('SkinRegistry', () {
    test('all contains 5 skins', () {
      expect(SkinRegistry.all.length, 5);
    });

    test('classic is free', () {
      expect(SkinRegistry.classic.price, 0);
    });

    test('byId returns correct skin', () {
      final skin = SkinRegistry.byId('golden_dice');
      expect(skin, isNotNull);
      expect(skin!.name, 'Golden Dice');
      expect(skin.type, SkinType.dice);
    });

    test('byId returns null for unknown id', () {
      expect(SkinRegistry.byId('nonexistent'), null);
    });

    test('purchasable excludes free skins', () {
      final purchasable = SkinRegistry.purchasable;
      expect(purchasable.length, 4);
      expect(purchasable.any((s) => s.price == 0), false);
    });

    test('all skin IDs are unique', () {
      final ids = SkinRegistry.all.map((s) => s.id).toSet();
      expect(ids.length, SkinRegistry.all.length);
    });
  });
}
