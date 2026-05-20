import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/services/ad_service.dart';

class MockRewardedAd extends Mock implements RewardedAd {}

class MockInterstitialAd extends Mock implements InterstitialAd {}

void main() {
  final service = AdService();

  setUp(() {
    service.rewardedAd = null;
    service.interstitialAd = null;
    service.isRewardedLoading = false;
    service.isInterstitialLoading = false;
  });

  group('AdService', () {
    group('state getters/setters', () {
      test('rewardedAd can be set and get', () {
        final mockAd = MockRewardedAd();
        service.rewardedAd = mockAd;
        expect(service.rewardedAd, same(mockAd));
      });

      test('interstitialAd can be set and get', () {
        final mockAd = MockInterstitialAd();
        service.interstitialAd = mockAd;
        expect(service.interstitialAd, same(mockAd));
      });

      test('isRewardedLoading can be set and get', () {
        service.isRewardedLoading = true;
        expect(service.isRewardedLoading, isTrue);
      });

      test('isInterstitialLoading can be set and get', () {
        service.isInterstitialLoading = true;
        expect(service.isInterstitialLoading, isTrue);
      });
    });

    group('dispose', () {
      test('disposes rewarded ad and clears reference', () async {
        final mockAd = MockRewardedAd();
        service.rewardedAd = mockAd;
        when(() => mockAd.dispose()).thenAnswer((_) async {});

        service.dispose();

        verify(() => mockAd.dispose()).called(1);
        expect(service.rewardedAd, isNull);
      });

      test('disposes interstitial ad and clears reference', () async {
        final mockAd = MockInterstitialAd();
        service.interstitialAd = mockAd;
        when(() => mockAd.dispose()).thenAnswer((_) async {});

        service.dispose();

        verify(() => mockAd.dispose()).called(1);
        expect(service.interstitialAd, isNull);
      });

      test('does not throw when no ads are loaded', () {
        expect(() => service.dispose(), returnsNormally);
      });

      test('disposes both ad types', () async {
        final rewarded = MockRewardedAd();
        final interstitial = MockInterstitialAd();
        service.rewardedAd = rewarded;
        service.interstitialAd = interstitial;
        when(() => rewarded.dispose()).thenAnswer((_) async {});
        when(() => interstitial.dispose()).thenAnswer((_) async {});

        service.dispose();

        verify(() => rewarded.dispose()).called(1);
        verify(() => interstitial.dispose()).called(1);
        expect(service.rewardedAd, isNull);
        expect(service.interstitialAd, isNull);
      });
    });

    group('loadRewardedAd', () {
      test('returns immediately when already loading', () async {
        service.isRewardedLoading = true;
        // Should not throw; loadRewardedAd returns early
        await service.loadRewardedAd();
        expect(service.isRewardedLoading, isTrue);
      });

      test('returns immediately when ad already loaded', () async {
        service.rewardedAd = MockRewardedAd();
        await service.loadRewardedAd();
        expect(service.rewardedAd, isNotNull);
      });
    });

    group('loadInterstitialAd', () {
      test('returns immediately when already loading', () async {
        service.isInterstitialLoading = true;
        await service.loadInterstitialAd();
        expect(service.isInterstitialLoading, isTrue);
      });

      test('returns immediately when ad already loaded', () async {
        service.interstitialAd = MockInterstitialAd();
        await service.loadInterstitialAd();
        expect(service.interstitialAd, isNotNull);
      });
    });
  });
}
