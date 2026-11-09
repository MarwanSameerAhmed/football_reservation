import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Locale locale;

  const ThemeState({required this.themeMode, required this.locale});

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';

  ThemeState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(const ThemeState(themeMode: ThemeMode.light, locale: Locale('ar')));

  void toggleTheme() {
    emit(
      state.copyWith(
        themeMode: state.themeMode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light,
      ),
    );
  }

  void toggleLanguage() {
    emit(
      state.copyWith(
        locale: state.locale.languageCode == 'ar'
            ? const Locale('en')
            : const Locale('ar'),
      ),
    );
  }
}
