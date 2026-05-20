import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/skin_registry.dart';
import '../../models/skin.dart';
import '../../services/storage_service.dart';

/// 皮肤状态
class SkinState {
  final Skin activeSkin;
  final List<String> unlockedIds;
  final Set<String> pendingPurchase; // 正在处理中的购买（防连点）

  const SkinState({
    required this.activeSkin,
    required this.unlockedIds,
    this.pendingPurchase = const {},
  });

  SkinState copyWith({
    Skin? activeSkin,
    List<String>? unlockedIds,
    Set<String>? pendingPurchase,
  }) =>
      SkinState(
        activeSkin: activeSkin ?? this.activeSkin,
        unlockedIds: unlockedIds ?? this.unlockedIds,
        pendingPurchase: pendingPurchase ?? this.pendingPurchase,
      );

  bool isUnlocked(String skinId) => unlockedIds.contains(skinId);

  bool isEquipped(String skinId) => activeSkin.id == skinId;
}

/// 皮肤状态管理
///
/// 负责：
/// - 从本地存储加载已解锁/当前皮肤
/// - 购买皮肤（检查余额、扣款、解锁）
/// - 装备皮肤
class SkinNotifier extends StateNotifier<SkinState> {
  SkinNotifier() : super(SkinState(
    activeSkin: SkinRegistry.classic,
    unlockedIds: const ['classic'],
  )) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final activeId = StorageService.getActiveSkin() ?? 'classic';
    final unlocked = StorageService.getUnlockedSkins() ?? ['classic'];

    state = SkinState(
      activeSkin: SkinRegistry.byId(activeId) ?? SkinRegistry.classic,
      unlockedIds: List<String>.from(unlocked),
    );
  }

  /// 购买皮肤（返回是否成功）
  bool buySkin(String skinId, {required int balance, required int Function(int) deduct}) {
    if (state.pendingPurchase.contains(skinId)) return false;
    if (state.isUnlocked(skinId)) return false;

    final skin = SkinRegistry.byId(skinId);
    if (skin == null) return false;
    if (balance < skin.price) return false;

    // 标记购买中
    state = state.copyWith(
      pendingPurchase: {...state.pendingPurchase, skinId},
    );

    // 扣款
    final newBalance = deduct(skin.price);
    if (newBalance < 0) {
      // 扣款失败，回滚
      state = state.copyWith(
        pendingPurchase: state.pendingPurchase.difference({skinId}),
      );
      return false;
    }

    // 解锁并装备
    final unlocked = [...state.unlockedIds, skinId];
    StorageService.setUnlockedSkins(unlocked);
    StorageService.setActiveSkin(skinId);

    state = SkinState(
      activeSkin: skin,
      unlockedIds: unlocked,
      pendingPurchase: state.pendingPurchase.difference({skinId}),
    );
    return true;
  }

  /// 装备已拥有的皮肤
  bool equipSkin(String skinId) {
    if (!state.isUnlocked(skinId)) return false;
    if (state.isEquipped(skinId)) return true;

    final skin = SkinRegistry.byId(skinId);
    if (skin == null) return false;

    StorageService.setActiveSkin(skinId);
    state = state.copyWith(activeSkin: skin);
    return true;
  }
}

final skinNotifierProvider = StateNotifierProvider<SkinNotifier, SkinState>(
  (ref) => SkinNotifier(),
);
