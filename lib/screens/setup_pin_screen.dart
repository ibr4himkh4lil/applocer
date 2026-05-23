import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/pin_pad.dart';
import 'home_screen.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});
  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String? _first;
  bool _confirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PinPad(
        title: _confirm ? 'Confirm PIN' : 'Create a PIN',
        subtitle: _confirm ? 'Re-enter your PIN' : 'Choose a 4-digit PIN',
        onSubmit: (pin) async {
          if (!_confirm) {
            setState(() {
              _first = pin;
              _confirm = true;
            });
            return true;
          }
          if (pin == _first) {
            await StorageService.savePin(pin);
            await StorageService.setSetupDone(true);
            if (!mounted) return true;
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            return true;
          }
          return false;
        },
      ),
    );
  }
}