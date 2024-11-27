import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppTheme {
  const AppTheme._();
  static final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade800,
        secondary: Colors.orange.shade800,
        surface: Colors.grey.shade900,
        background: const Color(0xFF121212),
        error: Colors.red.shade800,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ));
  static final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.orange.shade900,
        surface: Colors.white,
        background: const Color(0xFFEDF0F5),
        error: Colors.red.shade800,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ));
  static Brightness get currentSystemBrightness {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness;
  }
}
