import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:chatroom_app/models/user.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:equatable/equatable.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository _roomRepository;

  RoomBloc({required RoomRepository roomRepository})
      : _roomRepository = roomRepository,
        super(RoomInitial()) {
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<LoadUsersRequested>(_onLoadUsersRequested);
    on<LoadRoomsRequested>(_onLoadRoomsRequested);
    on<LoadPublicRoomsRequested>(_onLoadPublicRoomsRequested);
    on<JoinRoomRequested>(_onJoinRoomRequested);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
  }

  void _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    try {
      final room = await _roomRepository.createRoom(
        name: event.name,
        type: event.type,
        members: event.members,
      );
      emit(RoomSuccess(room));
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  void _onLoadUsersRequested(
    LoadUsersRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    try {
      final users = await _roomRepository.getUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onLoadRoomsRequested(
    LoadRoomsRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    try {
      await emit.forEach<List<Room>>(
        _roomRepository.getRooms(),
        onData: (rooms) => rooms.isEmpty ? RoomsEmpty() : MyRoomsLoaded(rooms),
        onError: (error, stackTrace) => RoomFailure(error.toString()),
      );
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onLoadPublicRoomsRequested(
    LoadPublicRoomsRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    try {
      await emit.forEach<List<Room>>(
        _roomRepository.getPublicRooms(),
        onData: (rooms) => PublicRoomsLoaded(rooms),
        onError: (error, stackTrace) => RoomFailure(error.toString()),
      );
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onJoinRoomRequested(
    JoinRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    try {
      await _roomRepository.joinRoom(event.roomId);
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<RoomState> emit,
  ) async {
    try {
      await _roomRepository.markMessagesAsRead(event.roomId);
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }
}
