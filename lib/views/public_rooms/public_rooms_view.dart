import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/room/room_bloc.dart';
import 'package:chatroom_app/blocs/room/room_event.dart';
import 'package:chatroom_app/blocs/room/room_state.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:chatroom_app/views/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class PublicRoomsView extends StatelessWidget {
  const PublicRoomsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc(roomRepository: RoomRepository())
        ..add(LoadPublicRoomsRequested()),
      child: const _PublicRoomsContent(),
    );
  }
}

class _PublicRoomsContent extends StatelessWidget {
  const _PublicRoomsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Rooms'),
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
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
      ),
    );
  }
} 