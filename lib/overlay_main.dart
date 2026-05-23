import 'package:flutter/material.dart';
import 'screens/lock_screen.dart';

@pragma('vm:entry-point')
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LockScreen(),
  ));
}