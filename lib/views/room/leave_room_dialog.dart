import 'package:flutter/material.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';

class LeaveRoomDialog extends StatelessWidget {
  final Room room;

  const LeaveRoomDialog({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Leave Room'),
      content: const Text('Are you sure you want to leave this room?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<RoomBloc>().add(LeaveRoomRequested(room.id));
            Navigator.of(context).pop();
          },
          child: const Text('Leave'),
        ),
      ],
    );
  }
} 