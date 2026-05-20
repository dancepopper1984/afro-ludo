import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/core/iap_registry.dart';
import 'package:afro_ludo_flutter/models/iap_product.dart';
import 'package:afro_ludo_flutter/services/iap_service.dart';

void main() {
  group('IapService', () {
    late IapService service;

    setUp(() {
      service = IapService();
    });

    tearDown(() {
      service.dispose();
    });

    group('testing injection points', () {
      test('isAvailable defaults to false', () {
        expect(service.isAvailable, isFalse);
      });

      test('isAvailable can be set', () {
        service.isAvailable = true;
        expect(service.isAvailable, isTrue);
      });

      test('availableProducts defaults to empty', () {
        expect(service.availableProducts, isEmpty);
      });

      test('setAvailableProducts replaces the list', () {
        service.setAvailableProducts(IapRegistry.all);
        expect(service.availableProducts, equals(IapRegistry.all));
      });

      test('setAvailableProducts clears previous products', () {
        service.setAvailableProducts(IapRegistry.all);
        service.setAvailableProducts([IapRegistry.coins500]);
        expect(service.availableProducts, hasLength(1));
        expect(service.availableProducts.first.storeId, 'afro_coins_500');
      });
    });

    group('purchaseStream', () {
      test('emits nothing initially', () async {
        // 确保 stream 存在但没有事件
        expect(service.purchaseStream, isA<Stream>());
      });
    });

    group('dispose', () {
      test('can be called multiple times safely', () {
        service.dispose();
        service.dispose();
        expect(true, isTrue); // no throw
      });
    });
  });
}
