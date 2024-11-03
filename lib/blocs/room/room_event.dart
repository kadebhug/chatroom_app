part of 'room_bloc.dart';

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

class LoadRoomsRequested extends RoomEvent {}

class LoadPublicRoomsRequested extends RoomEvent {}

class JoinRoomRequested extends RoomEvent {
  final String roomId;

  JoinRoomRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class MarkMessagesAsRead extends RoomEvent {
  final String roomId;

  MarkMessagesAsRead(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class LoadRoomDetailsRequested extends RoomEvent {
  final String roomId;

  LoadRoomDetailsRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class UpdateRoomNameRequested extends RoomEvent {
  final String roomId;
  final String newName;

  UpdateRoomNameRequested(this.roomId, this.newName);

  @override
  List<Object?> get props => [roomId, newName];
}

class LeaveRoomRequested extends RoomEvent {
  final String roomId;

  LeaveRoomRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class DeleteRoomRequested extends RoomEvent {
  final String roomId;

  DeleteRoomRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
