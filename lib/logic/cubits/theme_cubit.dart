import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeState {
  ThemeState({required this.themeMode});

  ThemeMode themeMode;

  Map<String, dynamic> toJson() => {'themeMode': themeMode.name};

  ThemeState.fromJson(Map<String, dynamic> json)
      : themeMode = ThemeMode.values.firstWhere((e) => e.name == json['themeMode']);

  @override
  String toString() => 'theme: $themeMode';
}

class ThemeCubit extends Cubit<ThemeState> with HydratedMixin {
  ThemeCubit() : super(ThemeState(themeMode: ThemeMode.light)) {
    hydrate();
  }

  void setTheme(bool isDark) {
    emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  @override
  ThemeState fromJson(Map<String, dynamic> json) {
    return ThemeState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(ThemeState state) {
    return state.toJson();
  }
}

ThemeMode get initialTheme {
  var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  if (brightness == Brightness.dark) {
    return ThemeMode.dark;
  }
  return ThemeMode.light;
}
