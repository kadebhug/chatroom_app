import 'package:flutter/material.dart';
import 'package:chatroom_app/models/room.dart';

class RoomInfoDialog extends StatelessWidget {
  final Room room;

  const RoomInfoDialog({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Room Info'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Room Name: ${room.name}'),
          Text('Room ID: ${room.id}'),
          Text('Created By: ${room.createdBy}'),
          Text('Members: ${room.members.join(', ')}'),
          Text('Created At: ${room.createdAt}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
} 