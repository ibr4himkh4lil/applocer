import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../services/app_list_service.dart';
import '../services/storage_service.dart';

class LockProvider extends ChangeNotifier {
  List<AppInfo> _apps = [];
  Set<String> _locked = {};
  bool _loading = false;
  String _query = '';

  List<AppInfo> get apps {
    if (_query.isEmpty) return _apps;
    return _apps
        .where((a) => a.appName.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  bool get loading => _loading;
  int get lockedCount => _locked.length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _apps = await AppListService.getAllApps();
    _locked = await StorageService.getLockedApps();
    _loading = false;
    notifyListeners();
  }

  Future<void> toggle(AppInfo app) async {
    await AppListService.toggleLock(app.packageName);
    _locked = await StorageService.getLockedApps();
    _apps = _apps
        .map((a) => a.packageName == app.packageName
            ? a.copyWith(isLocked: _locked.contains(a.packageName))
            : a)
        .toList();
    notifyListeners();
  }

  void search(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> lockAll() async {
    final pkgs = _apps.map((a) => a.packageName).toSet();
    await StorageService.saveLockedApps(pkgs);
    _locked = pkgs;
    _apps = _apps.map((a) => a.copyWith(isLocked: true)).toList();
    notifyListeners();
  }

  Future<void> unlockAll() async {
    await StorageService.saveLockedApps({});
    _locked = {};
    _apps = _apps.map((a) => a.copyWith(isLocked: false)).toList();
    notifyListeners();
  }
}