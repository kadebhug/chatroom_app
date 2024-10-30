import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:chatroom_app/models/message.dart';
import 'room_event.dart';
import 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository _roomRepository;
  StreamSubscription<List<Message>>? _messagesSubscription;

  RoomBloc({required RoomRepository roomRepository})
      : _roomRepository = roomRepository,
        super(RoomInitial()) {
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<LoadUsersRequested>(_onLoadUsersRequested);
    on<LoadRoomsRequested>(_onLoadRoomsRequested);
    on<LoadMessagesRequested>(_onLoadMessagesRequested);
    on<SendMessageRequested>(_onSendMessageRequested);
    on<LoadPublicRoomsRequested>(_onLoadPublicRoomsRequested);
    on<JoinRoomRequested>(_onJoinRoomRequested);
    on<_MessagesUpdated>(_onMessagesUpdated);
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
    log('Loading rooms');
    if (!emit.isDone) emit(RoomLoading());
    log('Loading rooms');
    try {
      await _messagesSubscription?.cancel();
      await emit.forEach<List<Room>>(
        _roomRepository.getRooms(),
        onData: (rooms) {
          if (rooms.isEmpty) {
            return RoomsEmpty();
          }
          return MyRoomsLoaded(rooms);
        },
        onError: (error, stackTrace) {
          return RoomFailure(error.toString());
        },
      );
    } catch (e) {
      if (!emit.isDone) emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onLoadMessagesRequested(
    LoadMessagesRequested event,
    Emitter<RoomState> emit,
  ) async {
    if (!emit.isDone) emit(RoomLoading());
    
    try {
      await _messagesSubscription?.cancel();
      await emit.forEach<List<Message>>(
        _roomRepository.getMessages(event.roomId),
        onData: (messages) => MessagesLoaded(messages),
        onError: (error, stackTrace) => RoomFailure(error.toString()),
      );
    } catch (e) {
      if (!emit.isDone) emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onSendMessageRequested(
    SendMessageRequested event,
    Emitter<RoomState> emit,
  ) async {
    try {
      await _roomRepository.sendMessage(event.roomId, event.content);
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  void _onMessagesUpdated(
    _MessagesUpdated event,
    Emitter<RoomState> emit,
  ) {
    emit(MessagesLoaded(event.messages));
  }

  Future<void> _onLoadPublicRoomsRequested(
    LoadPublicRoomsRequested event,
    Emitter<RoomState> emit,
  ) async {
    if (!emit.isDone) emit(RoomLoading());
    
    try {
      await emit.forEach<List<Room>>(
        _roomRepository.getPublicRooms(),
        onData: (rooms) {
          print('Received ${rooms.length} public rooms'); // Debug print
          return PublicRoomsLoaded(rooms);
        },
        onError: (error, stackTrace) {
          print('Error loading public rooms: $error'); // Debug print
          return RoomFailure(error.toString());
        },
      );
    } catch (e) {
      print('Exception in _onLoadPublicRoomsRequested: $e'); // Debug print
      if (!emit.isDone) emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onJoinRoomRequested(
    JoinRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    try {
      await _roomRepository.joinRoom(event.roomId);
      // The rooms list will automatically update through the stream
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}

// Internal events
class _RoomsUpdated extends RoomEvent {
  final List<Room> rooms;

  _RoomsUpdated(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class _RoomLoadError extends RoomEvent {
  final String error;

  _RoomLoadError(this.error);

  @override
  List<Object?> get props => [error];
}

class _MessagesUpdated extends RoomEvent {
  final List<Message> messages;

  _MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}
