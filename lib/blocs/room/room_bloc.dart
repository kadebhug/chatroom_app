import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:chatroom_app/models/room.dart';
import 'room_event.dart';
import 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository _roomRepository;

  RoomBloc({required RoomRepository roomRepository})
      : _roomRepository = roomRepository,
        super(RoomInitial()) {
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<LoadUsersRequested>(_onLoadUsersRequested);
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
}
