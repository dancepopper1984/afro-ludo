import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_frequency_controller.dart';

/// 广告服务
///
/// 封装 AdMob 激励视频、插页广告和 Banner 广告。
/// 使用测试 ID，上架前必须替换为生产 ID。
/// 插页广告通过 AdFrequencyController 控制频次。
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _isRewardedLoading = false;
  bool _isInterstitialLoading = false;

  final _interstitialController = AdFrequencyController.interstitial();
  final _bannerController = AdFrequencyController.banner();

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
  BannerAd? get bannerAd => _bannerAd;

  @visibleForTesting
  set bannerAd(BannerAd? ad) => _bannerAd = ad;

  @visibleForTesting
  bool get isRewardedLoading => _isRewardedLoading;

  @visibleForTesting
  set isRewardedLoading(bool value) => _isRewardedLoading = value;

  @visibleForTesting
  bool get isInterstitialLoading => _isInterstitialLoading;

  @visibleForTesting
  set isInterstitialLoading(bool value) => _isInterstitialLoading = value;

  // === 广告单元 ID（生产环境） ===
  static const String _rewardedAdUnitId =
      'ca-app-pub-7765853410525635/9477687349';
  static const String _interstitialAdUnitId =
      'ca-app-pub-7765853410525635/2950595993';
  static const String _bannerAdUnitId =
      'ca-app-pub-7765853410525635/4263677669';

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

  /// 展示插页广告（自动受频次控制）
  ///
  /// 如果频次控制器不允许展示，直接调用 [onDismissed] 不展示广告。
  Future<void> showInterstitialAd({void Function()? onDismissed}) async {
    if (!_interstitialController.canShow()) {
      onDismissed?.call();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      await loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    _interstitialController.recordShow();

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

  // === Banner 广告 ===

  /// 加载 Banner 广告
  ///
  /// 返回 BannerAd widget 用于嵌入界面底部。
  /// 如果频次控制器已达今日上限，返回 null。
  BannerAd? createBannerAd({
    required AdSize size,
    void Function(Ad)? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad,
  }) {
    if (!_bannerController.canShow()) return null;

    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          onAdFailedToLoad?.call(error);
        },
      ),
    );

    ad.load();
    _bannerController.recordShow();
    return ad;
  }

  // === 释放 ===

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
