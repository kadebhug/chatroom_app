import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
              value: context.watch<ThemeBloc>().state.themeType,
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
          ListTile(
            title: const Text('Primary Color'),
            trailing: GestureDetector(
              onTap: () => _showColorPicker(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.watch<ThemeBloc>().state.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: context.read<ThemeBloc>().state.primaryColor,
              onColorChanged: (Color color) {
                context.read<ThemeBloc>().add(ChangePrimaryColor(color));
              },
              availableColors: AppTheme.predefinedColors,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
