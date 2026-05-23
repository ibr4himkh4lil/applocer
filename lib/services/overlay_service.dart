import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'storage_service.dart';
import 'usage_stats_service.dart';

class OverlayService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationId: 98765,
        initialNotificationTitle: 'App Locker',
        initialNotificationContent: 'Protecting your apps',
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((_) => service.setAsForegroundService());
    service.on('setAsBackground').listen((_) => service.setAsBackgroundService());
    service.on('stop').listen((_) {
      service.stopSelf();
    });
  }

  String? lastPkg;
  while (true) {
    try {
      final fg = await UsageStatsService.getForegroundApp();
      final locked = await StorageService.getLockedApps();
      final ownPkg = 'com.yourname.applocker'; // <-- change to yours

      if (fg != null &&
          fg != lastPkg &&
          fg != ownPkg &&
          locked.contains(fg)) {
        lastPkg = fg;
        FlutterOverlayWindow.showOverlay(
          enableDrag: false,
          overlayTitle: "Locked",
          overlayContent: "Authentication required",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.public,
          positionGravity: Gravity.none,
          height: WindowSize.matchParent,
          width: WindowSize.matchParent,
        );
      } else if (fg != null && fg == ownPkg) {
        lastPkg = fg;
        FlutterOverlayWindow.closeOverlay();
      } else if (fg != null) {
        lastPkg = fg;
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 700));
  }
}