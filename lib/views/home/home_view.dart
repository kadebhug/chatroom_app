import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';
import 'package:chatroom_app/blocs/room/room_event.dart';
import 'package:chatroom_app/blocs/room/room_state.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:chatroom_app/models/user.dart';
import 'package:chatroom_app/repositories/room_repository.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc(roomRepository: RoomRepository()),
      child: BlocListener<RoomBloc, RoomState>(
        listener: (context, state) {
          if (state is RoomSuccess) {
            Navigator.of(context).pop(); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Room created successfully!')),
            );
          } else if (state is RoomFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: const _HomeViewContent(),
      ),
    );
  }
}

class _HomeViewContent extends StatelessWidget {
  const _HomeViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home View')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoomDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RoomBloc>(),
        child: const CreateRoomDialog(),
      ),
    );
  }
}

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({Key? key}) : super(key: key);

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  RoomType _roomType = RoomType.public;
  final Set<String> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(LoadUsersRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Room'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<RoomType>(
                segments: const [
                  ButtonSegment(
                    value: RoomType.public,
                    label: Text('Public'),
                  ),
                  ButtonSegment(
                    value: RoomType.private,
                    label: Text('Private'),
                  ),
                ],
                selected: {_roomType},
                onSelectionChanged: (Set<RoomType> selection) {
                  setState(() {
                    _roomType = selection.first;
                  });
                },
              ),
              if (_roomType == RoomType.private) ...[
                const SizedBox(height: 16),
                const Text('Select Users:'),
                const SizedBox(height: 8),
                Flexible(
                  child: BlocBuilder<RoomBloc, RoomState>(
                    builder: (context, state) {
                      if (state is UsersLoaded) {
                        return ListView.builder(
                          itemCount: state.users.length,
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            return CheckboxListTile(
                              title: Text(user.name ?? 'Unnamed User'),
                              subtitle: Text(user.email ?? ''),
                              value: _selectedUsers.contains(user.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value ?? false) {
                                    _selectedUsers.add(user.id);
                                  } else {
                                    _selectedUsers.remove(user.id);
                                  }
                                });
                              },
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<RoomBloc>().add(
                    CreateRoomRequested(
                      name: _nameController.text,
                      type: _roomType,
                      members: _selectedUsers.toList(),
                    ),
                  );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
