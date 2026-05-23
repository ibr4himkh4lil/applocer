import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const kPinKey = 'master_pin';
  static const kBiometricKey = 'biometric_enabled';
  static const kLockedAppsKey = 'locked_apps';
  static const kSetupDoneKey = 'setup_done';

  static Future<void> savePin(String pin) =>
      _secure.write(key: kPinKey, value: pin);

  static Future<String?> getPin() => _secure.read(key: kPinKey);

  static Future<void> setBiometric(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(kBiometricKey, v);
  }

  static Future<bool> isBiometricEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(kBiometricKey) ?? false;
  }

  static Future<void> saveLockedApps(Set<String> pkgs) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(kLockedAppsKey, pkgs.toList());
  }

  static Future<Set<String>> getLockedApps() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(kLockedAppsKey) ?? []).toSet();
  }

  static Future<void> setSetupDone(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(kSetupDoneKey, v);
  }

  static Future<bool> isSetupDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(kSetupDoneKey) ?? false;
  }
}