import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

/// Crashlytics 服务
///
/// Firebase Crashlytics 初始化与错误上报。
/// 捕获 Flutter 框架异常和 Dart 异步异常。
class CrashlyticsService {
  static bool _initialized = false;

  /// 初始化 Firebase 和 Crashlytics
  ///
  /// 如果 Firebase 未配置（缺少 google-services.json），静默跳过。
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      // 捕获 Flutter 框架异常
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // 捕获 Dart 异步异常
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      _initialized = true;
    } catch (_) {
      // Firebase 未配置，跳过初始化
    }
  }

  /// 手动记录非致命错误
  static void recordError(dynamic exception, StackTrace? stack,
      {String? reason}) {
    FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      fatal: false,
    );
  }

  /// 设置用户标识（可选，用于追踪特定用户的崩溃）
  static void setUserId(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// 添加自定义键值对上下文（可选）
  static void setCustomKey(String key, String value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }
}
