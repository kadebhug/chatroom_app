import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';
import 'package:chatroom_app/blocs/room/room_event.dart';
import 'package:chatroom_app/blocs/room/room_state.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:go_router/go_router.dart';
import 'package:chatroom_app/blocs/auth/auth_bloc.dart';
import 'package:chatroom_app/blocs/auth/auth_event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RoomBloc _roomBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    _roomBloc = context.read<RoomBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: _HomeViewContent(tabController: _tabController),
    );
  }
}

class _HomeViewContent extends StatelessWidget {
  final TabController tabController;

  const _HomeViewContent({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(tabController.index == 0 ? 'My Rooms' : 'Available Rooms'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'User'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  (user?.displayName?.isNotEmpty ?? false) 
                      ? user!.displayName![0].toUpperCase()
                      : (user?.email?.isNotEmpty ?? false)
                          ? user!.email![0].toUpperCase()
                          : 'U',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                context.go('/');
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Rooms'),
              onTap: () {
                context.go('/rooms');
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                context.go('/settings');
                Navigator.pop(context); // Close drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          context.read<AuthBloc>().add(SignOutRequested());
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          _MyRoomsTab(),
          _AvailableRoomsTab(),
        ],
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
          controller: tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat),
              text: 'My Rooms',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: 'Available',
            ),
          ],
        ),
      ),
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

class _MyRoomsTab extends StatelessWidget {
  const _MyRoomsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("IN MY ROOMS TAB");
    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        log("STATE LISTENER: $state");
        if (state is RoomInitial) {
          log("IN INTIAL STATE");
          context.read<RoomBloc>().add(LoadRoomsRequested());
        }
        if (state is RoomFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        log("STATE BUILDER: $state");
        if (state is RoomLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MyRoomsLoaded) {
          if (state.rooms.isEmpty) {
            return const Center(
              child: Text('No rooms yet. Create one to get started!'),
            );
          }
          return ListView.builder(
            itemCount: state.rooms.length,
            itemBuilder: (context, index) {
              final room = state.rooms[index];
              return RoomListTile(room: room);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _AvailableRoomsTab extends StatelessWidget {
  const _AvailableRoomsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        if (state is RoomInitial) {
          context.read<RoomBloc>().add(LoadPublicRoomsRequested());
        }
      },
      builder: (context, state) {
        if (state is RoomLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PublicRoomsLoaded) {
          if (state.rooms.isEmpty) {
            return const Center(
              child: Text('No public rooms available.'),
            );
          }
          return ListView.builder(
            itemCount: state.rooms.length,
            itemBuilder: (context, index) {
              final room = state.rooms[index];
              final user = FirebaseAuth.instance.currentUser;
              return RoomListTile(
                room: room,
                showJoinButton: !room.members.contains(user?.uid),
                onJoin: () {
                  context.read<RoomBloc>().add(JoinRoomRequested(room.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully joined the room!'),
                    ),
                  );
                  context.go('/rooms/${room.id}');
                },
              );
            },
          );
        }
        if (state is RoomFailure) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
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

class RoomListTile extends StatelessWidget {
  final Room room;
  final bool showJoinButton;
  final VoidCallback? onJoin;

  const RoomListTile({
    Key? key,
    required this.room,
    this.showJoinButton = false,
    this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        room.type == RoomType.private
            ? Icons.lock_outline
            : Icons.public,
      ),
      title: Text(room.name),
      subtitle: Text(
        '${room.members.length} member${room.members.length == 1 ? '' : 's'}',
      ),
      trailing: showJoinButton
          ? ElevatedButton(
              onPressed: onJoin,
              child: const Text('Join'),
            )
          : Text(
              room.type == RoomType.private ? 'Private' : 'Public',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
      onTap: showJoinButton ? null : () => context.go('/rooms/${room.id}'),
    );
  }
}
