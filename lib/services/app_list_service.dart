import 'package:installed_apps/installed_apps.dart';
import '../models/app_info.dart';
import 'storage_service.dart';

class AppListService {
  static Future<List<AppInfo>> getAllApps() async {
    final locked = await StorageService.getLockedApps();
    
    final apps = await InstalledApps.getInstalledApps(true, false);
    
    final list = apps.map((a) {
      return AppInfo(
        packageName: a.packageName ?? '',
        appName: a.name ?? '',
        isSystem: a.isSystemApp ?? false,
        isLocked: locked.contains(a.packageName),
        icon: a.icon,
      );
    }).toList();
    
    list.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    return list;
  }

  static Future<void> toggleLock(String pkg) async {
    final locked = await StorageService.getLockedApps();
    locked.contains(pkg) ? locked.remove(pkg) : locked.add(pkg);
    await StorageService.saveLockedApps(locked);
  }
}
