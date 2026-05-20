import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/core/skin_registry.dart';

void main() {
  group('SkinRegistry', () {
    test('contains classic skin', () {
      expect(SkinRegistry.byId('classic'), isNotNull);
    });

    test('contains all 5 skins', () {
      expect(SkinRegistry.all.length, equals(5));
    });

    test('byId returns correct skin', () {
      final skin = SkinRegistry.byId('neon');
      expect(skin?.name, equals('Neon Board'));
      expect(skin?.price, equals(1000));
    });

    test('byId returns null for unknown id', () {
      expect(SkinRegistry.byId('unknown'), isNull);
    });

    test('purchasable excludes free classic skin', () {
      final purchasable = SkinRegistry.purchasable;
      expect(purchasable.any((s) => s.id == 'classic'), isFalse);
      expect(purchasable.length, equals(4));
    });

    test('classic skin is free', () {
      expect(SkinRegistry.classic.price, equals(0));
    });
  });
}
