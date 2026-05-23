import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../services/storage_service.dart';
import '../widgets/pin_pad.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final bio = await StorageService.isBiometricEnabled();
    if (!bio) return;
    final auth = LocalAuthentication();
    final ok = await auth.authenticate(
      localizedReason: 'Unlock app',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (ok) FlutterOverlayWindow.closeOverlay();
  }

  Future<bool> _verify(String pin) async {
    final stored = await StorageService.getPin();
    if (stored == pin) {
      FlutterOverlayWindow.closeOverlay();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.95),
      child: FutureBuilder<bool>(
        future: StorageService.isBiometricEnabled(),
        builder: (c, s) => PinPad(
          title: '🔒 App Locked',
          subtitle: 'Enter PIN to continue',
          onSubmit: _verify,
          showBiometric: s.data ?? false,
          onBiometric: _tryBiometric,
        ),
      ),
    );
  }
}