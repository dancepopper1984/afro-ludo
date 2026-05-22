import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_frequency_controller.dart';

/// Banner 广告组件
///
/// 通过 AdFrequencyController 控制展示频率，防止用户流失。
/// 仅在 canShow() 通过时才展示 Banner。
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static const String _adUnitId =
      'ca-app-pub-7765853410525635/4263677669'; // 生产 Banner ID
  static final _controller = AdFrequencyController.banner();

  BannerAd? _bannerAd;
  bool _canShow = false;

  @override
  void initState() {
    super.initState();
    _canShow = _controller.canShow();
    if (_canShow) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    final ad = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() {});
          _controller.recordShow();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canShow || _bannerAd == null) return const SizedBox.shrink();

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
