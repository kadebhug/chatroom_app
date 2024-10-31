part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessagesLoaded extends MessageState {
  final List<Message> messages;

  MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageFailure extends MessageState {
  final String error;

  MessageFailure(this.error);

  @override
  List<Object?> get props => [error];
} 