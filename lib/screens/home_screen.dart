import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/lock_provider.dart';
import '../services/storage_service.dart';
import '../services/usage_stats_service.dart';
import '../services/overlay_service.dart';
import '../widgets/pin_pad.dart';
import 'app_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _authed = false;
  bool _serviceRunning = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<LockProvider>().load();
    await OverlayService.initialize();
    _checkPerms();
  }

  Future<void> _checkPerms() async {
    final usage = await UsageStatsService.hasUsagePermission();
    final overlay = await UsageStatsService.hasOverlayPermission();
    if (!usage) await UsageStatsService.openUsageSettings();
    if (!overlay) await UsageStatsService.requestOverlayPermission();
  }

  Future<bool> _verifyPin(String pin) async {
    final stored = await StorageService.getPin();
    if (stored == pin) {
      setState(() => _authed = true);
      return true;
    }
    return false;
  }

  Future<void> _biometric() async {    final auth = LocalAuthentication();
    final can = await auth.canCheckBiometrics && await auth.isDeviceSupported();
    if (!can) return;
    final ok = await auth.authenticate(
      localizedReason: 'Unlock App Locker',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (ok && mounted) setState(() => _authed = true);
  }

  Future<void> _toggleService() async {
    if (_serviceRunning) {
      await OverlayService.stop();
    } else {
      await OverlayService.start();
    }
    setState(() => _serviceRunning = !_serviceRunning);
  }

  @override
  Widget build(BuildContext context) {
    if (!_authed) {
      return Scaffold(
        body: FutureBuilder<bool>(
          future: StorageService.isBiometricEnabled(),
          builder: (c, s) {
            final bio = s.data ?? false;
            return PinPad(
              title: 'Unlock App Locker',
              onSubmit: _verifyPin,
              showBiometric: bio,
              onBiometric: _biometric,
            );
          },
        ),
      );
    }

    final p = context.watch<LockProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Locker'),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
      body: RefreshIndicator(        onRefresh: p.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _statCard(context, p),
            const SizedBox(height: 16),
            _serviceCard(context),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              icon: const Icon(Icons.apps),
              label: const Text('Manage Locked Apps'),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AppListScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, LockProvider p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.shield,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text('${p.lockedCount}',
                style: Theme.of(context).textTheme.displaySmall),
            const Text('Apps Protected'),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(BuildContext context) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(
          _serviceRunning ? Icons.play_circle : Icons.pause_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Protection Active'),
        subtitle: Text(_serviceRunning
            ? 'Monitoring apps in background'            : 'Tap to start protection'),
        value: _serviceRunning,
        onChanged: (_) => _toggleService(),
      ),
    );
  }
}