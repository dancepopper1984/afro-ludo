import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 分享服务
///
/// 支持 WhatsApp 直接分享和系统级分享 fallback。
class ShareService {
  ShareService._();

  /// 分享战绩到 WhatsApp
  ///
  /// [text] 要分享的文本内容。
  /// 如果 WhatsApp 未安装，自动降级为系统分享。
  static Future<void> shareToWhatsApp(String text) async {
    final whatsappUrl = _buildWhatsAppUrl(text);
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return;
    }

    await Share.share(text);
  }

  /// 生成战绩分享文本（纯文本，不触发分享）
  static String buildGameResultText({
    required String gameName,
    required int position,
    int totalPlayers = 4,
    String? extra,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('I just played $gameName on Afro Ludo!');

    if (position == 1) {
      buffer.writeln('I WON 1st place out of $totalPlayers players!');
    } else {
      buffer.writeln('I finished #$position out of $totalPlayers players.');
    }

    if (extra != null && extra.isNotEmpty) {
      buffer.writeln(extra);
    }

    buffer.writeln();
    buffer.write('Download Afro Ludo and challenge me!');

    return buffer.toString();
  }

  /// 分享战绩（便捷方法）
  static Future<void> shareGameResult({
    required String gameName,
    required int position,
    int totalPlayers = 4,
    String? extra,
  }) async {
    final text = buildGameResultText(
      gameName: gameName,
      position: position,
      totalPlayers: totalPlayers,
      extra: extra,
    );
    await shareToWhatsApp(text);
  }

  static Uri _buildWhatsAppUrl(String text) {
    final encoded = Uri.encodeComponent(text);
    if (kIsWeb) {
      return Uri.parse('https://wa.me/?text=$encoded');
    }
    if (Platform.isIOS) {
      return Uri.parse('whatsapp://send?text=$encoded');
    }
    return Uri.parse('https://wa.me/?text=$encoded');
  }
}
