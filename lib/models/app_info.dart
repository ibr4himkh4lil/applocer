import 'dart:typed_data';

class AppInfo {
  final String packageName;
  final String appName;
  final bool isSystem;
  final bool isLocked;
  final Uint8List? icon;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.isSystem = false,
    this.isLocked = false,
    this.icon,
  });

  AppInfo copyWith({bool? isLocked}) => AppInfo(
        packageName: packageName,
        appName: appName,
        isSystem: isSystem,
        isLocked: isLocked ?? this.isLocked,
        icon: icon,
      );
}