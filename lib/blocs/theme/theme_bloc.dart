import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatroom_app/config/themes.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;

  ThemeBloc(this.prefs) : super(ThemeState(themeData: AppTheme.lightTheme, themeType: ThemeType.light)) {
    on<ChangeTheme>(_onChangeTheme);
    _loadSavedTheme();
  }

  void _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    final themeData = AppTheme.getThemeFromType(event.themeType);
    emit(ThemeState(themeData: themeData, themeType: event.themeType));
    _saveTheme(event.themeType);
  }

  void _loadSavedTheme() {
    final savedThemeIndex = prefs.getInt('theme') ?? 0;
    final savedThemeType = ThemeType.values[savedThemeIndex];
    add(ChangeTheme(savedThemeType));
  }

  Future<void> _saveTheme(ThemeType themeType) async {
    await prefs.setInt('theme', themeType.index);
  }
}
