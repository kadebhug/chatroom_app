import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chatroom_app/models/message.dart';
import 'package:chatroom_app/repositories/room_repository.dart';
import 'package:equatable/equatable.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final RoomRepository _roomRepository;
  StreamSubscription<List<Message>>? _messagesSubscription;

  MessageBloc({required RoomRepository roomRepository})
      : _roomRepository = roomRepository,
        super(MessageInitial()) {
    on<LoadMessagesRequested>(_onLoadMessagesRequested);
    on<SendMessageRequested>(_onSendMessageRequested);
    on<_MessagesUpdated>(_onMessagesUpdated);
  }

  Future<void> _onLoadMessagesRequested(
    LoadMessagesRequested event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageLoading());
    
    try {
      await _messagesSubscription?.cancel();
      await emit.forEach<List<Message>>(
        _roomRepository.getMessages(event.roomId),
        onData: (messages) => MessagesLoaded(messages),
        onError: (error, stackTrace) => MessageFailure(error.toString()),
      );
    } catch (e) {
      emit(MessageFailure(e.toString()));
    }
  }

  Future<void> _onSendMessageRequested(
    SendMessageRequested event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _roomRepository.sendMessage(event.roomId, event.content);
    } catch (e) {
      emit(MessageFailure(e.toString()));
    }
  }

  void _onMessagesUpdated(
    _MessagesUpdated event,
    Emitter<MessageState> emit,
  ) {
    emit(MessagesLoaded(event.messages));
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
} 