import 'package:flutter/services.dart';

class UsageStatsService {
  static const _channel = MethodChannel('com.applocker/usage');

  static Future<String?> getForegroundApp() async {
    try {
      return await _channel.invokeMethod<String>('getForegroundApp');
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasUsagePermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openUsageSettings() =>
      _channel.invokeMethod('openUsageSettings');

  static Future<void> requestOverlayPermission() =>
      _channel.invokeMethod('requestOverlayPermission');

  static Future<bool> hasOverlayPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
    } catch (_) {
      return false;
    }
  }
}