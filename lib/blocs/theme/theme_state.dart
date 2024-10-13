import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:chatroom_app/config/themes.dart';

class ThemeState extends Equatable {
  final ThemeData themeData;
  final ThemeType themeType;

  const ThemeState({required this.themeData, required this.themeType});

  @override
  List<Object> get props => [themeData, themeType];
}
