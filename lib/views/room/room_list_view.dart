import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';
import 'package:chatroom_app/blocs/room/room_event.dart';
import 'package:chatroom_app/blocs/room/room_state.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:chatroom_app/views/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class RoomListView extends StatefulWidget {
  const RoomListView({Key? key}) : super(key: key);

  @override
  State<RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RoomBloc(roomRepository: RoomRepository())
            ..add(LoadRoomsRequested()),
        ),
        BlocProvider(
          create: (context) => RoomBloc(roomRepository: RoomRepository())
            ..add(LoadPublicRoomsRequested()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rooms'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Rooms'),
              Tab(text: 'Available Rooms'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _MyRoomsTab(),
            _AvailableRoomsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateRoomDialog(context),
          child: const Icon(Icons.add),
        ),
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
    return BlocBuilder<RoomBloc, RoomState>(
      bloc: context.read<RoomBloc>(),
      builder: (context, state) {
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
        if (state is RoomFailure) {
          return Center(child: Text('Error: ${state.error}'));
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
    return BlocBuilder<RoomBloc, RoomState>(
      bloc: context.watch<RoomBloc>(),
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
