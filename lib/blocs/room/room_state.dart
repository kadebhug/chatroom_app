import 'package:equatable/equatable.dart';
import 'package:chatroom_app/models/user.dart';
import 'package:chatroom_app/models/room.dart';

abstract class RoomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomSuccess extends RoomState {
  final Room room;

  RoomSuccess(this.room);

  @override
  List<Object?> get props => [room];
}

class RoomFailure extends RoomState {
  final String error;

  RoomFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class UsersLoaded extends RoomState {
  final List<User> users;

  UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}
