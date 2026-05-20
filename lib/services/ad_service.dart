import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 广告服务
///
/// 封装 AdMob 激励视频和插页广告。
/// 使用测试 ID，上架前必须替换为生产 ID。
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isRewardedLoading = false;
  bool _isInterstitialLoading = false;

  // === 测试注入点 ===

  @visibleForTesting
  RewardedAd? get rewardedAd => _rewardedAd;

  @visibleForTesting
  set rewardedAd(RewardedAd? ad) => _rewardedAd = ad;

  @visibleForTesting
  InterstitialAd? get interstitialAd => _interstitialAd;

  @visibleForTesting
  set interstitialAd(InterstitialAd? ad) => _interstitialAd = ad;

  @visibleForTesting
  bool get isRewardedLoading => _isRewardedLoading;

  @visibleForTesting
  set isRewardedLoading(bool value) => _isRewardedLoading = value;

  @visibleForTesting
  bool get isInterstitialLoading => _isInterstitialLoading;

  @visibleForTesting
  set isInterstitialLoading(bool value) => _isInterstitialLoading = value;

  // === 广告单元 ID ===
  // TODO: 上架前替换为生产环境 ID
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // 测试 ID
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // 测试 ID

  // === 初始化 ===

  static Future<InitializationStatus> init() {
    return MobileAds.instance.initialize();
  }

  // === 激励视频 ===

  /// 预加载激励视频广告
  Future<void> loadRewardedAd() async {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// 展示激励视频广告
  ///
  /// [onRewarded] 用户完整看完广告后回调，参数为奖励金额
  Future<void> showRewardedAd({
    required void Function(int amount) onRewarded,
    void Function()? onDismissed,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) {
      // 广告未准备好，尝试重新加载
      await loadRewardedAd();
      onDismissed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        // 预加载下一条
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward.amount.toInt());
      },
    );
  }

  // === 插页广告 ===

  /// 预加载插页广告
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// 展示插页广告
  Future<void> showInterstitialAd({void Function()? onDismissed}) async {
    final ad = _interstitialAd;
    if (ad == null) {
      await loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
      },
    );

    ad.show();
  }

  // === 释放 ===

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
