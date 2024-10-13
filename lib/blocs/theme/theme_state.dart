import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:chatroom_app/config/themes.dart';

class ThemeState extends Equatable {
  final ThemeData themeData;
  final ThemeType themeType;
  final Color primaryColor;

  const ThemeState({
    required this.themeData,
    required this.themeType,
    required this.primaryColor,
  });

  @override
  List<Object> get props => [themeData, themeType, primaryColor];
}
