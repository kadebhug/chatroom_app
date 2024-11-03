import 'package:chatroom_app/blocs/room/room_bloc.dart';
import 'package:chatroom_app/models/room.dart';
import 'package:chatroom_app/views/room/delete_room_dialog.dart';
import 'package:chatroom_app/views/room/edit_room_name_dialog.dart';
import 'package:chatroom_app/views/room/leave_room_dialog.dart';
import 'package:chatroom_app/views/room/manage_members_dialog.dart';
import 'package:chatroom_app/views/room/room_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatroom_app/blocs/message/message_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SingleRoomView extends StatefulWidget {
  final String roomId;

  const SingleRoomView({Key? key, required this.roomId}) : super(key: key);

  @override
  State<SingleRoomView> createState() => _SingleRoomViewState();
}

class _SingleRoomViewState extends State<SingleRoomView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MessageBloc _messageBloc;
  late RoomBloc _roomBloc;

  @override
  void initState() {
    super.initState();
    _messageBloc = context.read<MessageBloc>();
    _roomBloc = context.read<RoomBloc>();
    _messageBloc.add(LoadMessagesRequested(widget.roomId));
    _roomBloc.add(MarkMessagesAsRead(widget.roomId));
    _roomBloc.add(LoadRoomDetailsRequested(widget.roomId));
  }

  void _showRoomSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomDetailsLoaded) {
            final room = state.room;
            final currentUser = FirebaseAuth.instance.currentUser;
            final isCreator = room.createdBy == currentUser?.uid;

            return RoomSettingsSheet(
              room: room,
              isCreator: isCreator,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        final roomName = state is RoomDetailsLoaded 
            ? state.room.name 
            : 'Room ${widget.roomId}';

        return Scaffold(
          appBar: AppBar(
            title: Text(roomName),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showRoomSettings,
              ),
            ],
          ),
          body: SingleRoomContent(
            roomId: widget.roomId,
            scrollController: _scrollController,
            messageController: _messageController,
            onSendMessage: _sendMessage,
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageBloc.add(
        SendMessageRequested(
          roomId: widget.roomId,
          content: message,
        ),
      );
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class SingleRoomContent extends StatelessWidget {
  final String roomId;
  final ScrollController scrollController;
  final TextEditingController messageController;
  final VoidCallback onSendMessage;

  const SingleRoomContent({
    Key? key,
    required this.roomId,
    required this.scrollController,
    required this.messageController,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Column(
        children: [
          Expanded(
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Start the conversation!'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == currentUser?.uid;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe && message.senderName != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        message.senderName!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary
                                              .withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMe
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: onSendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      );
  }
}

class RoomSettingsSheet extends StatelessWidget {
  final Room room;
  final bool isCreator;

  const RoomSettingsSheet({
    Key? key,
    required this.room,
    required this.isCreator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Room Info'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => RoomInfoDialog(room: room),
              );
            },
          ),
          if (isCreator) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Room Name'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => EditRoomNameDialog(room: room),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Manage Members'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => ManageMembersDialog(room: room),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Room', 
                style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => DeleteRoomDialog(room: room),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Leave Room', 
                style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => LeaveRoomDialog(room: room),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
