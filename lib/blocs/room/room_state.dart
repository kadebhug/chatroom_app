part of 'room_bloc.dart';

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

class RoomsLoaded extends RoomState {
  final List<Room> rooms;

  RoomsLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class MyRoomsLoaded extends RoomState {
  final List<Room> rooms;

  MyRoomsLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class PublicRoomsLoaded extends RoomState {
  final List<Room> rooms;

  PublicRoomsLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class RoomsEmpty extends RoomState {}

class RoomDetailsLoaded extends RoomState {
  final Room room;

  RoomDetailsLoaded(this.room);

  @override
  List<Object?> get props => [room];
}
