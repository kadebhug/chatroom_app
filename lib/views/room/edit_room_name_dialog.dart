import 'package:chatroom_app/models/room.dart';
import 'package:flutter/material.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditRoomNameDialog extends StatefulWidget {
  final Room room;

  const EditRoomNameDialog({Key? key, required this.room}) : super(key: key);

  @override
  _EditRoomNameDialogState createState() => _EditRoomNameDialogState();
}

class _EditRoomNameDialogState extends State<EditRoomNameDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.room.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Room Name'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'New Room Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newName = _nameController.text.trim();
            if (newName.isNotEmpty) {
              context.read<RoomBloc>().add(
                UpdateRoomNameRequested(widget.room.id, newName),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 