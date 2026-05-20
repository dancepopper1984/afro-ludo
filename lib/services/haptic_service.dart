import 'package:flutter/services.dart';

/// 触觉反馈服务
///
/// 封装 Flutter HapticFeedback，受设置中的 hapticsEnabled 控制。
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool hapticsEnabled = true;

  void _feedback(void Function() action) {
    if (hapticsEnabled) action();
  }

  /// 轻触（按钮点击等）
  void light() => _feedback(HapticFeedback.lightImpact);

  /// 中强触（棋子移动等）
  void medium() => _feedback(HapticFeedback.mediumImpact);

  /// 强触（吃子、胜利等）
  void heavy() => _feedback(HapticFeedback.heavyImpact);

  /// 选择变化触（骰子结果、切换选项）
  void selection() => _feedback(HapticFeedback.selectionClick);

  /// 成功触（棋子到家、胜利）
  void success() => _feedback(HapticFeedback.vibrate);
}
