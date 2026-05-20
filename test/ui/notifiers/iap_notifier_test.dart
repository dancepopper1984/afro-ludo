import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/core/iap_registry.dart';
import 'package:afro_ludo_flutter/models/iap_product.dart';
import 'package:afro_ludo_flutter/services/iap_service.dart';
import 'package:afro_ludo_flutter/ui/notifiers/iap_notifier.dart';

class MockIapService extends Mock implements IapService {}

class MockPurchaseDetails extends Mock implements PurchaseDetails {}

class MockIAPError extends Mock implements IAPError {}

class FakePurchaseDetails extends Fake implements PurchaseDetails {}

class FakeIapProduct extends Fake implements IapProduct {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakePurchaseDetails());
  });

  late MockIapService mockService;
  late StreamController<PurchaseDetails> purchaseController;

  setUp(() {
    mockService = MockIapService();
    purchaseController = StreamController<PurchaseDetails>.broadcast();

    when(() => mockService.purchaseStream)
        .thenAnswer((_) => purchaseController.stream);
    when(() => mockService.init()).thenAnswer((_) async => true);
    when(() => mockService.queryProducts())
        .thenAnswer((_) async => IapRegistry.all);
    when(() => mockService.purchase(any())).thenAnswer((_) async => true);
    when(() => mockService.completePurchase(any()))
        .thenAnswer((_) async {});
    when(() => mockService.dispose()).thenReturn(null);
  });

  tearDown(() {
    purchaseController.close();
  });

  IapNotifier createNotifier({void Function(int)? onCompleted}) =>
      IapNotifier(
        iapService: mockService,
        onPurchaseCompleted: onCompleted,
      );

  group('IapNotifier', () {
    test('initial state is idle with empty products', () {
      final notifier = createNotifier();
      addTearDown(notifier.dispose);

      expect(notifier.state.status, IapUiStatus.idle);
      expect(notifier.state.products, isEmpty);
      expect(notifier.state.error, isNull);
      expect(notifier.state.lastPurchasedCoins, isNull);
    });

    group('init', () {
      test('sets ready when IAP available and products found', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);

        await notifier.init();

        expect(notifier.state.status, IapUiStatus.ready);
        expect(notifier.state.products, equals(IapRegistry.all));
      });

      test('sets error when IAP not available', () async {
        when(() => mockService.init()).thenAnswer((_) async => false);

        final notifier = createNotifier();
        addTearDown(notifier.dispose);

        await notifier.init();

        expect(notifier.state.status, IapUiStatus.error);
        expect(notifier.state.error, contains('not available'));
      });

      test('sets error when no products returned', () async {
        when(() => mockService.queryProducts())
            .thenAnswer((_) async => []);

        final notifier = createNotifier();
        addTearDown(notifier.dispose);

        await notifier.init();

        expect(notifier.state.status, IapUiStatus.error);
        expect(notifier.state.error, contains('No products'));
      });
    });

    group('purchase', () {
      test('returns false when not ready', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);

        final result = await notifier.purchase('afro_coins_500');
        expect(result, isFalse);
      });

      test('returns false when already purchasing', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();

        notifier.state = notifier.state.copyWith(status: IapUiStatus.purchasing);

        final result = await notifier.purchase('afro_coins_500');
        expect(result, isFalse);
      });

      test('initiates purchase and returns result', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();

        final result = await notifier.purchase('afro_coins_500');

        expect(result, isTrue);
        verify(() => mockService.purchase('afro_coins_500')).called(1);
      });

      test('sets error on exception', () async {
        when(() => mockService.purchase(any()))
            .thenThrow(Exception('network error'));

        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();

        final result = await notifier.purchase('afro_coins_500');

        expect(result, isFalse);
        expect(notifier.state.status, IapUiStatus.error);
      });
    });

    group('purchase stream handling', () {
      test('purchased status triggers success and callback', () async {
        int? receivedCoins;
        final notifier = createNotifier(
          onCompleted: (coins) => receivedCoins = coins,
        );
        addTearDown(notifier.dispose);
        await notifier.init();

        final details = MockPurchaseDetails();
        when(() => details.status).thenReturn(PurchaseStatus.purchased);
        when(() => details.productID).thenReturn('afro_coins_500');
        when(() => details.pendingCompletePurchase).thenReturn(true);

        purchaseController.add(details);
        await pumpEventQueue();

        expect(notifier.state.status, IapUiStatus.success);
        expect(notifier.state.lastPurchasedCoins, 500);
        expect(receivedCoins, 500);
        verify(() => mockService.completePurchase(details)).called(1);
      });

      test('restored status also triggers callback', () async {
        int? receivedCoins;
        final notifier = createNotifier(
          onCompleted: (coins) => receivedCoins = coins,
        );
        addTearDown(notifier.dispose);
        await notifier.init();

        final details = MockPurchaseDetails();
        when(() => details.status).thenReturn(PurchaseStatus.restored);
        when(() => details.productID).thenReturn('afro_coins_1200');
        when(() => details.pendingCompletePurchase).thenReturn(false);

        purchaseController.add(details);
        await pumpEventQueue();

        expect(notifier.state.status, IapUiStatus.success);
        expect(receivedCoins, 1200);
      });

      test('pending status sets purchasing', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();

        final details = MockPurchaseDetails();
        when(() => details.status).thenReturn(PurchaseStatus.pending);

        purchaseController.add(details);
        await pumpEventQueue();

        expect(notifier.state.status, IapUiStatus.purchasing);
      });

      test('canceled status returns to ready', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();

        final details = MockPurchaseDetails();
        when(() => details.status).thenReturn(PurchaseStatus.canceled);

        purchaseController.add(details);
        await pumpEventQueue();

        expect(notifier.state.status, IapUiStatus.ready);
      });

      test('error status sets error state', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();

        final error = MockIAPError();
        when(() => error.message).thenReturn('billing error');

        final details = MockPurchaseDetails();
        when(() => details.status).thenReturn(PurchaseStatus.error);
        when(() => details.error).thenReturn(error);

        purchaseController.add(details);
        await pumpEventQueue();

        expect(notifier.state.status, IapUiStatus.error);
        expect(notifier.state.error, contains('billing error'));
      });

      test('unknown product ID does not crash', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();

        final details = MockPurchaseDetails();
        when(() => details.status).thenReturn(PurchaseStatus.purchased);
        when(() => details.productID).thenReturn('unknown_product');
        when(() => details.pendingCompletePurchase).thenReturn(true);

        purchaseController.add(details);
        await pumpEventQueue();

        expect(notifier.state.status, IapUiStatus.success);
        expect(notifier.state.lastPurchasedCoins, isNull);
      });
    });

    group('reset', () {
      test('from success resets to ready', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();
        notifier.state = notifier.state.copyWith(
          status: IapUiStatus.success,
          lastPurchasedCoins: 500,
        );

        notifier.reset();

        expect(notifier.state.status, IapUiStatus.ready);
        expect(notifier.state.lastPurchasedCoins, isNull);
        expect(notifier.state.error, isNull);
      });

      test('from error resets to ready', () async {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        await notifier.init();
        notifier.state = notifier.state.copyWith(
          status: IapUiStatus.error,
          error: 'some error',
        );

        notifier.reset();

        expect(notifier.state.status, IapUiStatus.ready);
        expect(notifier.state.error, isNull);
      });

      test('does nothing from other states', () {
        final notifier = createNotifier();
        addTearDown(notifier.dispose);
        notifier.state = notifier.state.copyWith(status: IapUiStatus.loading);

        notifier.reset();

        expect(notifier.state.status, IapUiStatus.loading);
      });
    });

    group('dispose', () {
      test('cancels subscription and disposes service', () {
        final notifier = createNotifier();
        notifier.dispose();

        verify(() => mockService.dispose()).called(1);
      });
    });
  });
}
