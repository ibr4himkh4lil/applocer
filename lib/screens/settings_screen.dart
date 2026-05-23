import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/storage_service.dart';
import 'setup_pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bio = false;
  bool _bioAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = LocalAuthentication();
    final can = await auth.canCheckBiometrics && await auth.isDeviceSupported();
    final enabled = await StorageService.isBiometricEnabled();
    setState(() {
      _bioAvailable = can;
      _bio = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Unlock'),
            subtitle: Text(_bioAvailable
                ? 'Use fingerprint/face to unlock'
                : 'Biometric not available'),
            value: _bio,
            onChanged: _bioAvailable
                ? (v) async {
                    await StorageService.setBiometric(v);
                    setState(() => _bio = v);
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('Change PIN'),
            onTap: () async {
              await StorageService.setSetupDone(false);
              if (!mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const SetupPinScreen()));
            },
          ),
        ],
      ),
    );
  }
}