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

class LoadMessagesRequested extends RoomEvent {
  final String roomId;

  LoadMessagesRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SendMessageRequested extends RoomEvent {
  final String roomId;
  final String content;

  SendMessageRequested({
    required this.roomId,
    required this.content,
  });

  @override
  List<Object?> get props => [roomId, content];
}

class _MessagesUpdated extends RoomEvent {
  final List<Message> messages;

  _MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class LoadPublicRoomsRequested extends RoomEvent {}

class JoinRoomRequested extends RoomEvent {
  final String roomId;

  JoinRoomRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
