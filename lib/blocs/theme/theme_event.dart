import 'package:equatable/equatable.dart';
import 'package:chatroom_app/config/themes.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ChangeTheme extends ThemeEvent {
  final ThemeType themeType;

  const ChangeTheme(this.themeType);

  @override
  List<Object> get props => [themeType];
}
