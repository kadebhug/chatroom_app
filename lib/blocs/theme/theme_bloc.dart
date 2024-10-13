import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatroom_app/config/themes.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;

  ThemeBloc(this.prefs)
      : super(ThemeState(
          themeData: AppTheme.getThemeFromType(ThemeType.light, Colors.blue),
          themeType: ThemeType.light,
          primaryColor: Colors.blue,
        )) {
    on<ChangeTheme>(_onChangeTheme);
    on<ChangePrimaryColor>(_onChangePrimaryColor);
    _loadSavedTheme();
  }

  void _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) {
    final themeData = AppTheme.getThemeFromType(event.themeType, state.primaryColor);
    emit(ThemeState(themeData: themeData, themeType: event.themeType, primaryColor: state.primaryColor));
    _saveTheme(event.themeType, state.primaryColor);
  }

  void _onChangePrimaryColor(ChangePrimaryColor event, Emitter<ThemeState> emit) {
    final themeData = AppTheme.getThemeFromType(state.themeType, event.color);
    emit(ThemeState(themeData: themeData, themeType: state.themeType, primaryColor: event.color));
    _saveTheme(state.themeType, event.color);
  }

  void _loadSavedTheme() {
    final savedThemeIndex = prefs.getInt('themeType') ?? 0;
    final savedThemeType = ThemeType.values[savedThemeIndex];
    final savedPrimaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
    add(ChangeTheme(savedThemeType));
    add(ChangePrimaryColor(savedPrimaryColor));
  }

  Future<void> _saveTheme(ThemeType themeType, Color primaryColor) async {
    await prefs.setInt('themeType', themeType.index);
    await prefs.setInt('primaryColor', primaryColor.value);
  }
}
