import 'package:flutter/material.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';

class DeleteRoomDialog extends StatelessWidget {
  final Room room;

  const DeleteRoomDialog({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Room'),
      content: const Text('Are you sure you want to delete this room?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<RoomBloc>().add(DeleteRoomRequested(room.id));
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
} 