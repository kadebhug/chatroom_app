import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/theme/theme_bloc.dart';
import 'package:chatroom_app/blocs/theme/theme_event.dart';
import 'package:chatroom_app/config/themes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeType>(
              value: context.read<ThemeBloc>().state.themeType,
              onChanged: (ThemeType? newValue) {
                if (newValue != null) {
                  context.read<ThemeBloc>().add(ChangeTheme(newValue));
                }
              },
              items: ThemeType.values.map((ThemeType type) {
                return DropdownMenuItem<ThemeType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
