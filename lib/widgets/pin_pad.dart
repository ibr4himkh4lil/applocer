import 'package:flutter/material.dart';

class PinPad extends StatefulWidget {
  final int length;
  final String title;
  final String subtitle;
  final Future<bool> Function(String) onSubmit;
  final VoidCallback? onBiometric;
  final bool showBiometric;

  const PinPad({
    super.key,
    this.length = 4,
    this.title = 'Enter PIN',
    this.subtitle = '',
    required this.onSubmit,
    this.onBiometric,
    this.showBiometric = false,
  });

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';
  bool _shaking = false;
  bool _processing = false;

  void _onKey(String k) async {
    if (_processing) return;
    if (k == 'del') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
      return;
    }
    if (_pin.length >= widget.length) return;
    final newPin = _pin + k;
    setState(() => _pin = newPin);
    if (newPin.length == widget.length) {
      setState(() => _processing = true);
      final ok = await widget.onSubmit(newPin);
      if (!ok && mounted) {
        setState(() {
          _shaking = true;
          _pin = '';
          _processing = false;
        });
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) setState(() => _shaking = false);
      }    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.lock, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(widget.title, style: theme.textTheme.headlineSmall),
          if (widget.subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(widget.subtitle,
                  style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _shaking
                ? Padding(
                    key: const ValueKey('shake'),
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          widget.length, (_) => _dot(filled: false, error: true)),
                    ),
                  )
                : Padding(
                    key: const ValueKey('normal'),
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(widget.length, (i) {
                        return _dot(filled: i < _pin.length);
                      }),
                    ),
                  ),
          ),
          const Spacer(),
          _buildKeypad(theme),
          const SizedBox(height: 24),
        ],
      ),
    );  }

  Widget _dot({required bool filled, bool error = false}) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: error
              ? Colors.red
              : filled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          border: Border.all(
            color: error
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      );

  Widget _buildKeypad(ThemeData theme) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Column(
      children: [
        ...keys.map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((k) => _key(k, theme)).toList(),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.showBiometric)
              _iconKey(Icons.fingerprint, () => widget.onBiometric?.call(), theme)
            else
              const SizedBox(width: 80, height: 80),
            _key('0', theme),
            _iconKey(Icons.backspace_outlined, () => _onKey('del'), theme),
          ],
        ),
      ],
    );
  }

  Widget _key(String k, ThemeData theme) => SizedBox(        width: 80,
        height: 80,
        child: TextButton(
          style: TextButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          onPressed: () => _onKey(k),
          child: Text(k, style: theme.textTheme.headlineMedium),
        ),
      );

  Widget _iconKey(IconData icon, VoidCallback onTap, ThemeData theme) =>
      SizedBox(
        width: 80,
        height: 80,
        child: IconButton(
          icon: Icon(icon, size: 30, color: theme.colorScheme.primary),
          onPressed: onTap,
        ),
      );
}