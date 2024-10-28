import 'package:equatable/equatable.dart';
import 'package:chatroom_app/models/room.dart';

abstract class RoomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateRoomRequested extends RoomEvent {
  final String name;
  final RoomType type;
  final List<String> members;

  CreateRoomRequested({
    required this.name,
    required this.type,
    required this.members,
  });

  @override
  List<Object?> get props => [name, type, members];
}

class LoadUsersRequested extends RoomEvent {}
