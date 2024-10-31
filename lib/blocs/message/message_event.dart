part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessagesRequested extends MessageEvent {
  final String roomId;

  LoadMessagesRequested(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SendMessageRequested extends MessageEvent {
  final String roomId;
  final String content;

  SendMessageRequested({
    required this.roomId,
    required this.content,
  });

  @override
  List<Object?> get props => [roomId, content];
}

class _MessagesUpdated extends MessageEvent {
  final List<Message> messages;

  _MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
} 