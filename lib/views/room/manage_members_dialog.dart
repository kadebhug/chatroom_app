import 'package:flutter/material.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';

class ManageMembersDialog extends StatelessWidget {
  final Room room;

  const ManageMembersDialog({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Members'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Members:'),
            ...room.members.map((member) {
              return ListTile(
                title: Text(member),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    // Logic to remove member
                    context.read<RoomBloc>().add(LeaveRoomRequested(room.id));
                  },
                ),
              );
            }).toList(),
          ],
        ),
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